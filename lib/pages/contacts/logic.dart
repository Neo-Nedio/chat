import 'dart:async';

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
import '../../components/custom_flutter_toast/index.dart';
import '../../utils/getx_config/GlobalData.dart';
import '../../utils/getx_config/GlobalThemeConfig.dart';
import '../../utils/web_socket.dart';

class ContactsLogic extends GetxController {
  final _friendApi = FriendApi();
  final _chatGroupApi = ChatGroupApi();
  final _notifyApi = NotifyApi();
  //主题配置
  final GlobalThemeConfig _theme = GetInstance().find<GlobalThemeConfig>();

  final GlobalData _globalData = GetInstance().find<GlobalData>();

  List<String> tabs = ['我的群聊', '我的好友', '好友通知']; // 标签页

  int selectedIndex = 1;        // 当前选中的标签索引（默认选中"我的好友"）
  String currentUserId = '';   //获取当前用户id
  List<dynamic> friendList = []; // 好友列表数据（按分组）
  List<dynamic> chatGroupList = [];
  List<dynamic> notifyFriendList = [];

  final _wsManager = WebSocketUtil();
  StreamSubscription? _subscription;

  GlobalData get globalData => GetInstance().find<GlobalData>();

  @override
  void onInit() {
    super.onInit();
    eventListen();
  }

  void eventListen() {
    // 监听消息
    _subscription = _wsManager.eventStream.listen((event) {
      if (event['type'] == 'on-receive-notify') {
        init(); //接受到通知时刷新页面
      }
    });
  }

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

  //消息已读
  void onReadNotify() async {
    await _notifyApi.read('friend'); //消息已读
    await _globalData.onGetUserUnreadInfo();
  }

  // 标签切换
  void handlerTabTapped(int index) {
    selectedIndex = index;
    update([const Key("contacts")]);
    if (index == 2) {
      onReadNotify(); //切换到好友通知时，把消息已读
    }
  }

  //打开好友详情
  void handlerFriendTapped(dynamic friend) {
    Get.toNamed('/friend_info', arguments: {'friendId': friend['friendId']});
  }

  //同意添加好友
  void handlerAgreeFriend(dynamic notify) async {
    onReadNotify(); //消息已读
    final result = await _friendApi.agree(notify['id'], notify['fromId']);
    if (result['code'] == 0) {
      init();
      CustomFlutterToast.showSuccessToast("同意好友请求成功");
    } else {
      CustomFlutterToast.showErrorToast("同意好友请求失败");
    }
  }

  //拒绝添加好友
  void handlerRejectFriend(dynamic notify) async {
    onReadNotify(); //消息已读
    final result = await _friendApi.reject(notify['fromId']);
    if (result['code'] == 0) {
      init();
      CustomFlutterToast.showSuccessToast("操作成功");
    } else {
      CustomFlutterToast.showErrorToast("网络错误");
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
