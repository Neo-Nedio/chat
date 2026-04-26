import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget appLoadingInkDrop({required Color color, double size = 32}) {
  return LoadingAnimationWidget.inkDrop(
    color: color,
    size: size,
  );
}

Widget appLoadingDiscreteCircle({
  required Color color,
  double size = 32,
  Color? secondRingColor,
  Color? thirdRingColor,
}) {
  return LoadingAnimationWidget.discreteCircle(
    color: color,
    size: size,
    secondRingColor: secondRingColor ??
        Color.lerp(color, const Color(0xFF1A1A1A), 0.3)!,
    thirdRingColor: thirdRingColor ??
        Color.lerp(color, const Color(0xFF5E35B1), 0.28)!,
  );
}
