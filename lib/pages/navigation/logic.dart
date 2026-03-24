import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/getx_config/GlobalData.dart';
import '../../utils/getx_config/GlobalThemeConfig.dart';
import '../../utils/notification.dart';
import '../../utils/permission_handler.dart';
import '../../utils/web_socket.dart';

class NavigationLogic extends GetxController {
  late int currentIndex = 0;
  final _wsManager = WebSocketUtil();

  GlobalData get globalData => GetInstance().find<GlobalData>();

  void initData(){
    //Get.parameters（URL 参数）
    String sex = Get.parameters['sex'] ?? "男"; // 获取路由参数
    final theme = Get.find<GlobalThemeConfig>(); // 获取主题配置实例
    theme.changeThemeMode(sex == "女" ? 'pink' : 'blue'); // 根据性别设置主题
  }

  @override
  void onInit() {
    super.onInit();
    initData();

    //立即执行
    (() async {
      await globalData.init(); //  初始化全局数据
      await NotificationUtil.initialize();           // 1. 初始化通知服务
      await NotificationUtil.createNotificationChannel(); // 2. 创建通知渠道
      await PermissionHandler.permissionRequest();   // 3. 请求通知权限
      await connectWebSocket(); //建立 WebSocket 连接
      eventListen(); //进行监听
    })();
  }

  // 监听消息(收到任何消息，立马刷新)
  void eventListen() {
    _wsManager.eventStream.listen((event) {
      globalData.onGetUserUnreadInfo();
    });
  }

  Future<void> connectWebSocket() async {
    // 建立 WebSocket 连接
    _wsManager.connect();
  }

  final List<String> selectedIcons = [
    'chat',
    'user',
    'talk',
    'mine',
  ];

  final List<String> unselectedIcons = [
    'assets/images/chat-empty.png',
    'assets/images/user-empty.png',
    'assets/images/talk-empty.png',
    'assets/images/mine-empty.png',
  ];

  final List<String> name = [
    '消息',
    '通讯',
    '说说',
    '我的',
  ];

  void onTap(int index) {
    currentIndex = index;
    update([const Key("main")]);
  }
}
