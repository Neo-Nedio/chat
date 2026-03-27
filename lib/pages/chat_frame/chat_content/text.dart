import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/getx_config/config.dart';

class TextMessage extends StatelessThemeWidget {
  final dynamic value;
  final bool isRight;

  const TextMessage({
    super.key,
    required this.value,
    required this.isRight, //是不是用户发的
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isRight ? theme.primaryColor : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      //最大为屏幕的0.8倍大小
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(Get.context!).size.width * 0.8,
      ),
      child: Text(
        value['msgContent']['content'],
        style: TextStyle(color: isRight ? Colors.white : Colors.black),
      ),
    );
  }
}
