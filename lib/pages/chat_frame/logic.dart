import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_mobile/api/friend_api.dart';
import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/chat_group_api.dart';
import '../../api/chat_group_member.dart';
import '../../api/chat_list_api.dart';
import '../../api/msg_api.dart';
import '../../api/user_api.dart';
import '../../api/video_api.dart';
import '../../components/custom_flutter_toast/index.dart';
import '../../utils/String.dart';
import '../../utils/cropPicture.dart';
import '../../utils/extension.dart';
import '../../utils/getx_config/GlobalData.dart';
import '../../utils/getx_config/config.dart';
import '../../utils/web_socket.dart';
import 'index.dart';

class ChatFrameLogic extends Logic<ChatFramePage> {
  final _msgApi = MsgApi();           // 消息 API
  final _chatListApi = ChatListApi(); // 聊天列表 API
  final _userApi = UserApi();
  final _videoApi = VideoApi();
  final _friendApi = FriendApi();
  final _chatGroupApi = ChatGroupApi();
  final _chatGroupMemberApi = ChatGroupMemberApi();
  final _wsManager = WebSocketUtil(); // WebSocket 管理

  final TextEditingController msgContentController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode(skipTraversal: true); //按 Tab 键时跳过这个输入框，避免意外打开键盘
  final RxString panelType = "none".obs; //显示的面板

  late Map<String, dynamic> members = {}; //群成员
  late List<dynamic> msgList = [];     // 消息列表
  late String targetId = '';           // 聊天对象ID
  late dynamic chatInfo = {};          // 聊天信息（对方头像、名称等）
  String selfPortrait = '';
  late RxBool isRecording = false.obs; //录音状态
  late RxBool isSend = false.obs;      // 是否有内容可发送
  late RxBool isReadOnly = false.obs; //只读

  // 分页相关
  int num = 20;      // 每页数量
  int index = 0;     // 当前索引（不是页数，而是起始位置）
  bool isLoading = false;  // 是否加载中
  bool hasMore = true;     // 是否有更多消息
  StreamSubscription? _subscription;
  final GlobalData _globalData = Get.find<GlobalData>();

