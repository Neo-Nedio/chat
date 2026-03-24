import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../api/notify_api.dart';
import '../../../components/custom_flutter_toast/index.dart';

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
        CustomFlutterToast.showSuccessToast("请求成功");
      }
      //Get.until((route) => Get.currentRoute == "/");
    });
  }
}
