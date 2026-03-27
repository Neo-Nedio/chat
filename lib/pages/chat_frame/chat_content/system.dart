import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../utils/getx_config/config.dart';

//系统消息
class SystemMessage extends StatelessThemeWidget {
  final dynamic value;

  const SystemMessage({super.key, this.value});

  @override
  Widget build(BuildContext context) {
/*
    ┌─────────────────────────────────────────────────┐
    │  张三 加入了群聊                                 │
    │  群名称已修改为 "技术交流群"                      │
    │  李四 和 王五 成为好友                           │
    └─────────────────────────────────────────────────┘*/
    List<dynamic> systemMsgList = jsonDecode(value['content']); // 解析 JSON
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: systemMsgList.map((msg) {
          //判断是否强调
          final isEmphasize = msg['isEmphasize'] as bool? ?? false;
          final content = msg['content'] as String? ?? '';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 12,
                color: isEmphasize ? theme.primaryColor : Colors.black,
                fontWeight: isEmphasize ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
