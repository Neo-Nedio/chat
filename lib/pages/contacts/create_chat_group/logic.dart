import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/chat_group_api.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../../../utils/String.dart';

class CreateChatGroupLogic extends GetxController {
  final _chatGroupApi = ChatGroupApi();
  late int nameLength = 0;
  final TextEditingController nameController = TextEditingController();

  //创建群聊
  void onCreateChatGroup() async {
    if (StringUtil.isNullOrEmpty(nameController.text)) {
      CustomFlutterToast.showErrorToast('请输入群名称~');
      return;
    }
    final response = await _chatGroupApi.create(nameController.text);
    if (response['code'] == 0) {
      CustomFlutterToast.showSuccessToast('创建群聊成功~');
      Get.back(result: true);
    } else {
      CustomFlutterToast.showErrorToast(response['msg']);
    }
  }

  //名字改变
  void onGroupNameChanged(String value) {
    nameLength = value.length;
    update([const Key('create_chat_group')]);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
