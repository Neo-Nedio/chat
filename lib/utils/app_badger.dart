import 'package:app_badge_plus/app_badge_plus.dart';

//桌面角标管理工具类，负责将未读消息数量显示在应用图标上（应用图上的红点）。
class AppBadger {
  static int _chatCount = 0;
  static int _notifyCount = 0;

  // 同时设置聊天和通知未读数
  static void setCount(int chatCount, int notifyCount) {
    _chatCount = chatCount;
    _notifyCount = notifyCount;
    _updateBadgeCount();
  }

  // 只设置聊天未读数
  static void setChatCount(int count) {
    _chatCount = count;
    _updateBadgeCount();
  }

  // 只设置通知未读数
  static void setNotifyCount(int count) {
    _notifyCount = count;
    _updateBadgeCount();
  }

  //更新角标
  static void _updateBadgeCount() async {
    // 1. 检查设备是否支持角标
    if (await AppBadgePlus.isSupported()) {

      // 2. 计算总未读数
      int total = _chatCount + _notifyCount;

      // 3. 根据总数决定显示什么
      if (total > 0) {
        // 有未读：显示总数量
        await AppBadgePlus.updateBadge(total);
      } else {
        // 无未读：清零
        _notifyCount = 0;
        _chatCount = 0;
        await AppBadgePlus.updateBadge(0);
      }
    }
  }
}
