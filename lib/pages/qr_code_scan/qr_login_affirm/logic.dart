import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../api/user_api.dart';
import '../../../components/custom_flutter_toast/index.dart';

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
        CustomFlutterToast.showSuccessToast("登录成功~");
      }

      Get.offAllNamed("/");//无论成功失败，都跳转到首页，并清除所有历史路由
      //一直回退到跟路由
      //Get.until((route) => Get.currentRoute == "/");
    });
  }
}
