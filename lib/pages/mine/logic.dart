import 'dart:io';

import 'package:chat_mobile/api/admin_api.dart';
import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/user_api.dart';
import '../../components/custom_flutter_toast/index.dart';
import '../../utils/getx_config/GlobalData.dart';

class MineLogic extends GetxController {
  final _userApi = UserApi();
  final _adminApi = AdminApi();

  late dynamic currentUserInfo = {};

  Future<void> init() async {
    await _onGetCurrentUserInfo(); //加载网络数据后再次刷新
    update([const Key("mine")]);
  }

  //获取用户信息
  Future<void> _onGetCurrentUserInfo() async {
    //先用本地数据填充
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserInfo['name'] = prefs.getString('username') ?? '';
    currentUserInfo['portrait'] = prefs.getString('portrait') ?? '';
    currentUserInfo['account'] = prefs.getString('account') ?? '';
    currentUserInfo['sex'] = prefs.getString('sex') ?? '';
    update([const Key("mine")]);

    //加载网路
    final userInfo = await _userApi.info();
    final data = userInfo['data'];

    //优先用网络的，如果失败就继续用本地的
    currentUserInfo['name'] = data['name'] ?? prefs.getString('username');
    currentUserInfo['portrait'] = data['portrait'] ?? prefs.getString('portrait');
    currentUserInfo['account'] = data['account'] ?? prefs.getString('account');
    currentUserInfo['sex'] = data['sex'] ?? prefs.getString('sex');

    //保存用户信息
    prefs.setString('username', currentUserInfo['name'] ?? '');
    prefs.setString('account', currentUserInfo['account']?? '');
    prefs.setString('portrait', currentUserInfo['portrait']?? '');
    prefs.setString('sex', currentUserInfo['sex']?? '');
  }

  void handlerLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseIp = prefs.getString('baseIp')?.trim() ?? '';
    await prefs.clear();
    prefs.setString("baseIp", baseIp);
    Get.find<GlobalData>().reset();
    Get.offAndToNamed('/login');
  }

  //上传背景图片
  Future<void> uploadChatBackground(File picture) async {
    Map<String, dynamic> map = {};
    final file = await MultipartFile.fromFile(picture.path,
        filename: picture.path.split('/').last);
    final ext = picture.path.split('.').last.toLowerCase();
    map['type'] = {'png': 'image/png', 'webp': 'image/webp', 'gif': 'image/gif'}[ext] ?? 'image/jpeg';
    map['name'] = picture.path.split('/').last;
    map['size'] = picture.lengthSync();
    map["file"] = file;
    FormData formData = FormData.fromMap(map);

    final result = await _userApi.uploadChatBackground(formData);

    if (result['code'] == 0) {
      CustomFlutterToast.showSuccessToast('背景图片设置成功');
      Get.find<GlobalData>().chatBgUrl = result['data'];
    } else {
      CustomFlutterToast.showErrorToast(result['msg'] ?? '设置失败');
    }
  }

  //前往管理员页面
  void toAdmin() {
    _adminApi.isAdmin().then((res) {
      if (res['code'] == 0) {
        Get.toNamed('/admin');
      }else{
        CustomFlutterToast.showErrorToast('你不是管理员~');
      }
    });
  }

  //前往系统通知页面
  void toSystemNotify() {
    _adminApi.isAdmin().then((res) {
      if (res['code'] == 0) {
        Get.toNamed('/system_notify', arguments: {
          'isAdmin': true,
        });
      }else{
        Get.toNamed('/system_notify', arguments: {
          'isAdmin': false,
        });
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }
}
