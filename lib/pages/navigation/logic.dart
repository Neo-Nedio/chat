import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../utils/getx_config/GlobalThemeConfig.dart';

class NavigationLogic extends GetxController {
  late int currentIndex = 0;

  @override
  void onInit() {
    super.onInit();
    //Get.parameters（URL 参数）
    String sex = Get.parameters['sex'] ?? "男"; // 获取路由参数
    final theme = Get.find<GlobalThemeConfig>(); // 获取主题配置实例
    theme.changeThemeMode(sex == "女" ? 'pink' : 'blue'); // 根据性别设置主题
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
