import 'package:flutter/material.dart';

import '../custom_portrait/index.dart';

//可编辑的头像组件，显示头像图片，并在编辑模式下覆盖一个半透明遮罩和相机图标，点击可更换头像。
class CustomUpdatePortrait extends StatelessWidget {
  final String url;
  final double size;
  final double radius;
  final GestureTapCallback onTap;
  final bool isEdit;

  const CustomUpdatePortrait(
      {super.key,
      required this.url,
      this.size = 70,
      this.radius = 35,
      required this.onTap,
      this.isEdit = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        //头像
        CustomPortrait(
          onTap: onTap, //在没有遮盖层时也可以编辑
          url: url,
          size: size,
          radius: radius,
        ),
        //编辑遮罩层（可选）
        if (isEdit)
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: size,      // 与头像同宽
              height: size,     // 与头像同高
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),  // 半透明黑色遮罩
                borderRadius: BorderRadius.circular(radius), // 与头像相同的圆角
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.camera_alt, // 相机图标
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}
