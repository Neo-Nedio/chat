import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../api/chat_list_api.dart';
import '../../api/msg_api.dart';
import '../../utils/String.dart';
import '../../utils/web_socket.dart';

class ChatFrameLogic extends GetxController {
  final _msgApi = MsgApi();           // 消息 API
  final _chatListApi = ChatListApi(); // 聊天列表 API
  final _wsManager = WebSocketUtil(); // WebSocket 管理

  final TextEditingController msgContentController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late List<dynamic> msgList = [];     // 消息列表
  late String targetId = '';           // 聊天对象ID
  late dynamic chatInfo = {};          // 聊天信息（对方头像、名称等）
  late RxBool isSend = false.obs;      // 是否有内容可发送

  // 分页相关
  int num = 20;      // 每页数量
  int index = 0;     // 当前索引（不是页数，而是起始位置）
  bool isLoading = false;  // 是否加载中
  bool hasMore = true;     // 是否有更多消息

  @override
  void onInit() {
    chatInfo = Get.arguments['chatInfo'] ?? '';
    targetId = chatInfo['fromId'];
    super.onInit();
    onGetMsgRecode();      // 获取消息记录
    eventListen();         // 监听 WebSocket 消息
    onRead();              // 标记已读

    // 添加滚动监听
    scrollController.addListener(() {
      //确保 ScrollController 已经附加到 ListView 上，可以安全调用滚动方法。
      if (scrollController.hasClients) {
        if (scrollController.position.pixels ==
            scrollController.position.minScrollExtent) { //监听上滑
          loadMore();
        }
      }
    });
  }

  //消息监听
  void eventListen() {
    // 监听消息
    _wsManager.eventStream.listen((event) {
      if (event['type'] == 'on-receive-msg') {
        if (event['content']['fromId'] == targetId) {
          msgListAddMsg(event['content']); // 收到新消息，添加到列表
        }
      }
    });
  }

  //获取历史消息
  Future<void> onGetMsgRecode() async {
    //正在加载
    isLoading = true;

    update([const Key('chat_frame')]);

    try {
      final res = await _msgApi.record(targetId, index, num);
      if (res['code'] == 0) {
        msgList = res['data'];
        index += msgList.length;
        hasMore = res['data'].length >= 0;
        update([const Key('chat_frame')]);
        // UI 渲染完成后执行
        SchedulerBinding.instance.addPostFrameCallback((_) {
          scrollBottom(); //滚动到底部
        });
      }
    } finally {
      //关闭加载
      isLoading = false;
      update([const Key('chat_frame')]);
    }
  }

  //加载更多消息（上拉加载）
  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    update([const Key('chat_frame')]);

    try {
      final res = await _msgApi.record(targetId, index, num);

      if (res['code'] == 0) {
        if (res['data'].isEmpty) {
          hasMore = false;
        } else {
          // 保存当前滚动位置
          final double previousScrollOffset = scrollController.position.pixels;
          final double previousMaxScrollExtent =
              scrollController.position.maxScrollExtent; //总滚动高度（可滚动的最大距离）

          // 在列表头部插入旧消息
          msgList.insertAll(0, res['data']);  // 在列表头部插入
          index = msgList.length;              // 更新总消息数
          hasMore = res['data'].length >= 0;   // 判断是否还有更多

          // 保持滚动位置
          // UI 渲染完成后执行
          SchedulerBinding.instance.addPostFrameCallback((_) {
            //获取加载后的新总高度
            final double newMaxScrollExtent =
                scrollController.position.maxScrollExtent;
            //计算新的滚动位置（原来的位置 加上 新增的内容高度）
            final double newOffset = previousScrollOffset +
                (newMaxScrollExtent - previousMaxScrollExtent);
            scrollController.animateTo(
              newOffset,
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
            );
          });
        }
      }
    } finally {
      //关闭加载
      isLoading = false;
      update([const Key('chat_frame')]);
    }
  }

  //将聊天列表滚动到底部，显示最新的消息
  void scrollBottom() {
    //确保 ScrollController 已经附加到 ListView 上，可以安全调用滚动方法。
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,  // 滚动到底部
        duration: const Duration(milliseconds: 500), // 动画时长 500ms
        curve: Curves.fastOutSlowIn,                 // 动画曲线
      );
    }
  }

  //根据聊天类型，跳转到对应的详情页面
  void toDetailsPage() {
    if (chatInfo['type'] == 'group') {
      Get.toNamed('/chat_group_info', arguments: {'chatGroupId': targetId});
    } else {
      Get.toNamed('/friend_info', arguments: {'friendId': targetId});
    }
  }

  //发送文本消息
  void sendTextMsg() async {
    if (StringUtil.isNullOrEmpty(msgContentController.text)) return;
    dynamic msg = {
      'toUserId': targetId,
      'source': chatInfo['type'], // 'friend' 或 'group'
      'msgContent': {'type': "text", 'content': msgContentController.text}
    };

    _msgApi.send(msg).then((res) {
      if (res['code'] == 0) {
        msgContentController.text = '';  // 清空输入框
        msgListAddMsg(res['data']);      // 添加消息到列表
        onRead();                        // 标记已读
      }
    });
  }

  //将新消息添加到消息列表
  void msgListAddMsg(msg) {
    msgList.add(msg);                              // 1. 添加消息到列表末尾
    index = msgList.length;                        // 2. 更新索引（消息总数）
    update([const Key('chat_frame')]);             // 3. 刷新 UI
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollBottom();                              // 4. 滚动到底部
    });
  }

  void onRead() {
    _chatListApi.read(targetId);
  }

  @override
  void onClose() {
    super.onClose();
    msgContentController.dispose();
    scrollController.dispose();
  }
}
