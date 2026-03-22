import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../api/notify_api.dart';

class QRFriendAffirmLogic extends GetxController {
  final _notifyApi = NotifyApi();
  late final dynamic result; // 存储传递过来的好友信息

  @override
  void onInit() {
    super.onInit();
    //Get.arguments（对象参数）
    result = Get.arguments['result']; // 接收参数
  }

  void onAddFriend() {
    // 调用添加好友API
    _notifyApi.friendApply(result['id'], "通过二维码添加好友").then((res) {
      if (res['code'] == 0) {
        Fluttertoast.showToast(
            msg: "请求成功~",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: const Color(0xFF4C9BFF),
            textColor: Colors.white,
            fontSize: 16.0);
      }
      //Get.until((route) => Get.currentRoute == "/");
    });
  }
}
