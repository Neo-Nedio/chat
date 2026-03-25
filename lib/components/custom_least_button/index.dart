import 'package:flutter/material.dart';

import '../custom_material_button/index.dart';

//极简风格的按钮组件
class CustomLeastButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? textColor;

  const CustomLeastButton({
    super.key,
    required this.text,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomMaterialButton(
      onTap: onTap,
      child: Container(
        height: 50,  // 固定高度 50px
        padding: const EdgeInsets.symmetric(horizontal: 20), // 左右内边距 20px
        decoration: const BoxDecoration(
          color: Colors.transparent,  // 透明背景
        ),
        //文字
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // 水平居中
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,                           // 14px 字体
                color: textColor ?? Colors.black,       // 默认黑色
              ),
            ),
          ],
        ),
      ),
    );
  }
}
