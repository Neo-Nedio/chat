import 'package:chat_mobile/pages/chat_frame/chat_content/retraction.dart';
import 'package:chat_mobile/pages/chat_frame/chat_content/system.dart';
import 'package:chat_mobile/pages/chat_frame/chat_content/time.dart';
import 'package:chat_mobile/pages/chat_frame/chat_content/voice.dart';
import 'package:custom_pop_up_menu_fork/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_text_button/index.dart';
import '../../../utils/date.dart';
import '../../../utils/getx_config/GlobalData.dart';
import '../../../utils/getx_config/config.dart';
import 'call.dart';
import 'file.dart';
import 'image.dart';
import 'text.dart';

typedef CallBack = dynamic Function(dynamic data);

//聊天消息组件
class ChatMessage extends StatelessThemeWidget {
  final Map<String, dynamic> msg;
  final Map<String, dynamic> chatInfo;
  final Map<String, dynamic>? member;
  final String? chatPortrait;
  final void Function()? onTapMsg;
  final void Function()? reEdit;

  // 点击复制回调
  final CallBack? onTapCopy;

  // 点击转发回调
  final CallBack? onTapRetransmission;

  // 点击删除回调
  final CallBack? onTapDelete;

  // 点击撤回回调
  final CallBack? onTapRetract;

  // 点击引用回调
  final CallBack? onTapCite;

  // 点击转文字回调
  final CallBack? onTapVoice;

  const ChatMessage({
    super.key,
    this.chatPortrait,
    this.onTapCopy,
    this.onTapRetransmission,
    this.onTapDelete,
    this.onTapRetract,
    this.onTapCite,
    this.onTapMsg,
    this.reEdit,
    this.onTapVoice,
    required this.msg,
    required this.chatInfo,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    //判断用户是否是发送方
    bool isRight = msg['fromId'] == globalData.currentUserId;
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
              children: [
                /// 别人发的
                //头像
                if (!isRight && msg['msgContent']['type'] != 'retraction')
                  CustomPortrait(
                    url: msg['msgContent']?['formUserPortrait'] ?? '',
                    size: 40,
                    //打开详情页
                    onTap: () {
                      final friendId = msg['fromId'];
                      final currentUserId = Get.find<GlobalData>().currentUserId;
                      if(friendId != currentUserId){
                        Get.toNamed('/friend_info', arguments: {'friendId': friendId});
                      }
                    },
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
                    url:  msg['msgContent']?['formUserPortrait'] ?? '',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //头像
                  if (!isRight && msg['msgContent']['type'] != 'retraction')
                    CustomPortrait(
                      url: chatPortrait ?? '',
                      size: 38.7,
                      onTap: () {
                        final friendId = msg['fromId'];
                        final currentUserId = Get.find<GlobalData>().currentUserId;
                        if(friendId != currentUserId){
                          Get.toNamed('/friend_info', arguments: {'friendId': friendId});
                        }
                      },
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
                      url:  msg['msgContent']?['formUserPortrait'] ?? '',
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
      return msg['msgContent']?['formUserName'] ?? '';
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

  //根据消息类型返回不同的菜单项列表
  //todo 删除 转发 转文字 引用功能未做
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
    // PopMenuItemModel(
    //     title: '收藏',
    //     icon: Icons.collections,
    //     callback: (data) {
    //       debugPrint("data: " + data);
    //     }),
    PopMenuItemModel(
        title: '删除',
        icon: Icons.delete,
        callback: onTapDelete ??
                (data) => debugPrint("data: ${data.toString()}")),
    // 自己发的消息才有撤回菜单
    if (msg['fromId'] == globalData.currentUserId &&
        DateTime.now().difference(DateTime.parse(msg['createTime'])).inMinutes < 3) //大于三分钟不能撤回)
      PopMenuItemModel(
          title: '撤回',
          icon: Icons.reply,
          callback: onTapRetract ??
                  (data) => debugPrint("data: ${data.toString()}")),
    // PopMenuItemModel(
    //     title: '多选',
    //     icon: Icons.playlist_add_check,
    //     callback:  (data) {
    //       debugPrint("data: ${data.toString()}");
    //     }),
    PopMenuItemModel(
        title: '引用',
        icon: Icons.format_quote,
        callback:
        onTapCite ?? (data) => debugPrint("data: ${data.toString()}")),
    // PopMenuItemModel(
    //     title: '提醒',
    //     icon: Icons.add_alert,
    //     callback: (data) {
    //       debugPrint("data: " + data);
    //     }),
    // PopMenuItemModel(
    //     title: '搜一搜',
    //     icon: Icons.search,
    //     callback: (data) {
    //       debugPrint("data: " + data);
    //     }),
  ];

  //根据类型获得对应组件
  Widget getComponentByType(Map<String, dynamic> msg, bool isRight) {
    String type = msg['msgContent']['type'];
    final messageMap = {
      'text': (String? username) => TextMessage(value: msg, isRight: isRight),
      'file': (String? username) => FileMessage(value: msg, isRight: isRight),
      'img': (String? username) => ImageMessage(value: msg, isRight: isRight),
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
      final messageWidget =
      messageMap[type]!(msg['msgContent']['formUserName']);

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
