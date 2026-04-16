import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../api/notify_api.dart';

class SystemNotifyLogic extends GetxController {
  final _notifyApi = NotifyApi();
  late List<dynamic> systemNotifyList = [];
  late final isAdmin;

  @override
  void onInit() {
    super.onInit();
    onGetSystemNotify();
    isAdmin = Get.arguments['isAdmin'];
  }

  void onUpdate() {
    onGetSystemNotify();
    update([const Key('system_notify')]);
  }

  //加载系统通知
  void onGetSystemNotify() {
    _notifyApi.systemListNotify().then((res) {
      if (res['code'] == 0) {
        systemNotifyList = res['data'];
        update([const Key('system_notify')]);
      }
    });
  }
}
