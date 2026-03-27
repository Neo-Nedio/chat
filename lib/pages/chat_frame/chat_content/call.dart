import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../utils/date.dart';
import '../../../utils/getx_config/config.dart';

class CallMessage extends StatelessThemeWidget {
  final dynamic value;   // 消息数据
  final bool isRight;    // 是否是自己发的

  const CallMessage({
    super.key,
    required this.value,
    required this.isRight,
  });

  @override
  Widget build(BuildContext context) {
    final content = jsonDecode(value['msgContent']['content']);
    final type = content?['type'];        // 'audio' 或 'video'
    final time = content?['time'] ?? 0;   // 通话时长（秒），0表示未接通

    return Container(
      width: 170,
      height: 34,
      decoration: BoxDecoration(
        color: isRight ? theme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              type == 'audio' ? Icons.phone : Icons.videocam, // 语音/视频图标
              size: 20,
              color: isRight ? Colors.white : Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              time > 0 ? "通话时长 ${DateUtil.formatTimingTime(time)}" : "通话未接通",
              style: TextStyle(
                color: isRight ? Colors.white : null,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
