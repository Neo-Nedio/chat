import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../api/notify_api.dart';

class SystemNotifyLogic extends GetxController {
  final _notifyApi = NotifyApi();
  late List<dynamic> systemNotifyList = [];
  final Map<String, String> _urlCache = {};

  @override
  void onInit() {
    super.onInit();
    onGetSystemNotify();
  }


  Future<String> getImgUrl(String fileName) async {
    final key = fileName.trim();
    if (key.isEmpty) return '';
    if (_urlCache.containsKey(key)) {
      return _urlCache[key]!;
    }
    final res = await _notifyApi.getImgUrl(key);
    if (res['code'] == 0 && res['data'] != null) {
      final url = res['data'].toString().trim();
      if (url.isNotEmpty) {
        _urlCache[key] = url;
        return url;
      }
    }
    return '';
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
