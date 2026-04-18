import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/user_api.dart';
import '../app_badger.dart';

//全局数据管理类
class GlobalData extends GetxController {
  final _userApi = UserApi();
  // 未读数据，可能包含的 key：
  //   chat         - 聊天消息未读数
  //   notify       - 通知未读总数（friendNotify + groupNotify + systemNotify）
  //   friendNotify - 好友申请未读数
  //   groupNotify  - 群申请未读数
  //   systemNotify - 系统通知未读数
  var unread = <String, int>{
    'chat': 0,
    'notify': 0,
    'friendNotify': 0,
    'groupNotify': 0,
    'systemNotify': 0,
  }.obs;
  var currentUserId = '';
  var currentUserAccount = '';
  var baseIp = '';
  String? chatBgUrl;

  Future<void> init() async {
    await onGetUserUnreadInfo(); // 异步获取未读数据
    SharedPreferences.getInstance().then((prefs) {
      currentUserId = prefs.getString('userId') ?? '';
      currentUserAccount = prefs.getString('account') ?? '';
      baseIp = prefs.getString('baseIp') ?? '';
    });
    _fetchChatBgUrl();
  }

  //退出登录时清空不该有的数据
  void reset() {
    chatBgUrl = null;
    currentUserId = '';
    currentUserAccount = '';
    // 把所有未读项重置为 0，同时清空桌面角标
    unread.updateAll((key, value) => 0);
    AppBadger.setCount(0, 0);
  }

  //获取聊天背景url
  Future<void> _fetchChatBgUrl() async {
    if (chatBgUrl != null) return;
    try {
      final res = await _userApi.getChatBackground();
      if (res['code'] == 0) {
        chatBgUrl = res['data'];
      }
    } catch (_) {}
  }

  // 获取未读信息
  Future<void> onGetUserUnreadInfo() async {
    final result = await _userApi.unread();
    if (result['code'] == 0) {
      // 用后端返回的数据覆盖对应 key，
      // 未返回的 key 保留默认 0，避免 UI 取值异常。
      final data = Map<String, dynamic>.from(result['data'] ?? {});
      data.forEach((key, value) {
        unread[key] = (value as num?)?.toInt() ?? 0;
      });
      unread.refresh();
      // 更新桌面角标（notify 已经是包含 friend/group/system 的总和）
      AppBadger.setCount(
          getUnreadCount('chat'),    // 聊天未读数
          getUnreadCount('notify')); // 通知未读总数
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
