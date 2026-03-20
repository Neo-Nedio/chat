import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/chat_group_api.dart';
import '../../api/friend_api.dart';
import '../../api/notify_api.dart';

class ContactsLogic extends GetxController {
  final _friendApi = FriendApi();
  final _chatGroupApi = ChatGroupApi();
  final _notifyApi = NotifyApi();

  List<String> tabs = ['我的群聊', '我的好友', '好友通知']; // 标签页

  int selectedIndex = 1;        // 当前选中的标签索引（默认选中"我的好友"）
  String currentUserId = '';   //获取当前用户id
  List<dynamic> friendList = []; // 好友列表数据（按分组）
  List<dynamic> chatGroupList = [];
  List<dynamic> notifyFriendList = [];

  void init() {
    SharedPreferences.getInstance().then((prefs) {
      currentUserId = prefs.getString('userId') ?? '';
      update();
    });
    //不要放在getContent里面，不然会无限刷新
    onNotifyFriendList();
    onChatGroupList();
    onFriendList();
  }

  // 更新好友列表
  void onFriendList() {
    _friendApi.list().then((res) {
      if (res['code'] == 0) {
        friendList = res['data'];
        update();
      }
    });
  }

  //群列表
  void onChatGroupList() {
    _chatGroupApi.list().then((res) {
      if (res['code'] == 0) {
        chatGroupList = res['data'];
        update();
      }
    });
  }

  //好友通知
  void onNotifyFriendList() {
    _notifyApi.friendList().then((res) {
      if (res['code'] == 0) {
        notifyFriendList = res['data'];
        update();
      }
    });
  }

  // 标签切换
  void handlerTabTapped(int index) {
    selectedIndex = index;
    update();
  }
}