  @override
  void onInit() {
    chatInfo = Get.arguments?['chatInfo'] ?? {};
    targetId = chatInfo['fromId'] ?? '';
    super.onInit();
    _onGetMembers();
    _onGetMsgRecode();      // 获取消息记录
    _refreshAvatarsOnEnter();
    _eventListen();         // 监听 WebSocket 消息
    _onRead();              // 标记已读

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

  // 本人头像：先本地 prefs，没有再请求 info（chatInfo 仅用入口参数）
  Future<void> _refreshAvatarsOnEnter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString('portrait')?.trim();
      if (local != null && local.isNotEmpty) {
        selfPortrait = local;
      } else {
        final info = await _userApi.info();
        final data = info['code'] == 0 ? info['data'] : null;
        selfPortrait = data?['portrait']?.toString() ?? '';
      }
    } catch (_) {
      selfPortrait =
          (await SharedPreferences.getInstance()).getString('portrait') ?? '';
    }
    update([const Key('chat_frame')]);
  }

  //消息监听
  void _eventListen() {
    // 监听消息
    _subscription = _wsManager.eventStream.listen((event) {
      if (event['type'] == 'on-receive-msg') {
        final data = event['content'];
        if ((data['fromId'] == targetId && data['source'] == 'user') || //对方发来的单聊消息
            (data['toId'] == targetId && data['source'] == 'group') || //群聊消息
            (data['fromId'] == _globalData.currentUserId &&
                data['toId'] == targetId)) {
          if (data['msgContent']['type'] == 'retraction') {
            msgList = msgList.replace(newValue: data);
            _onRead();
            update([const Key('chat_frame')]);
            return;
          }
          _onRead();
          bool forceScrollToBottom = false;
          if (scrollController.hasClients) { //检查 ScrollController 是否已绑定到滚动组件（防止报错）
            final p = scrollController.position;
            const tolerance = 48.0;
            //p.extentAfter 当前可视区域下方还有多少内容未滚动（滚动到底部时为 0）
            forceScrollToBottom = p.extentAfter <= tolerance;
          }
          msgListAddMsg(event['content'], forceScrollToBottom: forceScrollToBottom);
        }
      }
    });
  }

  //获取成员
  void _onGetMembers() async {
    if (chatInfo['type'] == 'group') {
      await _chatGroupMemberApi.list(targetId).then((res) {
        if (res['code'] == 0) {
          members = res['data'];
          update([const Key('chat_frame')]);
        }
      });
    }
  }

  //获取历史消息
  Future<void> _onGetMsgRecode() async {
    //正在加载
    isLoading = true;

    update([const Key('chat_frame')]);

    try {
      final res = await _msgApi.record(targetId, index, num);
      if (res['code'] == 0) {
        msgList = res['data'];
        index += msgList.length;
        hasMore = msgList.isNotEmpty; // 判断是否还有更多数据
        scrollBottom(isAnimate: false); //滚动到底部
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            //获取加载后的新总高度
            final double newMaxScrollExtent =
                scrollController.position.maxScrollExtent;
            //计算新的滚动位置（原来的位置 加上 新增的内容高度）
            final double newOffset = previousScrollOffset +
                (newMaxScrollExtent - previousMaxScrollExtent);
            scrollController.jumpTo(
              newOffset,
              //duration: const Duration(milliseconds: 200),
              //curve: Curves.fastOutSlowIn,
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
  void scrollBottom({bool isAnimate = true}) {
    void jump() {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
    if (scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback( (_){
        if(isAnimate){
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,  // 滚动到底部
            duration: const Duration(milliseconds: 500), // 动画时长 500ms
            curve: Curves.fastOutSlowIn,                 // 动画曲线
          );
        }else{
          //需要两次滚到底部，maxScrollExtent在刚开始进入聊天时会变，要两次滚到底部
          jump();
          WidgetsBinding.instance.addPostFrameCallback((_) => jump());
        }
      });
    }
  }

  //根据聊天类型，跳转到对应的详情页面
  void toDetailsPage() {
    if (chatInfo['type'] == 'group') {
      //打开群聊详情
      handlerGroupTapped(targetId);
    } else {
      //前往用户详情
      handlerUserTapped(targetId);
    }
  }

  //打开群聊详情
  void handlerGroupTapped(dynamic toId) async{
    //跳转前先校验群聊是否存在（未解散）
    final res = await _chatGroupApi.isDissolveChatGroup(toId);
    if (res['code'] == 0) {
      CustomFlutterToast.showErrorToast('该群聊不存在或已解散');
      return;
    }
    Get.toNamed('/chat_group_info', arguments: {'chatGroupId': toId});
  }

  //打开对方用户详情
  void handlerUserTapped(dynamic toId) {
    final currentUserId = Get.find<GlobalData>().currentUserId;
    if(toId != currentUserId){
      _friendApi.isFriend(toId).then((res){
        if (res['code'] == 0) {
          if(res['data']){ //双方是好友
            Get.toNamed('/friend_info', arguments: {'friendId': toId});
          }else{//双方不是好友
            _userApi.getInfoById(toId).then((userRes){
              if (userRes['code'] == 0) {
                Get.toNamed('/search_info', arguments: {
                  'friendInfo': userRes['data'],
                  'isFriend': false,
                });
              } else {
                CustomFlutterToast.showErrorToast(userRes['msg'] ?? "获取用户信息失败");
              }
            });
          }
        }else{
          CustomFlutterToast.showErrorToast(res['msg'] ?? "打开详情失败");
        }
      });
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
        isSend.value =false ;//消息发送后改为不可发送
        msgContentController.clear();  // 清空输入框
        msgListAddMsg(res['data'], forceScrollToBottom: true); // 添加消息到列表（到底部）
        _onRead();                        // 标记已读
      }else {
        CustomFlutterToast.showErrorToast(res['msg'] ?? '发送消息失败');
      }
    });
  }

  //将新消息添加到消息列表
  void msgListAddMsg(msg, {bool forceScrollToBottom = false}) {
    msgList.add(msg);                              // 1. 添加消息到列表末尾
    index = msgList.length;                        // 2. 更新索引（消息总数）
    update([const Key('chat_frame')]);             // 3. 刷新 UI
    if (forceScrollToBottom) { //判断是否到底部
      scrollBottom();
    }
  }

  //消息已读
  void _onRead() {
    _chatListApi.read(targetId);
    _globalData.onGetUserUnreadInfo();
  }

  //发起视频通话
  void onInviteVideoChat(isOnlyAudio) {
    _videoApi.invite(targetId, isOnlyAudio).then((res) {
      if (res['code'] == 0) {
        Get.toNamed('/video_chat', arguments: {
          'userId': targetId,
          'isSender': true,
          'isOnlyAudio': isOnlyAudio,
        });
      } else {
        CustomFlutterToast.showErrorToast(res['msg'] ?? '发起通话失败');
      }
    });
  }

  //选择图片/拍照
  Future cropChatBackgroundPicture(ImageSource? type) async =>
      cropPicture(type, onUploadImg, isVariable: true);

  //图片上传回调
  Future<void> onUploadImg(File file) async {
    onSendImgOrFileMsg(file, 'img');
  }

  //选择文件
  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path != null) {
      File file = File(path);
      onSendImgOrFileMsg(file, 'file'); // 发送文件
    }
  }

  //发送文件/图片
  void onSendImgOrFileMsg(File file, type) async {
    if (StringUtil.isNullOrEmpty(file.path)) {
      return; // 文件路径为空，不发送
    }

    // 1. 获取文件名
    String fileName = file.path.split('/').last;
    // 2. 创建 MultipartFile
    final fileData = await MultipartFile.fromFile(file.path, filename: fileName);

    // 3. 构建消息元数据
    dynamic msg = {
      'toUserId': targetId,
      'source': chatInfo['type'],
      'msgContent': {
        'type': type,
        'content': jsonEncode({
          'name': fileName,
          'size': fileData.length,
        })
      }
    };

    // 4. 发送元数据
    _msgApi.send(msg).then((res) {
      if (res['code'] == 0) {
        if (StringUtil.isNotNullOrEmpty(res['data']?['id'])) {
          // 5. 上传文件
          Map<String, dynamic> map = {};
          map["file"] = fileData;
          map['msgId'] = res['data']['id'];
          FormData formData = FormData.fromMap(map);
          _msgApi.sendMedia(formData).then((v) {
            msgListAddMsg(res['data'], forceScrollToBottom: true);
            _onRead();
          });
        }
      }else {
        CustomFlutterToast.showErrorToast(res['msg'] ?? '发起消息失败');
      }
    });
  }

  //发送语音消息
  void onSendVoiceMsg(filePath, time) async {
    if (StringUtil.isNullOrEmpty(filePath)) {
      return;  // 文件路径为空，不发送
    }
    if (time == 0) {
      CustomFlutterToast.showSuccessToast('录制时间太短~');
      return;  // 时长太短，提示用户
    }

    MultipartFile file = await MultipartFile.fromFile(filePath, filename: 'voice.wav');
    dynamic msg = {
      'toUserId': targetId,           // 接收者 ID
      'source': chatInfo['type'],     // 'user' 或 'group'
      'msgContent': {
        'type': "voice",              // 消息类型：语音
        'content': jsonEncode({       // 语音信息（JSON 字符串）
          'name': 'voice.wav',        // 文件名
          'size': file.length,        // 文件大小（字节）
          'time': time,               // 录音时长（秒）
        })
      }
    };
    _msgApi.send(msg).then((res) {
      if (res['code'] == 0) {
        if (StringUtil.isNotNullOrEmpty(res['data']?['id'])) {
          Map<String, dynamic> map = {};
          map["file"] = file;                    // 音频文件
          map['msgId'] = res['data']['id'];      // 消息 ID（关联）
          //得到消息id后再发送文件
          FormData formData = FormData.fromMap(map);
          _msgApi.sendMedia(formData).then((v) {
            msgListAddMsg(res['data'], forceScrollToBottom: true); // 添加到消息列表
            _onRead();                             // 标记已读
          });
        }
      }
    });
  }

  //点击通话消息记录
  void onTapMsg(dynamic msg) {
    widget?.hidePanel(); //收起所有面板

    final msgContent = msg['msgContent'] as Map<String, dynamic>;

    // 点击文本消息（暂不处理）
    if (msgContent['type'] == 'text') return;

    final Map<String, dynamic> content = jsonDecode(msgContent['content']);

    // 点击通话消息拨打给对方
    if (msgContent['type'] == 'call') {
      if (content['type'] == 'video') {
        onInviteVideoChat(false); // 视频通话
      } else {
        onInviteVideoChat(true); // 语音通话
      }
    }
  }

  //撤回消息
  void retractMsg(dynamic data, dynamic msg) async {
    if(DateTime.now().difference(DateTime.parse(msg['createTime'])).inMinutes > 3) {//大于三分钟不能撤回
      CustomFlutterToast.showErrorToast('大于三分钟不能撤回');
    }
    try {
      final result = await _msgApi.retract(msg['id'], targetId);
      if (result['code'] == 0) {
        // 替换原消息为撤回消息
        msgList = msgList.replace(oldValue: msg, newValue: result['data']);
        CustomFlutterToast.showSuccessToast('撤回成功');
      } else {
        CustomFlutterToast.showErrorToast(
            '撤回失败: ${result['message'] ?? '未知错误'}');
      }
    } catch (e) {
      CustomFlutterToast.showErrorToast('撤回失败');
    } finally {
      isLoading = false;
      update([const Key('chat_frame')]);
    }
  }

  // 重新编辑消息
  void reEditMsg(dynamic msg) async {
    final result = await _msgApi.reEdit(msg['id']);

    if (result['code'] == 0) {
      // 获取撤回的内容
      msgContentController.text = result['data']['msgContent']['content'];
      isSend.value = msgContentController.text.trim().isNotEmpty; // 控制发送按钮
      isRecording.value = false;
      // 弹出键盘
      WidgetsBinding.instance
          .addPostFrameCallback((_) => focusNode.requestFocus());
      update([const Key('chat_frame')]);
    }
  }

  void onTapVoice(dynamic msg) async {
    bool isGroup = chatInfo['type'] == 'group';

    try {
      final result = await _msgApi.voiceToText(msg['id'],isGroup);
      if (result['code'] == 0) {
        print(result['data']);
        // 替换原消息为转换成功的消息
        msgList = msgList.replace(oldValue: msg, newValue: result['data']);
        CustomFlutterToast.showSuccessToast('语音转文字成功');
      } else {
        CustomFlutterToast.showErrorToast(
            '语音转文字失败: ${result['message'] ?? '未知错误'}');
      }
    } catch (e) {
      CustomFlutterToast.showErrorToast('语音转文字失败');
    } finally {
      isLoading = false;
      update([const Key('chat_frame')]);
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
    msgContentController.dispose();
    scrollController.dispose();
    GlobalData globalData = GetInstance().find<GlobalData>();
    globalData.onGetUserUnreadInfo();
  }
}
