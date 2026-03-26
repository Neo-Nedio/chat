import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../api/chat_group_notice_api.dart';
import '../../../../../components/custom_flutter_toast/index.dart';

class AddChatGroupNoticeLogic extends GetxController {
  final _chatGroupNoticeApi = ChatGroupNoticeApi();
  final TextEditingController noticeController = TextEditingController();
  late String? chatGroupNoticeId;  // 公告ID，有值表示编辑模式
  late String chatGroupId;          // 群聊ID
  late RxInt noticeLength = 0.obs;  // 公告长度（响应式）

  @override
  void onInit() {
    super.onInit();
    noticeController.text = Get.arguments['content'] ?? '';        // 编辑时传入原有内容
    chatGroupNoticeId = Get.arguments['chatGroupNoticeId'];        // 有值=编辑，无值=新增
    chatGroupId = Get.arguments['chatGroupId'];                    // 群聊ID
    noticeLength.value = noticeController.text.length;             // 初始化长度
  }

  // 提交公告
  void onAddNotice() async {
    if (noticeController.text=='' || noticeController.text.trim().isEmpty) {
      CustomFlutterToast.showErrorToast('公告不能为空~');
      return;
    }

    Map<String, dynamic> response = {'code': 1};

    // 判断是新增还是编辑
    if (chatGroupNoticeId == null) {
      // 新增公告
      response =
          await _chatGroupNoticeApi.create(chatGroupId, noticeController.text);
    } else {
      //编辑公告
      response = await _chatGroupNoticeApi.update(
          chatGroupId, chatGroupNoticeId!, noticeController.text);
    }

    if (response['code'] == 0) {
      CustomFlutterToast.showSuccessToast('群公告设置成功~');
      Get.back(result: true);
    } else {
      CustomFlutterToast.showErrorToast('群公告设置失败~');
    }
  }

  @override
  void onClose() {
    noticeController.dispose();
    super.onClose();
  }
}
