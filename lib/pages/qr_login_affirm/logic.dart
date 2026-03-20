import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../api/user_api.dart';

class QRLoginAffirmLogic extends GetxController {
  final _userAPi = UserApi();
  late final String qrCode;

  @override
  void onInit() {
    super.onInit();
    qrCode = Get.arguments['qrCode'];
  }

  // 点击确认登录按钮时调用
  void onQrLogin() {
    // 调用登录API，传入二维码
    _userAPi.qrLogin(qrCode).then((res) {

      // 如果登录成功（code为0）
      if (res['code'] == 0) {
        // 显示Toast提示
        Fluttertoast.showToast(
            msg: "登录成功~",  // 提示信息
            toastLength: Toast.LENGTH_SHORT,  // 显示时长
            gravity: ToastGravity.TOP,  // 显示位置（顶部）
            timeInSecForIosWeb: 1,  // iOS/Web显示时间
            backgroundColor: const Color(0xFF4C9BFF),  // 蓝色背景
            textColor: Colors.white,  // 白色文字
            fontSize: 16.0);
      }

      // 无论成功失败，都跳转到首页，并清除所有历史路由
      Get.offAllNamed("/");
    });
  }
}
