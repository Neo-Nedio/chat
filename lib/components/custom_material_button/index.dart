import 'package:flutter/material.dart';


//自定义有涟漪效果的按钮
class CustomMaterialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  final Color? color;
  final GestureLongPressCallback? onLongPress;

  const CustomMaterialButton(
      {
      required this.child,
      required this.onTap,
      this.onLongPress,
      this.color,
      this.borderRadius = 10,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Material(//InkWell需要
      borderRadius: BorderRadius.circular(borderRadius),
      color: color ?? Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
