import 'package:chat_mobile/pages/chat_frame/chat_content/retraction.dart';
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

  const ChatMessage({
    super.key,
    required this.msg,
    required this.chatInfo,
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
          Text(DateUtil.formatTime(msg['msgContent']['content'])),
        // 群聊消息
        if (chatInfo['type'] == 'group' && msg['type'] != 'system')
          Align(
            //判断消息左右
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment:
                  isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                /// 别人发的
                //头像
                if (!isRight)
                  CustomPortrait(
                    url: msg['msgContent']?['formUserPortrait'],
                  ),
                const SizedBox(width: 5),
                ///用户名（自己时不显示）＋消息内容
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户名
                    if (!isRight)
                      Text(
                        msg['msgContent']?['formUserName'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF969696),
                          fontSize: 12,
                        ),
                      ),
                    //消息内容
                    getComponentByType(msg['msgContent']['type'], isRight),
                  ],
                ),
                ///自己消息
                if (isRight)
                  CustomPortrait(
                    url: msg['msgContent']?['formUserPortrait'],
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
