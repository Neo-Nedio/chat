import 'package:flutter/cupertino.dart';

import '../../utils/getx_config/config.dart';

//带有渐变阴影效果的文本
class CustomShadowText extends StatelessThemeWidget {
  final String text;           // 要显示的文本
  final double fontSize;       // 字体大小，默认 16
  final FontWeight fontWeight; // 字体粗细，默认粗体
  final double shadowTop;      // 阴影的垂直偏移，默认 13

  const CustomShadowText(
      {super.key,
      required this.text,
      this.fontSize = 16,
      this.shadowTop = 13,
      this.fontWeight = FontWeight.bold});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        //特效
        Positioned(
          top: shadowTop, // 向下偏移 shadowTop 像素
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              height: 15, // 固定高度 15 像素
              decoration: BoxDecoration(
                gradient: LinearGradient( //渐变效果
                  colors: [
                    theme.primaryColor.withValues(alpha: 0.1),
                    theme.primaryColor,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10), // 圆角
              ),
              //透明文字
              child: Opacity(
                opacity: 0,
                child: Text(
                  text,
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
            ),
          ),
        ),
        //实际文字
        Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
      ],
    );
  }
}
