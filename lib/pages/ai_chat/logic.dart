import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/ai_api.dart';
import '../../components/CustomDialog/index.dart';
import '../../components/custom_flutter_toast/index.dart';

class AiChatLogic extends GetxController {
  final _aiApi = AiApi();

  final scaffoldKey = GlobalKey<ScaffoldState>(); // 用于自动打开侧滑栏
  final questionController = TextEditingController(); // 问题输入框
  final scrollController = ScrollController(); // 消息列表滚动

  final modelList = <dynamic>[].obs; // 模型列表
  final Rx<Map<String, dynamic>?> currentModel = Rx(null); // 当前选中模型
  final records = <dynamic>[].obs; // 聊天记录（时间正序）
  final isStreaming = false.obs; // 流式回答中（发送按钮置灰）
  final streamingContent = ''.obs; // 当前流式回答的累积内容

  StreamSubscription? _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    onModelList();
    onChatRecordList();

    //进入页面后直接打开侧滑栏（等首帧渲染完成再操作 Scaffold）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldKey.currentState?.openEndDrawer();
    });
  }

  //加载模型列表，加载完成后默认选中第一个
  Future<void> onModelList() async {
    try {
      final res = await _aiApi.modelList();
      if (res['code'] == 0) {
        modelList.assignAll(res['data'] ?? []);
        //当前未选中或选中的模型已被删除时，重置为第一个
        final exists = currentModel.value != null &&
            modelList.any((m) => m['id'] == currentModel.value!['id']);
        if (!exists) {
          currentModel.value = modelList.isNotEmpty
              ? Map<String, dynamic>.from(modelList.first)
              : null;
        }
      }
    } catch (e) {
      debugPrint('onModelList error: $e');
    }
  }

  //加载聊天记录
  Future<void> onChatRecordList() async {
    try {
      final res = await _aiApi.chatRecordList();
      if (res['code'] == 0) {
        records.assignAll(res['data'] ?? []);
        scrollToBottom();
      }
    } catch (e) {
      debugPrint('onChatRecordList error: $e');
    }
  }

  //切换模型并收起侧滑栏
  void selectModel(Map<String, dynamic> model) {
    currentModel.value = model;
    scaffoldKey.currentState?.closeEndDrawer();
  }

  //跳转模型编辑页（新增：不传参；编辑：传入模型数据），返回后刷新列表
  Future<void> toModelEdit([Map<String, dynamic>? model]) async {
    final result = await Get.toNamed('/ai_model_edit', arguments: model);
    if (result == true) {
      onModelList();
    }
  }

  //删除模型（二次确认）
  void deleteModel(Map<String, dynamic> model) {
    CustomDialog.showTipDialog(
      Get.context!,
      text: '确定删除模型「${model['modelName']}」吗？',
      onOk: () async {
        final res = await _aiApi.modelDelete(model['id']);
        if (res['code'] == 0) {
          CustomFlutterToast.showSuccessToast('删除成功~');
          onModelList(); //刷新列表，若删的是当前选中模型会自动重置为第一个
        }
      },
      onCancel: () {},
    );
  }

  //发送问题（SSE 流式）
  Future<void> send() async {
    final question = questionController.text.trim();
    if (question.isEmpty) {
      CustomFlutterToast.showErrorToast('问题不能为空~');
      return;
    }
    if (currentModel.value == null) {
      CustomFlutterToast.showErrorToast('请先选择模型~');
      return;
    }
    if (isStreaming.value) return; //流式期间禁止重复发送

    //本地立即插入用户提问（乐观 UI）
    records.add({
      'role': 'user',
      'content': question,
      'createTime': DateTime.now().toString(),
    });
    questionController.clear();
    scrollToBottom();

    //进入流式状态，追加一条空的 assistant 气泡承接打字机内容
    isStreaming.value = true;
    streamingContent.value = '';

    try {
      await for (final event
          in _aiApi.answersStream(currentModel.value!['id'], question)) {
        switch (event.event) {
          case 'delta': //增量内容，追加到当前气泡
            streamingContent.value += event.data['content'] ?? '';
            scrollToBottom();
            break;
          case 'done': //流结束，用落库后的完整记录替换临时气泡
            records.add(event.data);
            _resetStreaming();
            scrollToBottom();
            break;
          case 'error': //出错，丢弃临时气泡
            CustomFlutterToast.showErrorToast(
                event.data['msg'] ?? 'AI 回答失败~');
            _resetStreaming();
            break;
        }
      }
    } catch (e) {
      debugPrint('answersStream error: $e');
      _resetStreaming();
    }
  }

  //结束流式状态
  void _resetStreaming() {
    isStreaming.value = false;
    streamingContent.value = '';
  }

  //滚动到消息列表底部
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    _streamSubscription?.cancel();
    questionController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}