//依赖注入(这样不用每个页面都要寻找自己的控制器)
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../pages/add_friend/friend_info/logic.dart';
import '../../pages/add_friend/friend_request/logic.dart';
import '../../pages/add_friend/logic.dart';
import '../../pages/chat_list/logic.dart';
import '../../pages/contacts/chat_group_information/chat_group_member/logic.dart';
import '../../pages/contacts/chat_group_information/chat_group_notice/add_chat_group_notice/logic.dart';
import '../../pages/contacts/chat_group_information/chat_group_notice/logic.dart';
import '../../pages/contacts/chat_group_information/logic.dart';
import '../../pages/contacts/chat_group_information/set_group_name/logic.dart';
import '../../pages/contacts/chat_group_information/set_group_nickname/logic.dart';
import '../../pages/contacts/chat_group_information/set_group_remark/logic.dart';
import '../../pages/contacts/create_chat_group/logic.dart';
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
    //fenix: true 是 GetX 中 lazyPut 的一个参数，意思是允许控制器在销毁后重新创建。
    Get.lazyPut(() => NavigationLogic(),fenix: true);
    Get.lazyPut(() => LoginPageLogic(),fenix: true);
    Get.lazyPut(() => RegisterPageLogic(),fenix: true);
    Get.lazyPut(() => RetrievePasswordLogic(),fenix: true);
    Get.lazyPut(() => UpdatePasswordLogic(),fenix: true);
    Get.lazyPut(() => ChatListLogic(),fenix: true);
    Get.lazyPut(() => ContactsLogic(),fenix: true);
    Get.lazyPut(() => MineLogic(),fenix: true);
    Get.lazyPut(() => TalkLogic(),fenix: true);
    Get.lazyPut(() => QRCodeScanLogic(),fenix: true);
    Get.lazyPut(() => QRLoginAffirmLogic(),fenix: true);
    Get.lazyPut(() => EditMineLogic(),fenix: true);
    Get.lazyPut(() => MineQRCodeLogic(),fenix: true);
    Get.lazyPut(() => QRFriendAffirmLogic(),fenix: true);
    Get.lazyPut(() => QrOtherResultLogic(),fenix: true);
    Get.lazyPut(() => AboutLogic(),fenix: true);
    Get.lazyPut(() => FriendInformationLogic(),fenix: true);
    Get.lazyPut(() => SetRemarkLogic(),fenix: true);
    Get.lazyPut(() => SetGroupLogic(),fenix: true);
    Get.lazyPut(() => AddFriendLogic(),fenix: true);
    Get.lazyPut(() => SearchInfoLogic(),fenix: true);
    Get.lazyPut(() => FriendRequestLogic(),fenix: true);
    Get.lazyPut(() => TalkDetailsLogic(),fenix: true);
    Get.lazyPut(() => TalkCreateLogic(),fenix: true);
    Get.lazyPut(() => UserSelectLogic(),fenix: true);
    Get.lazyPut(() => ChatGroupInformationLogic(),fenix: true);
    Get.lazyPut(() => ImageViewerLogic(),fenix: true);
    Get.lazyPut(() => ImageViewerUpdateLogic(),fenix: true);
    Get.lazyPut(() => SetGroupNameLogic(),fenix: true);
    Get.lazyPut(() => SetGroupRemarkLogic(),fenix: true);
    Get.lazyPut(() => SetGroupNameNickLogic(),fenix: true);
    Get.lazyPut(() => ChatGroupNoticeLogic(),fenix: true);
    Get.lazyPut(() => AddChatGroupNoticeLogic(),fenix: true);
    Get.lazyPut(() => ChatGroupMemberLogic(), fenix: true);
    Get.lazyPut(() => CreateChatGroupLogic(), fenix: true);
  }
}