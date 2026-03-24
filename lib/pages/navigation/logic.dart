import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/getx_config/GlobalThemeConfig.dart';
import '../../utils/web_socket.dart';

class NavigationLogic extends GetxController {
  late int currentIndex = 0;
  final _wsManager = WebSocketUtil();

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
    connectWebSocket(); //建立 WebSocket 连接
  }

  void connectWebSocket() async {
    // 从本地存储获取 token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-token');

    // 建立 WebSocket 连接
    _wsManager.connect(token!);
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
