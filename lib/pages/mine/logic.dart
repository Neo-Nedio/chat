import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MineLogic extends GetxController {
  late dynamic currentUserInfo = {};

  Future<void> init() async {
    await _onGetCurrentUserInfo(); //更新储存后再update
    update([const Key("mine")]);
  }

  //获取用户信息
  Future<void> _onGetCurrentUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserInfo['name'] = prefs.getString('username');
    currentUserInfo['portrait'] = prefs.getString('portrait');
    currentUserInfo['account'] = prefs.getString('account');
    currentUserInfo['sex'] = prefs.getString('sex');
  }

  void handlerLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAndToNamed('/login');
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }
}
