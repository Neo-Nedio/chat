import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/ai_api.dart';
import '../../../components/custom_flutter_toast/index.dart';

class AiModelEditLogic extends GetxController {
  final _aiApi = AiApi();

  final modelNameController = TextEditingController(); // 显示名
  final baseUrlController = TextEditingController(); // 接口地址
  final apiKeyController = TextEditingController(); // ApiKey
  final modelController = TextEditingController(); // 模型标识

  bool isEdit = false; // 编辑模式（arguments 携带模型数据）
  String id = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      isEdit = true;
      id = args['id'] ?? '';
      modelNameController.text = args['modelName'] ?? '';
      baseUrlController.text = args['baseUrl'] ?? '';
      modelController.text = args['model'] ?? '';
      //apiKey 列表接口不返回，编辑时留空表示不修改
    }
  }

  //提交（新增 / 编辑）
  Future<void> submit() async {
    final modelName = modelNameController.text.trim();
    final baseUrl = baseUrlController.text.trim();
    final apiKey = apiKeyController.text.trim();
    final model = modelController.text.trim();

    //新增四项全必填；编辑时 apiKey 可留空（不修改）
    if (modelName.isEmpty || baseUrl.isEmpty || model.isEmpty ||
        (!isEdit && apiKey.isEmpty)) {
      CustomFlutterToast.showErrorToast('请填写完整信息~');
      return;
    }

    final res = isEdit
        ? await _aiApi.modelUpdate(
            id: id,
            modelName: modelName,
            baseUrl: baseUrl,
            apiKey: apiKey.isEmpty ? null : apiKey,
            model: model,
          )
        : await _aiApi.modelAdd(
            modelName: modelName,
            baseUrl: baseUrl,
            apiKey: apiKey,
            model: model,
          );

    if (res['code'] == 0) {
      CustomFlutterToast.showSuccessToast(isEdit ? '修改成功~' : '添加成功~');
      Get.back(result: true); //通知侧滑栏刷新列表
    }
  }

  @override
  void onClose() {
    modelNameController.dispose();
    baseUrlController.dispose();
    apiKeyController.dispose();
    modelController.dispose();
    super.onClose();
  }
}