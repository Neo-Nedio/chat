import 'package:flutter/material.dart';

//自定义有涟漪效果的文本按钮
class CustomTextButton extends StatelessWidget {
  final String value;
  final GestureTapCallback onTap;
  final Color? textColor;
  final double fontSize;

  const CustomTextButton(
      this.value, {
        super.key,
        required this.onTap,
        this.fontSize = 12,
        this.textColor = const Color(0xFF4C9BFF),
      });

/*  CustomTextButton
  ┌─────────────────────────────────────┐
  │  InkWell (点击波纹效果)               │
  │  ┌─────────────────────────────────┐ │
  │  │  Text                           │ │
  │  │  "按钮文字"                      │ │
  │  └─────────────────────────────────┘ │
  └─────────────────────────────────────┘*/
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        value,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
        ),
      ),
    );
  }
}
