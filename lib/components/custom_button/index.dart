import 'package:flutter/material.dart';

import '../../utils/getx_config/config.dart';
import '../custom_material_button/index.dart';

//对material_button进行封装的自定义文字按钮
class CustomButton extends StatelessThemeWidget {
  final String text;
  final VoidCallback onTap;
  final String type;
  final double? width;
  final double? height;
  final double? textSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const CustomButton(
      {super.key,
      required this.text,
      this.width = 200,
      this.height = 40,
      this.textSize = 16,
      this.type = 'primary',
      this.borderRadius = 10,
      this.padding = const EdgeInsets.all(10),
      required this.onTap});

  Color _getColor(String type) {
    switch (type) {
      case 'primary':
        return theme.primaryColor;
      case 'minor':
        return const Color(0xFFEDF2F9);  // 次要按钮：浅灰蓝
      default:
        return theme.primaryColor;
    }
  }

  TextStyle _getTextStyle(String type) {
    switch (type) {
      case 'primary':
        return TextStyle(color: Colors.white, fontSize: textSize);  // 白色文字
      case 'minor':
        return TextStyle(color: const Color(0xFF1F1F1F), fontSize: textSize);  // 深灰色文字
      default:
        return TextStyle(color: Colors.white, fontSize: textSize); // 白色文字
    }
  }

  BoxDecoration _getBoxDecoration(String type) {
    switch (type) {
      case 'gradient':
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.boldColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius!),
        );
      default:
        return BoxDecoration(
          color: _getColor(type),
          borderRadius: BorderRadius.circular(borderRadius!),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomMaterialButton(
      onTap: onTap,
      color: type == 'gradient' ? null : _getColor(type), //渐变时颜色由decoration控制
      child: Container(
        width: width,
        height: height,
        decoration: _getBoxDecoration(type),
        padding: padding,
        child: Center(
          child: Text(
            text,
            style: _getTextStyle(type),
          ),
        ),
      ),
    );
  }
}
