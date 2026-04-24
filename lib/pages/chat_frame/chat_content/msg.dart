import 'package:chat_mobile/pages/chat_frame/chat_content/retraction.dart';
import 'package:chat_mobile/pages/chat_frame/chat_content/system.dart';
import 'package:chat_mobile/pages/chat_frame/chat_content/time.dart';
import 'package:chat_mobile/pages/chat_frame/chat_content/voice.dart';
import 'package:custom_pop_up_menu_fork/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../api/friend_api.dart';
import '../../../api/user_api.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_text_button/index.dart';
import '../../../utils/date.dart';
import '../../../utils/getx_config/GlobalData.dart';
import '../../../utils/getx_config/config.dart';
import 'call.dart';
import 'emoji.dart';
import 'file.dart';
import 'image.dart';
import 'text.dart';

typedef CallBack = dynamic Function(dynamic data);

//聊天消息组件
class ChatMessage extends StatelessThemeWidget {
  final Map<String, dynamic> msg;
  final Map<String, dynamic> chatInfo;
  final Map<String, dynamic>? member;
  final bool isOwner;
  final String? chatPortrait;
  final String? selfPortrait;
  final void Function()? onTapMsg;
  final void Function()? reEdit;

  // 点击复制回调
  final CallBack? onTapCopy;

  // 点击转发回调
  final CallBack? onTapRetransmission;

  // 点击禁言回调
  final CallBack? onTapBan;

  // 点击撤回回调
  final CallBack? onTapRetract;

  // 点击引用回调
  final CallBack? onTapCite;

  // 点击转文字回调
  final CallBack? onTapVoice;

  // 与 ChatFrameLogic 一致，用于表情预览 URL 复用同一份内存缓存
  final Future<String> Function(String fileName) getCustomEmojiImageUrl;

