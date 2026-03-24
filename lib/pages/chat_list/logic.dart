import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../api/chat_list_api.dart';
import '../../api/friend_api.dart';
import '../../utils/web_socket.dart';

class ChatListLogic extends GetxController {
  final _chatListApi = ChatListApi();
  final _friendApi = FriendApi();
  late List<dynamic> topList = [];     // 置顶聊天列表
  late List<dynamic> otherList = [];   // 其他聊天列表
  late List<dynamic> searchList = [];  // 搜索结果列表

  final _wsManager = WebSocketUtil();        // 获取 WebSocket 单例
  StreamSubscription? _subscription;         // 订阅对象，用于取消监听

  @override
  void onInit() {
    super.onInit();
    eventListen();  // 页面初始化时开始监听
  }

  void eventListen() {
    // 监听 WebSocket 事件流
    _subscription = _wsManager.eventStream.listen((event) {
      // 判断消息类型：是否是收到的聊天消息
      if (event['type'] == 'on-receive-msg') {
        onGetChatList();                     // 刷新聊天列表
      }
    });
  }

  void onGetChatList() {
    //获取列表
    _chatListApi.list().then((res) {
      if (res['code'] == 0) {
        topList = res['data']['tops'];
        otherList = res['data']['others'];
        update([const Key("chat_list")]);
      }
    });
  }

  void onTopStatus(String id, bool isTop) {
    // 传入相反的状态更新指定状态
    _chatListApi.top(id, !isTop).then((res) {
      if (res['code'] == 0) {
        onGetChatList(); // 重新获取最新列表
      }
    });
  }

  void onDeleteChatList(String id) {
    _chatListApi.delete(id).then((res) {
      if (res['code'] == 0) {
        onGetChatList(); // 重新获取最新列表
      }
    });
  }

  void onSearchFriend(String friendInfo) {
    if (friendInfo.trim() == '') { // 搜索框为空
      searchList = [];  // 清空搜索结果
      update([const Key("chat_list")]);
      return;
    }
    //获取搜索结果
    _friendApi.search(friendInfo).then((res) {
      if (res['code'] == 0) {
        searchList = res['data'];
      update([const Key("chat_list")]);
      }
    });
  }
}
