import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/user_api.dart';
import '../app_badger.dart';

//全局数据管理类
class GlobalData extends GetxController {
  final _userApi = UserApi();
  var unread = <String, int>{}.obs; // 未读数据
  var currentUserId = '';

  Future<void> init() async {
    await onGetUserUnreadInfo(); // 异步获取未读数据
    SharedPreferences.getInstance().then((prefs) {
      currentUserId = prefs.getString('userId') ?? '';
    });
  }

  // 获取未读信息
  Future<void> onGetUserUnreadInfo() async {
    final result = await _userApi.unread();
    if (result['code'] == 0) {
      // 更新响应式 Map（会触发 UI 更新）
      unread.assignAll(Map<String, int>.from(result['data']));
      // 更新桌面角标
      AppBadger.setCount(
          getUnreadCount('chat'),  // 聊天未读数
          getUnreadCount('notify')); // 通知未读数
    }
  }

  //获取未读数量
  int getUnreadCount(String type) {
    if (unread.containsKey(type)) {
      return unread[type]!;
    }
    return 0;
  }
}
