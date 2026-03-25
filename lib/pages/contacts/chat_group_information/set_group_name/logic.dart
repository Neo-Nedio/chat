import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api/chat_group_api.dart';
import '../../../../components/custom_flutter_toast/index.dart';

class SetGroupNameLogic extends GetxController {
  final _chatGroupApi = ChatGroupApi();
  final TextEditingController nameController = TextEditingController();
  late String chatGroupId;
  late RxInt nameLength = 0.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.text = Get.arguments['name']; //获得群聊名字用于填充
    chatGroupId = Get.arguments['chatGroupId'];
    nameLength.value = nameController.text.length;
  }

  //设置群聊名字
  void onSetName() async {
    if (nameController.text.isEmpty || nameController.text.trim().isEmpty) {
      CustomFlutterToast.showErrorToast('名称不能为空~');
      return;
    }
    final response =
        await _chatGroupApi.updateName(chatGroupId, nameController.text);
    if (response['code'] == 0) {
      CustomFlutterToast.showSuccessToast('更新群名称成功~');
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
