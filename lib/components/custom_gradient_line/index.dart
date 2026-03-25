import 'package:flutter/material.dart';

//绘制一条带有渐变效果的线条
class CustomGradientLine extends StatelessWidget {
  final double width;
  final double height;
  final Gradient gradient;

  const CustomGradientLine({
    super.key,
    required this.width,
    required this.height,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),  // 指定画布大小
      painter: _GradientLinePainter(gradient: gradient),  // 实际绘制器
    );
  }
}

class _GradientLinePainter extends CustomPainter {
  final Gradient gradient;

  _GradientLinePainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 创建画笔
    final paint = Paint()
      ..shader = //将渐变转换为着色器，应用到整个画布区域
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke //设置为描边模式（而不是填充）
      ..strokeWidth = size.height; //线条的粗细等于组件的高度
    // 2. 绘制线条
    canvas.drawLine(
      Offset(0, size.height / 2),  //画布的最左侧，垂直方向居中 起点
      Offset(size.width, size.height / 2), //画布的最右侧，垂直方向居中  终点
      paint,
    );
  }

  //不需要重绘
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
