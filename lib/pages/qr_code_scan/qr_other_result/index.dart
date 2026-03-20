import 'package:flutter/material.dart';

import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class QrOtherResultPage extends CustomWidget<QrOtherResultLogic> {
  QrOtherResultPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF), // 浅蓝色背景
      appBar: AppBar(
        centerTitle: true,
        title: const Text('扫描结果'),
        backgroundColor: const Color(0xFFF9FBFF),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              // 错误/警告图标
              const Icon(
                IconData(0xe66a, fontFamily: 'IconFont'),
                size: 100,
                color: Color(0xCCFF4C4C), // 半透明红色
              ),

              const SizedBox(height: 20),

              // 显示扫描到的内容
              Text(controller.text, style: const TextStyle(fontSize: 18))
            ],
          ),
        ),
      ),
    );
  }
}
