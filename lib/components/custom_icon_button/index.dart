import 'package:flutter/material.dart';

import '../custom_material_button/index.dart';

//文字标签的圆形图标按钮
class CustomIconButton extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final double? radius;
  final Function() onTap;
  final String? text;

  const CustomIconButton({
    super.key,
    this.width = 40,
    this.height = 40,
    this.iconSize = 36,
    this.color,
    required this.onTap,
    this.iconColor,
    required this.icon,
    this.text,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //图标按钮部分
        CustomMaterialButton(
          color: color ?? const Color(0xFFE3ECFF),  // 默认浅蓝色背景
          borderRadius: radius ?? width / 2,                 // 圆形（半径 = 宽/2）
          onTap: onTap,
          child: Container(
            width: width,      // 默认 40px
            height: height,    // 默认 40px
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.black38,
            ),
          ),
        ),
        //文字标签部分（可选）
        if (text != null) ...[
          const SizedBox(height: 4), // 图标与文字间距 4px
          SizedBox(
            width: width + 10,  // 比按钮宽 10px
            child: Center(
              child: Text(
                text!,
                style: const TextStyle(
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis, // 超出显示省略号
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
