import 'package:chat_mobile/pages/chat_frame/chat_content/retraction.dart';
import 'package:chat_mobile/pages/chat_frame/chat_content/system.dart';
import 'package:chat_mobile/pages/chat_frame/chat_content/time.dart';
import 'package:chat_mobile/pages/chat_frame/chat_content/voice.dart';
import 'package:flutter/material.dart';

import '../../../components/custom_portrait/index.dart';
import '../../../utils/date.dart';
import '../../../utils/getx_config/config.dart';
import 'call.dart';
import 'file.dart';
import 'image.dart';
import 'text.dart';

//聊天消息组件
class ChatMessage extends StatelessThemeWidget {
  final Map<String, dynamic> msg;
  final Map<String, dynamic> chatInfo;
  final Map<String, dynamic>? member;

  const ChatMessage({
    super.key,
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
        if (msg['type'] == 'system') SystemMessage(value: msg['msgContent']),
        // 群聊消息
        if (chatInfo['type'] == 'group' && msg['type'] != 'system')
          Align(
            //判断消息左右
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment:
                  isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 别人发的
                //头像
                //todo 增加一个添加后转向详情的回调
                if (!isRight)
                  CustomPortrait(
                    url: msg['msgContent']?['formUserPortrait'],
                    size: 40,
                  ),
                const SizedBox(width: 5),
                ///用户名＋消息内容
                Column(
                  crossAxisAlignment: isRight
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // 用户名
                    Text(
                      handlerGroupDisplayName(),
                      style: const TextStyle(
                        color: Color(0xFF969696),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    //消息内容
                    getComponentByType(msg['msgContent']['type'], isRight),
                  ],
                ),
                const SizedBox(width: 5),
                ///自己消息
                if (isRight)
                  CustomPortrait(
                    url: msg['msgContent']?['formUserPortrait'],
                    size: 40,
                  ),
              ],
            ),
          ),

        // 私聊消息
        if (chatInfo['type'] == 'user')
          Align(
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: getComponentByType(msg['msgContent']['type'], isRight),
          ),
        const SizedBox(height: 15),
      ],
    );
  }

  //获取群成员的显示名称
  String handlerGroupDisplayName() {
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

  Widget getComponentByType(String? type, bool isRight) {
    switch (type) {
      case 'text':
        return TextMessage(
          value: msg,
          isRight: isRight,
        );
      case 'file':
        return FileMessage(value: msg, isRight: isRight);
      case 'img':
        return ImageMessage(value: msg, isRight: isRight);
      case 'retraction':
        return RetractionMessage(isRight: isRight);
      case 'voice':
        return VoiceMessage(value: msg, isRight: isRight);
      case 'call':
        return CallMessage(value: msg, isRight: isRight);
      default:
        return const Text('暂不支持该消息类型');
    }
  }
}
