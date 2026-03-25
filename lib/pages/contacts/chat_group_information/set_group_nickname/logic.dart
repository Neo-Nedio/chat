import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../api/chat_group_api.dart';
import '../../../../components/custom_flutter_toast/index.dart';

class SetGroupNameNickLogic extends GetxController {
  final _chatGroupApi = ChatGroupApi();
  final TextEditingController nameController = TextEditingController();
  late String chatGroupId;
  late RxInt nameLength = 0.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.text = Get.arguments['name']; //获得群昵称用于填充
    chatGroupId = Get.arguments['chatGroupId'];
    nameLength.value = nameController.text.length;
  }

  void onSetName() async {
    if (nameController.text.isEmpty || nameController.text.trim().isEmpty) {
      CustomFlutterToast.showErrorToast('名称不能为空~');
      return;
    }
    final response = await _chatGroupApi.update(
        chatGroupId, 'group_name', nameController.text);
    if (response['code'] == 0) {
      CustomFlutterToast.showSuccessToast('群昵称设置成功~');
      Get.back(result: nameController.text); //返回名字
    } else {
      CustomFlutterToast.showErrorToast(response['msg']);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
