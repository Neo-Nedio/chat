import 'package:flutter/material.dart';

import '../../utils/getx_config/config.dart';

//自定义徽章组件，用于显示标签、状态标记等，支持不同颜色主题
class CustomBadge extends StatelessThemeWidget {
  final String text;
  final String type;

  const CustomBadge({
    super.key,
    required this.text,
    this.type = 'primary',
  });

  Color _getColor(String type) {
    switch (type) {
      case 'primary':
        return theme.primaryColor;
      case 'gold':
        return const Color(0xFFF3B659);
      default:
        return theme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
   /*
    ┌─────────────────────────────────────────────────┐
    │  ┌──────┐                                        │
    │  │ VIP  │  ← 边框：蓝色                          │
    │  └──────┘    背景：浅蓝色（10%透明度）            │
    │              文字：蓝色                          │
    └─────────────────────────────────────────────────┘*/
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _getColor(type).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: _getColor(type), width: 1),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 10, color: _getColor(type)),
        ),
      ),
    );
  }
}
