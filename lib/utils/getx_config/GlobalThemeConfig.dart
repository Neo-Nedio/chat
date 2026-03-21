import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class GlobalThemeConfig extends GetxController {
  late String themeMode = 'blue';

  void changeThemeMode(String mode) {
    themeMode = mode;
    update();
  }

  //主题色
  Color get primaryColor {
    switch (themeMode) {
      case 'blue':
        return const Color(0xFF4C9BFF);
      case 'pink':
        return const Color(0xFFFFA0CF);
      default:
        return const Color(0xFF4C9BFF);
    }
  }

  //字体色
  Color get boldColor {
    switch (themeMode) {
      case 'blue':
        return const Color(0xFF0060D9);  // 深蓝色
      case 'pink':
        return const Color(0xFFFF53A8);  // 亮粉色
      default:
        return const Color(0xFF0060D9);  // 默认深蓝色
    }
  }

  //次要颜色
  Color get minorColor {
    switch (themeMode) {
      case 'blue':
        return const Color(0xFFDFF4FF);
      case 'pink':
        return const Color(0xFFFBEBFF);
      default:
        return const Color(0xFFDFF4FF);
    }
  }

  //二维码颜色
  Color get qrColor {
    switch (themeMode) {
      case 'blue':
        return const Color(0xFFA0D9F6);
      case 'pink':
        return const Color(0xFFF5CFFF);
      default:
        return const Color(0xFFA0D9F6);
    }
  }

  //搜索框背景色
  Color get searchBarColor {
    switch (themeMode) {
      case 'blue':
        return const Color(0xFFE3ECFF);
      case 'pink':
        return const Color(0xFFFBEDFF);
      default:
        return const Color(0xFFE3ECFF);
    }
  }
}
