import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../api/user_api.dart';
import '../app_badger.dart';

//全局数据管理类，用于管理用户的未读消息数量，并更新桌面角标。
class GlobalData extends GetxController {
  final _userApi = UserApi();
  late Map<String, dynamic> unread; // 未读数据，延迟初始化

  void init() {
    _onGetUserUnreadInfo();
  }

  // 获取未读信息
  void _onGetUserUnreadInfo() async {
    final result = await _userApi.unread();
    if (result['code'] == 0) {
      unread = result['data'];
      AppBadger.setCount(
          getUnreadCount('chat'),  // 聊天未读数
          getUnreadCount('notify')); // 通知未读数

      update(); // 通知 UI 更新
    }
  }

  //获取未读数量
  int getUnreadCount(String type) {
    if (unread.containsKey(type)) {
      return unread[type];
    }
    return 0;
  }
}
