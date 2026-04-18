import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/get_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/chat_group_api.dart';
import '../../api/chat_list_api.dart';
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
  final _chatListApi = ChatListApi();
  //主题配置
  final GlobalThemeConfig _theme = GetInstance().find<GlobalThemeConfig>();

  final GlobalData _globalData = GetInstance().find<GlobalData>();

  List<String> tabs = ['我的群聊', '我的好友', '通知']; // 标签页

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
    globalData.onGetUserUnreadInfo();
    _chatGroupApi.list().then((res) {
      if (res['code'] == 0) {
        chatGroupList = res['data'];
        update([const Key("contacts")]);
      }
    });
  }

  //通知
  void onNotifyFriendList() {
    _notifyApi.list().then((res) {
      if (res['code'] == 0) {
        final data = res['data'];
        notifyFriendList = data is List ? data : <dynamic>[];
        update([const Key("contacts")]);
      }
    });
  }

  //消息已读
  // type: 'friend' 好友申请通知 / 'group' 群申请通知
  Future<void> onReadNotify() async {
    await _notifyApi.read('friend');
    await _notifyApi.read('group');
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
    final result = await _friendApi.reject(notify['fromId']);
    if (result['code'] == 0) {
      init();
      CustomFlutterToast.showSuccessToast("操作成功");
    } else {
      CustomFlutterToast.showErrorToast("网络错误");
    }
  }

  //长按分组进入分组设置页面
  void onLongPressGroup(){
    //均为0代表保护值，此时并不是从好友详情页面进入的
    Get.toNamed("/set_group",arguments: {
      'groupName':'0',
      'friendId':'0'
    });

  }

  //设置特别关心
  void onSetConcernFriend(dynamic friend) async{
    if(friend['isConcern']){
      final response = await _friendApi.unCareFor(friend['friendId']);
      setResult(response);
    }else {
      final response = await _friendApi.careFor(friend['friendId']);
      setResult(response);
    }
    Get.back();
    init();
  }

  //特别关心结果
  void setResult(Map<String, dynamic> response) {
    if (response['code'] == 0) {
      CustomFlutterToast.showSuccessToast('设置成功~');
    } else {
      CustomFlutterToast.showErrorToast(response['msg']);
    }
  }

  //前往会话页
  void onToSendGroupMsg(id) {
    _chatListApi.create(id, 'group').then((res) {
      if (res['code'] == 0) {
        Get.toNamed('/chat_frame', arguments: {
          'chatInfo': res['data'],
        });
      }
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
