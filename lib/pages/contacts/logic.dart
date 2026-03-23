import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/get_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/chat_group_api.dart';
import '../../api/friend_api.dart';
import '../../api/notify_api.dart';
import '../../utils/getx_config/GlobalThemeConfig.dart';

class ContactsLogic extends GetxController {
  final _friendApi = FriendApi();
  final _chatGroupApi = ChatGroupApi();
  final _notifyApi = NotifyApi();
  //主题配置
  final GlobalThemeConfig _theme = GetInstance().find<GlobalThemeConfig>();

  List<String> tabs = ['我的群聊', '我的好友', '好友通知']; // 标签页

  int selectedIndex = 1;        // 当前选中的标签索引（默认选中"我的好友"）
  String currentUserId = '';   //获取当前用户id
  List<dynamic> friendList = []; // 好友列表数据（按分组）
  List<dynamic> chatGroupList = [];
  List<dynamic> notifyFriendList = [];

  void init() {
    SharedPreferences.getInstance().then((prefs) {
      currentUserId = prefs.getString('userId') ?? '';
      update([const Key("contacts")]);
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
        update([const Key("contacts")]);
      }
    });
  }

  //群列表
  void onChatGroupList() {
    _chatGroupApi.list().then((res) {
      if (res['code'] == 0) {
        chatGroupList = res['data'];
        update([const Key("contacts")]);
      }
    });
  }

  //好友通知
  void onNotifyFriendList() {
    _notifyApi.friendList().then((res) {
      if (res['code'] == 0) {
        notifyFriendList = res['data'];
        update([const Key("contacts")]);
      }
    });
  }

  // 标签切换
  void handlerTabTapped(int index) {
    selectedIndex = index;
    update([const Key("contacts")]);
  }

  //打开好友详情(打开前先获取所有的分组)
  void handlerFriendTapped(dynamic friend) {
    List<Map<String, dynamic>> groupList = [];

    //遍历好友列表，过滤出可用的分组
    //friendList是好友分组列表，其下的Friend才是好友
    for (var item in friendList) {
      if (item['name'] == "特别关心" || item['name'] == "未分组"|| item['groupId'] == null) {
        continue;
      }
      //分组名称和标签
      groupList.add({'label': item['name'], 'value': item['groupId']});
    }

    //
    Get.toNamed('/friend_info',
        arguments: {'friend': friend, 'groupList': groupList});
  }

  //同意添加好友
  void handlerAgreeFriend(String notifyId) async {
    final result = await _friendApi.agree(notifyId);
    if (result['code'] == 0) {
      init();
      Fluttertoast.showToast(
          msg: "同意好友请求成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: _theme.primaryColor,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "同意好友请求失败",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
