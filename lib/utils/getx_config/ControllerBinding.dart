//依赖注入(这样不用每个页面都要寻找自己的控制器)
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../pages/add_friend/friend_info/logic.dart';
import '../../pages/add_friend/friend_request/logic.dart';
import '../../pages/add_friend/logic.dart';
import '../../pages/chat_list/logic.dart';
import '../../pages/contacts/chat_group_information/chat_group_notice/add_chat_group_notice/logic.dart';
import '../../pages/contacts/chat_group_information/chat_group_notice/logic.dart';
import '../../pages/contacts/chat_group_information/logic.dart';
import '../../pages/contacts/chat_group_information/set_group_name/logic.dart';
import '../../pages/contacts/chat_group_information/set_group_nickname/logic.dart';
import '../../pages/contacts/chat_group_information/set_group_remark/logic.dart';
import '../../pages/contacts/friend_information/logic.dart';
import '../../pages/contacts/friend_information/set_group/logic.dart';
import '../../pages/contacts/friend_information/set_remark/logic.dart';
import '../../pages/contacts/logic.dart';
import '../../pages/contacts/user_select/logic.dart';
import '../../pages/image_viewer/image_viewer_update/logic.dart';
import '../../pages/image_viewer/logic.dart';
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
import '../../pages/talk/talk_create/logic.dart';
import '../../pages/talk/talk_details/logic.dart';
import 'GlobalData.dart';
import 'GlobalThemeConfig.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GlobalThemeConfig(), permanent: true);
    Get.put(GlobalData(), permanent: true);
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
    Get.lazyPut(() => SetRemarkLogic());
    Get.lazyPut(() => SetGroupLogic());
    Get.lazyPut(() => AddFriendLogic());
    Get.lazyPut(() => SearchInfoLogic());
    Get.lazyPut(() => FriendRequestLogic());
    Get.lazyPut(() => TalkDetailsLogic());
    Get.lazyPut(() => TalkCreateLogic());
    Get.lazyPut(() => UserSelectLogic());
    Get.lazyPut(() => ChatGroupInformationLogic());
    Get.lazyPut(() => ImageViewerLogic());
    Get.lazyPut(() => ImageViewerUpdateLogic());
    Get.lazyPut(() => SetGroupNameLogic());
    Get.lazyPut(() => SetGroupRemarkLogic());
    Get.lazyPut(() => SetGroupNameNickLogic());
    Get.lazyPut(() => ChatGroupNoticeLogic());
    Get.lazyPut(() => AddChatGroupNoticeLogic());
  }
}