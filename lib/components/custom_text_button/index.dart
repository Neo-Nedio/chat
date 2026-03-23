import 'package:flutter/material.dart';

import '../../utils/getx_config/config.dart';

//自定义有涟漪效果的文本按钮
class CustomTextButton extends StatelessThemeWidget {
  final String value;
  final GestureTapCallback onTap;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomTextButton(
      this.value, {
        super.key,
        required this.onTap,
        this.fontSize = 12,
        this.textColor ,
        this.padding,
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
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      onTap: onTap,
      child: Container(
        padding: padding,
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor ?? theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
