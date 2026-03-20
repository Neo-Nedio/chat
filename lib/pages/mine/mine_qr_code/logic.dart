import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/qr_api.dart';

class MineQRCodeLogic extends GetxController {
  final _qrApi = QrApi();
  late dynamic currentUserInfo = {};//用户信息
  late String qrCode = ''; //二维码内容

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserInfo['name'] = prefs.getString('username');
    currentUserInfo['portrait'] = prefs.getString('portrait');
    currentUserInfo['account'] = prefs.getString('account');
    update([const Key("mine_qr_code")]);
    onQrCode();
  }

  //获取二维码内容
  void onQrCode() {
    _qrApi.code().then((res) {
      if (res['code'] == 0) {
        qrCode = res['data'];
        update([const Key("mine_qr_code")]);
      }
    });
  }
}
