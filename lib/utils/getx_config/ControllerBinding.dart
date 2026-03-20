//依赖注入(这样不用每个页面都要寻找自己的控制器)
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../pages/chat_list/logic.dart';
import '../../pages/contacts/logic.dart';
import '../../pages/login/logic.dart';
import '../../pages/mine/logic.dart';
import '../../pages/password/retrieve/logic.dart';
import '../../pages/password/update/logic.dart';
import '../../pages/qr_code_scan/logic.dart';
import '../../pages/qr_login_affirm/logic.dart';
import '../../pages/register/logic.dart';
import '../../pages/talk/logic.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    // 懒加载方式创建控制器实例
    Get.lazyPut(() => LoginPageLogic());        // 登录页控制器
    Get.lazyPut(() => RegisterPageLogic());     // 注册页控制器
    Get.lazyPut(() => RetrievePasswordLogic()); // 找回密码控制器
    Get.lazyPut(() => UpdatePasswordLogic());   // 修改密码控制器
    Get.lazyPut(() => ChatListLogic());
    Get.lazyPut(() => ContactsLogic());
    Get.lazyPut(() => MineLogic());
    Get.lazyPut(() => TalkLogic());
    Get.lazyPut(() => QRCodeScanLogic());
    Get.lazyPut(() => QRLoginAffirmLogic());
  }
}