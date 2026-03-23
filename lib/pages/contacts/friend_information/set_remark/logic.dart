import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../../api/friend_api.dart';
import '../../../../utils/getx_config/GlobalThemeConfig.dart';
import '../logic.dart';

class SetRemarkLogic extends GetxController {
  final _friendApi = FriendApi();
  final TextEditingController remarkController = TextEditingController();
  late int remarkLength = 0;
  late String friendId;
  //好友信息页面
  final FriendInformationLogic _friendInformationLogic =
      GetInstance().find<FriendInformationLogic>();
  //全局主题
  GlobalThemeConfig theme = GetInstance().find<GlobalThemeConfig>();

  @override
  void onInit() {
    super.onInit();
    remarkController.text = Get.arguments['remark'];
    friendId = Get.arguments['friendId'];
    remarkLength = remarkController.text.length;
  }

  //设置备注
  void onSetRemark() async {
    final response =
        await _friendApi.setRemark(friendId, remarkController.text);
    if (response['code'] == 0) {
      Fluttertoast.showToast(
          msg: "备注设置成功~",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: theme.primaryColor,
          textColor: Colors.white,
          fontSize: 16.0);
      //刷新好友信息并返回
      _friendInformationLogic.getFriendInfo();
      Get.back();
    } else {
      Fluttertoast.showToast(
          msg: response['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  //备注改变
  void onRemarkChanged(String value) {
    remarkLength = value.length;
    update([const Key('set_remark')]);
  }

  @override
  void onClose() {
    remarkController.dispose();
    super.onClose();
  }
}
