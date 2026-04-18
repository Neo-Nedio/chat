import 'package:app_badge_plus/app_badge_plus.dart';

//桌面角标管理工具类，负责将未读消息数量显示在应用图标上（应用图上的红点）。
class AppBadger {
  static int _chatCount = 0;
  static int _notifyCount = 0;

  // 同时设置聊天和通知未读数
  // 注意：notifyCount 是通知未读「总数」，已包含 friendNotify + groupNotify + systemNotify
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
    if (!await AppBadgePlus.isSupported()) return;

    // 2. 防止脏数据导致负数
    if (_chatCount < 0) _chatCount = 0;
    if (_notifyCount < 0) _notifyCount = 0;

    // 3. 计算总未读数（聊天 + 通知总数，通知里已包含 friend/group/system）
    final int total = _chatCount + _notifyCount;

    // 4. 更新角标（为 0 时即清零）
    await AppBadgePlus.updateBadge(total);
  }
}
