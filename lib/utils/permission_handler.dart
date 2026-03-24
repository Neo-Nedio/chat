import 'package:permission_handler/permission_handler.dart';

//权限管理工具类
class PermissionHandler {
  //权限申请入口
  static Future<void> permissionRequest() async {
    await requestNotificationPermission();//申请通知权限
  }

  //申请通知权限
  static Future<void> requestNotificationPermission() async {
    // 1. 获取当前通知权限状态
    var status = await Permission.notification.status;

    // 2. 如果权限被拒绝（未授权）
    if (status.isDenied) {
      // 3. 弹出系统权限请求弹窗
      await Permission.notification.request();
    }
  }
}