  const ChatMessage({
    super.key,
    this.chatPortrait,
    this.selfPortrait,
    this.onTapCopy,
    this.onTapRetransmission,
    this.onTapBan,
    this.onTapRetract,
    this.onTapCite,
    this.onTapMsg,
    this.reEdit,
    this.onTapVoice,
    required this.getCustomEmojiImageUrl,
    required this.msg,
    required this.chatInfo,
    required this.member,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    //判断用户是否是发送方
    bool isRight = msg['fromId'] == globalData.currentUserId;
    //自己的头像文件名
    final selfTrim = selfPortrait?.trim() ?? '';
    final selfAv = selfTrim.isNotEmpty
        ? selfTrim
        : (msg['msgContent']?['fromUserPortrait']?.toString() ?? '');
    return Column(
      children: [
        // 时间组件
        if (msg['isShowTime'] == true)
          TimeContent(value: DateUtil.formatTime(msg['createTime'])),
        // 系统消息
        if (msg['type'] == 'system')
          SystemMessage(value: msg['msgContent']),
        // 群聊消息
        if (chatInfo['type'] == 'group' && msg['type'] != 'system')
          Align(
            //判断消息左右
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              //撤回消息在中间，其他消息根据用户判断左右
              mainAxisAlignment: msg['msgContent']['type'] == 'retraction'
                  ? MainAxisAlignment.center
                  : isRight
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              //撤回消息垂直居中，其他消息从上方开始，保证头像在最上方
              crossAxisAlignment: msg['msgContent']['type'] == 'retraction'
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                /// 别人发的
                //头像
                if (!isRight && msg['msgContent']['type'] != 'retraction')
                  CustomPortrait(
                    portrait: member?['portrait']?.toString() ?? '',
                    size: 40,
                    //打开详情页
                    onTap: () => _handlerUserTapped(msg['fromId']),
                  ),
                const SizedBox(width: 5),
                ///用户名＋消息内容
                Column(
                  crossAxisAlignment: isRight
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // 用户名
                    if (msg['msgContent']['type'] != 'retraction')
                    Text(
                      _handlerGroupDisplayName(),
                      style: const TextStyle(
                        color: Color(0xFF969696),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    //消息内容
                    getComponentByType(msg, isRight),
                  ],
                ),
                ///在撤回消息旁边显示一个"重新编辑"按钮
                if (msg['msgContent']['type'] == 'retraction' &&
                    isRight &&
                    msg['msgContent']['ext'] != null &&
                    msg['msgContent']['ext'] == 'text')
                  const SizedBox(width: 5),

                if (msg['msgContent']['type'] == 'retraction' &&
                    isRight &&
                    msg['msgContent']['ext'] != null &&
                    msg['msgContent']['ext'] == 'text')
                  CustomTextButton(
                    '重新编辑',
                    fontSize: 12,
                    onTap: reEdit ?? () => debugPrint("重新编辑"),
                  ),

                const SizedBox(width: 5),

                // 自己的头像
                if (isRight && msg['msgContent']['type'] != 'retraction')
                  CustomPortrait(
                    portrait: selfAv,
                    size: 40,
                  ),
              ],
            ),
          ),

        // 私聊消息
        if (chatInfo['type'] == 'user')
          Align(
              alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: msg['msgContent']['type'] == 'retraction'
                    ? MainAxisAlignment.center
                    : isRight
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                //撤回消息垂直居中，其他消息从上方开始，保证头像在最上方
                crossAxisAlignment: msg['msgContent']['type'] == 'retraction'
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  //头像
                  if (!isRight && msg['msgContent']['type'] != 'retraction')
                    CustomPortrait(
                      portrait: chatPortrait ?? '',
                      size: 38.7,
                      onTap: () => _handlerUserTapped(msg['fromId']),
                    ),

                  const SizedBox(width: 5),

                  //消息内容
                  getComponentByType(msg, isRight),
                  //在撤回消息旁边显示一个"重新编辑"按钮
                  if (msg['msgContent']['type'] == 'retraction' &&
                      isRight &&
                      msg['msgContent']['ext'] != null &&
                      msg['msgContent']['ext'] == 'text')
                    const SizedBox(width: 1),
                  if (msg['msgContent']['type'] == 'retraction' &&
                      isRight &&
                      msg['msgContent']['ext'] != null &&
                      msg['msgContent']['ext'] == 'text')
                  CustomTextButton('重新编辑',
                        fontSize: 12,
                        onTap: reEdit ??
                                () {
                              debugPrint("重新编辑");
                            }),
                  const SizedBox(width: 5),

                  // 自己的头像
                  if (isRight && msg['msgContent']['type'] != 'retraction')
                    CustomPortrait(
                      portrait: selfAv,
                      size: 40,
                    ),
                ],
              )),
        const SizedBox(height: 15),
      ],
    );
  }

  //获取群成员的显示名称
  String _handlerGroupDisplayName() {
    // 1. 如果没有成员信息，返回消息中的用户名
    if (member == null) {
      return msg['msgContent']?['fromUserName'] ?? '';
    }
    // 2. 有成员信息，按优先级返回
    if (member!.containsKey('groupName') && member!['groupName'] != null) {
      return member!['groupName']!;      // 优先级1：群昵称
    } else if (member!.containsKey('remark') && member!['remark'] != null) {
      return member!['remark']!;          // 优先级2：备注名
    } else {
      return member!['name'] ?? '';       // 优先级3：昵称
    }
  }

  //打开对方详情
  void _handlerUserTapped(String toId) {
    final currentUserId = Get.find<GlobalData>().currentUserId;
    if (toId != currentUserId) {
      FriendApi().isFriend(toId).then((res) {
        if (res['code'] == 0) {
          if (res['data']) {
            //双方是好友
            Get.toNamed('/friend_info', arguments: {'friendId': toId});
          } else {
            //双方不是好友
            UserApi().getInfoById(toId).then((userRes) {
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
        } else {
          CustomFlutterToast.showErrorToast(res['msg'] ?? "打开详情失败");
        }
      });
    }
  }

  //根据消息类型返回不同的菜单项列表
  List<PopMenuItemModel> menuItems(String type) => [
    // 文本消息专属菜单
    if (type == 'text')
      PopMenuItemModel(
        title: '复制',
        icon: Icons.content_copy,
        callback:
        onTapCopy ?? (data) => debugPrint("data: ${data.toString()}"),
      ),
    // 语音消息专属菜单
    if (type == 'voice')
      PopMenuItemModel(
        title: '转文字',
        icon: Icons.text_fields,
        callback:
        onTapVoice ?? (data) => debugPrint("data: ${data.toString()}"),
      ),
    // 通用菜单（所有类型都有）
    PopMenuItemModel(
        title: '转发',
        icon: Icons.send,
        callback: onTapRetransmission ??
                (data) => debugPrint("data: ${data.toString()}")),
    if (isOwner &&
        chatInfo['type'] == 'group' &&
        msg['fromId'] != globalData.currentUserId)
      PopMenuItemModel(
          title: '禁言',
          icon: Icons.volume_off,
          callback: onTapBan ??
              (data) => debugPrint("data: ${data.toString()}")),
    // 自己发的消息才有撤回菜单
    if (msg['fromId'] == globalData.currentUserId &&
        DateTime.now().difference(DateTime.parse(msg['createTime'])).inMinutes < 3) //大于三分钟不能撤回)
      PopMenuItemModel(
          title: '撤回',
          icon: Icons.reply,
          callback: onTapRetract ??
                  (data) => debugPrint("data: ${data.toString()}")),
    PopMenuItemModel(
        title: '引用',
        icon: Icons.format_quote,
        callback:
        onTapCite ?? (data) => debugPrint("data: ${data.toString()}")),
  ];

  //根据类型获得对应组件
  Widget getComponentByType(Map<String, dynamic> msg, bool isRight) {
    String type = msg['msgContent']['type'];
    final messageMap = {
      'text': (String? username) => TextMessage(value: msg, isRight: isRight),
      'file': (String? username) => FileMessage(value: msg, isRight: isRight),
      'img': (String? username) => ImageMessage(value: msg, isRight: isRight),
      'emoji': (String? username) => EmojiMessage(
            value: msg,
            isRight: isRight,
            getCustomEmojiImageUrl: getCustomEmojiImageUrl,
          ),
      'retraction': (String? username) => RetractionMessage(  // 撤回消息
        isRight: isRight,
        userName: username,
      ),
      'voice': (String? username) => VoiceMessage(value: msg, isRight: isRight),
      //这里的call是由video_chat的logic在挂断时用onHangup给后端发送消息，把类型写为call
      'call': (String? username) => CallMessage(value: msg, isRight: isRight), // 通话消息
    };

    // 非撤回消息：包裹 QuickPopUpMenu（长按弹出菜单）
    if (messageMap.containsKey(type)) {
      // 构建消息组件
      final messageWidget = messageMap[type]!(
        //私聊用null，显示[对方撤回了一条消息]
        chatInfo['type'] == 'group' ? _handlerGroupDisplayName() : null,
      );

      return type == 'retraction'
          ? messageWidget  // 撤回消息：直接返回，不需要菜单
          : QuickPopUpMenu( // 其他消息：包裹长按菜单
        showArrow: true, //是否显示指向触发元素的箭头
        useGridView: false,
        pressType: PressType.longPress,  // 长按触发
        menuItems: menuItems(type), // 动态菜单项
        dataObj: messageWidget, // 传递消息数据
        child: GestureDetector(
          onTap: onTapMsg, // 点击回调
          child: messageWidget,
        ),
      );
    } else {
      // 异常处理
      return const Text('暂不支持该消息类型');
    }
  }
}
