//依赖注入(这样不用每个页面都要寻找自己的控制器)
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../pages/chat_list/logic.dart';
import '../../pages/contacts/friend_information/logic.dart';
import '../../pages/contacts/logic.dart';
import '../../pages/login/logic.dart';
import '../../pages/mine/about/logic.dart';
import '../../pages/mine/edit/logic.dart';
import '../../pages/mine/logic.dart';
import '../../pages/mine/mine_qr_code/logic.dart';
import '../../pages/navigation/logic.dart';
import '../../pages/password/retrieve/logic.dart';
import '../../pages/password/update/logic.dart';
import '../../pages/qr_code_scan/logic.dart';
import '../../pages/qr_code_scan/qr_friend_affirm/logic.dart';
import '../../pages/qr_code_scan/qr_login_affirm/logic.dart';
import '../../pages/qr_code_scan/qr_other_result/logic.dart';
import '../../pages/register/logic.dart';
import '../../pages/talk/logic.dart';
import 'GlobalThemeConfig.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GlobalThemeConfig(), permanent: true);
    // 懒加载方式创建控制器实例(没有创建实例，即Get.find之前不会初始化)
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
    Get.lazyPut(() => NavigationLogic());
    Get.lazyPut(() => EditMineLogic());
    Get.lazyPut(() => MineQRCodeLogic());
    Get.lazyPut(() => QrOtherResultLogic());
    Get.lazyPut(() => QRFriendAffirmLogic());
    Get.lazyPut(() => AboutLogic());
    Get.lazyPut(() => FriendInformationLogic());
  }
}