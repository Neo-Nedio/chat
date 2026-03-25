import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api/chat_group_api.dart';
import '../../../../components/custom_flutter_toast/index.dart';

class SetGroupRemarkLogic extends GetxController {
  final _chatGroupApi = ChatGroupApi();
  final TextEditingController remarkController = TextEditingController();
  late String chatGroupId;
  late RxInt remarkLength = 0.obs;

  @override
  void onInit() {
    super.onInit();
    remarkController.text = Get.arguments['remark']; //获得群备注用于填充
    chatGroupId = Get.arguments['chatGroupId'];
    remarkLength.value = remarkController.text.length;
  }

  void onSetName() async {
    if (remarkController.text.isEmpty || remarkController.text.trim().isEmpty) {
      CustomFlutterToast.showErrorToast('名称不能为空~');
      return;
    }
    final response = await _chatGroupApi.update(
        chatGroupId, 'group_remark', remarkController.text);
    if (response['code'] == 0) {
      CustomFlutterToast.showSuccessToast('备注修改成功~');
      Get.back(result: remarkController.text);//返回群备注
    } else {
      CustomFlutterToast.showErrorToast(response['msg']);
    }
  }

  @override
  void onClose() {
    remarkController.dispose();
    super.onClose();
  }
}
