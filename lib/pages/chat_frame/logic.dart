import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_mobile/api/friend_api.dart';
import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/chat_group_api.dart';
import '../../api/chat_group_member.dart';
import '../../api/chat_list_api.dart';
import '../../api/emoji_api.dart';
import '../../api/msg_api.dart';
import '../../api/notify_api.dart';
import '../../api/user_api.dart';
import '../../api/video_api.dart';
import '../../components/custom_button/index.dart';
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
  final _emojiApi = EmojiApi();
  final _imagePicker = ImagePicker(); // 自定义表情相册选图
  final _chatListApi = ChatListApi(); // 聊天列表 API
  final _userApi = UserApi();
  final _videoApi = VideoApi();
  final _friendApi = FriendApi();
  final _chatGroupApi = ChatGroupApi();
  final _chatGroupMemberApi = ChatGroupMemberApi();
  final _notifyApi = NotifyApi();
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
  bool isOwner = false;
  late RxBool isRecording = false.obs; //录音状态
  late RxBool isSend = false.obs;      // 是否有内容可发送
  late RxBool isReadOnly = false.obs; //只读

  // 表情面板：0 经典表情，1 自定义表情包
  final RxInt emojiPanelTab = 0.obs;
  List<dynamic> customEmojiList = [];
  bool customEmojiListLoading = false;
  bool _customEmojiUploading = false;
  final Map<String, String> _customEmojiFileUrlCache = {};

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
    _onGetGroup();        //获取群成员，公告，判断是否为群主
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

  //加载群聊信息
  void _onGetGroup() async{
    if (chatInfo['type'] != 'group') return;

    await _onGetMembers();

    // 获取群详情（包含公告）
    final res = await _chatGroupApi.details(targetId);
    if (res['code'] != 0) return;
    final chatGroup = res['data'];

    //设置完 isOwner 必须 update，否则已经渲染过的 ChatMessage
    //    不会重新生成 menuItems（禁言菜单就不会出现）
    // 因为刚开始渲染的ChatMessage时isOwner还没被赋值为true
    isOwner = _globalData.currentUserId == chatGroup['ownerUserId'];
    update([const Key('chat_frame')]);

    _checkGroupNotice(chatGroup); //先获得成员再检查公告，防止成员没加载出来发生错误
  }

  //获取成员并检查公告
  Future<void> _onGetMembers() async {
    final res = await _chatGroupMemberApi.list(targetId);
    if (res['code'] == 0) {
      members = res['data'];
      update([const Key('chat_frame')]);
    }
  }

  // 检查群公告通知
  void _checkGroupNotice(dynamic chatGroup) async {
    final me = members[_globalData.currentUserId];
    if (me == null) return;

    final notice = chatGroup['notice'];
    if (notice == null) return;

    final readTime = me['lastReadNoticeTime'];
    final createTime = notice['createTime'];

    // 从未读过 或 公告较新
    if (readTime == null || DateTime.parse(createTime).isAfter(DateTime.parse(readTime))) {
      _showNoticeDialog(notice['noticeContent'] ?? '');
    }
  }

  // 公告弹窗
  void _showNoticeDialog(String content) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(
                  child: Text(
                    '群公告',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: '查看所有',
                        type: 'minor',
                        height: 36,
                        onTap: () {
                          Navigator.pop(context);
                          _notifyApi.groupNotifyRead(targetId);
                          Get.toNamed('/chat_group_notice', arguments: {'chatGroupId': targetId, 'isOwner': false});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: '确定',
                        height: 36,
                        onTap: () {
                          Navigator.pop(context);
                          _notifyApi.groupNotifyRead(targetId);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  // 相册选图并上传为自定义表情
  Future<void> pickAndUploadCustomEmoji() async {
    if (_customEmojiUploading) {
      return;
    }
    _customEmojiUploading = true;
    try {
      // 1. 打开相册
      final x = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x == null) {
        return;
      }

      // 2. 校验文件
      final file = File(x.path);
      if (!file.existsSync()) {
        CustomFlutterToast.showErrorToast('文件不存在');
        return;
      }

      // 3. 文件名（与系统返回一致时优先用 x.name，否则从路径取）
      var name = x.name;
      if (name.isEmpty) {
        name = x.path.split(Platform.pathSeparator).last;
        if (name.isEmpty) {
          final p = x.path.replaceAll(r'\', '/');
          final idx = p.lastIndexOf('/');
          if (idx != -1 && idx < p.length - 1) {
            name = p.substring(idx + 1);
          }
        }
      }

      // 4. Content-Type
      var type = 'image/jpeg';
      if (x.mimeType != null && x.mimeType!.isNotEmpty) {
        type = x.mimeType!;
      } else {
        final lower = name.toLowerCase();
        if (lower.endsWith('.png')) {
          type = 'image/png';
        } else if (lower.endsWith('.gif')) {
          type = 'image/gif';
        } else if (lower.endsWith('.webp')) {
          type = 'image/webp';
        } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
          type = 'image/jpeg';
        }
      }

      // 5. 组表单上传
      final size = file.lengthSync();
      final multipart = await MultipartFile.fromFile(x.path, filename: name);
      final res = await _emojiApi.upload(
        FormData.fromMap({
          'name': name,
          'type': type,
          'size': size,
          'file': multipart,
        }),
      );
      if (res['code'] == 0) {
        // 6. 拉取最新表情列表
        final listRes = await _emojiApi.list();
        if (listRes['code'] == 0 && listRes['data'] != null) {
          customEmojiList = listRes['data'];
        } else {
          customEmojiList = [];
        }
        update([const Key('emoji_panel')]);
        CustomFlutterToast.showSuccessToast('已添加');
      } else {
        CustomFlutterToast.showErrorToast(res['msg'] ?? '上传失败');
      }
    } catch (_) {
      CustomFlutterToast.showErrorToast('上传失败');
    } finally {
      _customEmojiUploading = false;
    }
  }

  // 拉取当前用户的自定义表情
  Future<void> loadCustomEmojiList() async {
    if (customEmojiListLoading) {
      return;
    }
    customEmojiListLoading = true;
    update([const Key('emoji_panel')]);
    try {
      final res = await _emojiApi.list();
      if (res['code'] == 0 && res['data'] != null) {
        final data = res['data'];
        customEmojiList = data;
      } else {
        customEmojiList = [];
      }
    } catch (_) {
      customEmojiList = [];
    } finally {
      customEmojiListLoading = false;
      update([const Key('emoji_panel')]);
    }
  }

  // 根据 fileName 解析可展示的图片地址（有内存缓存，供表情面板用）
  Future<String> getCustomEmojiImageUrl(String fileName) async {
    if (fileName.isEmpty) {
      return '';
    }
    final hit = _customEmojiFileUrlCache[fileName];
    if (hit != null && hit.isNotEmpty) {
      return hit;
    }

    final u = await _loadCustomEmojiImageUrlOnce(fileName);
    if (u.isNotEmpty) {
      _customEmojiFileUrlCache[fileName] = u;
    }
    return u;
  }

  // 从接口取表情预览 URL
  Future<String> _loadCustomEmojiImageUrlOnce(String fileName) async {
    try {
      final res = await _emojiApi.getImage(fileName);
      if (res['code'] == 0 && res['data'] != null) {
        return res['data'].toString();
      }
    } catch (_) {}
    return '';
  }

  // 发送自定义表情消息：content 为存储中的文件名
  void sendEmojiMsg(String fileName) {
    if (StringUtil.isNullOrEmpty(fileName)) return;
    final msg = {
      'toUserId': targetId,
      'source': chatInfo['type'],
      'msgContent': {
        'type': 'emoji',
        'content': fileName,
      }
    };
    _msgApi.send(msg).then((res) {
      if (res['code'] == 0) {
        msgListAddMsg(res['data'], forceScrollToBottom: true); // 添加消息到列表（到底部）
        _onRead(); // 标记已读
      } else {
        CustomFlutterToast.showErrorToast(res['msg'] ?? '发送失败');
      }
    });
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
    if (msgContent['type'] == 'emoji') return;

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

  //禁言群成员回调（仅群主可调用，菜单已做权限过滤）
  Future<void> banMember(dynamic msg) async {
    final String memberId = msg['fromId']?.toString() ?? '';
    if (memberId.isEmpty) {
      CustomFlutterToast.showErrorToast('成员ID为空');
      return;
    }
    if (memberId == _globalData.currentUserId) {
      CustomFlutterToast.showErrorToast('不能禁言自己');
      return;
    }

    // 先查询当前禁言状态，便于在弹窗中提示
    bool currentlyBanned = false;
    try {
      final statusRes = await _chatGroupMemberApi.isBan(targetId, memberId);
      if (statusRes['code'] == 0) {
        currentlyBanned =  true;
      }
    } catch (_) {
      // 查询失败不影响后续禁言操作
    }

    // 取一下被操作成员显示名，用于弹窗标题
    final member = members[memberId];
    String displayName = '';
    if (member != null) {
      displayName = (member['groupName'] ??
              member['remark'] ??
              member['name'] )
          .toString();
    }

    // 时长选项：标题 + 秒数（0 = 解除禁言）
    final List<Map<String, dynamic>> options = [
      {'label': '1 分钟', 'duration': 60},
      {'label': '10 分钟', 'duration': 600},
      {'label': '1 小时', 'duration': 3600},
      {'label': '12 小时', 'duration': 43200},
      {'label': '1 天', 'duration': 86400},
      {'label': '7 天', 'duration': 604800},
    ];

    //禁言的底部弹窗
    await showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      isScrollControlled: true, // 允许内容超过默认高度，避免溢出
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final maxH = MediaQuery.of(ctx).size.height * 0.7; //最大高度为屏幕的0.7
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //上部分信息
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '禁言：$displayName',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentlyBanned ? '当前状态：禁言中' : '当前状态：未禁言',
                        style: TextStyle(
                          fontSize: 12,
                          color: currentlyBanned ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                //下部分选项
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...options.map(
                          (e) => ListTile(
                            title: Text(e['label']),
                            trailing:
                                const Icon(Icons.chevron_right, size: 18),
                            onTap: () {
                              Navigator.pop(ctx);
                              _doBan(memberId, e['duration'] as int,
                                  e['label'] as String);
                            },
                          ),
                        ),
                        if (currentlyBanned) ...[
                          const Divider(height: 1),
                          ListTile(
                            title: const Text(
                              '解除禁言',
                              style: TextStyle(color: Colors.red),
                            ),
                            trailing: const Icon(Icons.lock_open,
                                size: 18, color: Colors.red),
                            onTap: () {
                              Navigator.pop(ctx);
                              _doBan(memberId, 0, '解除禁言');
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                //取消按钮
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //真正发起禁言请求
  Future<void> _doBan(String memberId, int duration, String label) async {
    try {
      final res =
          await _chatGroupMemberApi.ban(targetId, memberId, duration);
      if (res['code'] == 0) {
        CustomFlutterToast.showSuccessToast(
            duration == 0 ? '已解除禁言' : '已禁言：$label');
      } else {
        CustomFlutterToast.showErrorToast(res['msg'] ?? '操作失败');
      }
    } catch (e) {
      CustomFlutterToast.showErrorToast('操作失败');
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
    _subscription?.cancel(); //移除监听器，防止退出后一直存在导致错误
    super.onClose();
    msgContentController.dispose();
    scrollController.dispose();
    GlobalData globalData = GetInstance().find<GlobalData>();
    globalData.onGetUserUnreadInfo();
  }
}
