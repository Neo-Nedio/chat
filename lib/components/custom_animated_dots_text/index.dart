import 'package:flutter/material.dart';

//带动态省略号动画的文本组件
class CustomAnimatedDotsText extends StatefulWidget {
  final String text;                    // 基础文本，如"正在输入"
  final Duration duration;             // 动画周期时长
  final TextStyle? textStyle;          // 文本样式
  final BoxDecoration? decoration;     // 背景装饰
  final EdgeInsetsGeometry? padding;    // 内边距

  const CustomAnimatedDotsText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 1200),
    this.textStyle,
    this.decoration,
    this.padding,
  });

  @override
  State<CustomAnimatedDotsText> createState() => _AnimatedDotsTextState();
}

class _AnimatedDotsTextState extends State<CustomAnimatedDotsText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,           // 绑定 Ticker，节省资源
      duration: widget.duration,  // 动画周期，默认 1200ms
    )..repeat();             // 无限循环
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(4),
      decoration: widget.decoration ??
          BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(5),
          ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          //计算点数(floor去除小数)
          int dots = (_controller.value * 3).floor() + 1;
          return Text(
            '${widget.text}${'.' * (dots % 4)}', //点数映射到 0-3
            style: widget.textStyle ??
                const TextStyle(fontSize: 14, color: Colors.white),
          );
        },
      ),
    );
  }
}
