import 'package:flutter/material.dart';

//自定义有涟漪效果的按钮
class CustomMaterialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;

  const CustomMaterialButton(
      {
      required this.child,
      required this.onTap,
      this.borderRadius = 10,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Material(//InkWell需要
      borderRadius: BorderRadius.circular(borderRadius),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: child,
      ),
    );
  }
}
