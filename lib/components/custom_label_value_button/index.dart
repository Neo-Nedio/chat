import 'package:flutter/material.dart';

import '../custom_material_button/index.dart';

class CustomLabelValueButton extends StatelessWidget {
  final String label;
  final String? value;
  final double? width;
  final VoidCallback onTap;
  final int? maxLines;
  final Widget? child;
  final String hint;

  const CustomLabelValueButton({
    super.key,
    required this.label, //左侧标签文字
    required this.onTap, //点击回调
    this.value, //	当前显示的值
    this.child,
    this.maxLines = 5,
    this.hint = '', //值为空时的提示文字
    this.width = 60, // 标签区域的宽度
  });

  Widget _getContent() {
    // 判断条件：没有自定义内容 并且 (值为空 或 值只有空白字符)
    if ( child == null  && (value == null || value!.trim().isEmpty)) {
      // 情况1：显示提示文字（灰色，14号字）
      return Text(
        hint,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black38,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
    // 情况2：优先使用自定义内容，没有则显示value
    return child ??
        Text(
          value!,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        );
  }

  @override
  Widget build(BuildContext context) {
/*
    ┌─────────────────────────────────────────────────────────────┐
    │ CustomMaterialButton                                        │
    │ ┌─────────────────────────────────────────────────────────┐ │
    │ │ Container (padding: 10)                                 │ │
    │ │ ┌─────────────────────────────────────────────────────┐ │ │
    │ │ │ Row                                                 │ │ │
    │ │ │ ┌──────────────────┬────────────────────┬─────────┐ │ │ │
    │ │ │ │                  │                    │         │ │ │
    │ │ │ │  标签区域        │   值显示区域       │  图标   │ │ │
    │ │ │ │  (固定宽度)      │   (弹性宽度)       │  (→)    │ │ │
    │ │ │ │                  │                    │         │ │ │
    │ │ │ │  例如：姓名      │   张三             │    >    │ │ │
    │ │ │ │                  │                    │         │ │ │
    │ │ │ └──────────────────┴────────────────────┴─────────┘ │ │ │
    │ │ └─────────────────────────────────────────────────────┘ │ │
    │ └─────────────────────────────────────────────────────────┘ │
    └─────────────────────────────────────────────────────────────┘*/
    return CustomMaterialButton( // 外层：带涟漪效果的按钮
      onTap: onTap,  // 点击时触发回调
      child: Container( // 容器：提供内边距
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,  // 顶部对齐
          mainAxisSize: MainAxisSize.min,                // 最小宽度
          mainAxisAlignment: MainAxisAlignment.center,   // 水平居中
          children: [
            // 第一部分：标签区域
            SizedBox(
              width: width,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            // 第二部分：值显示区域（弹性占满剩余空间）
            Expanded(
              child: _getContent(),
            ),
            // 第三部分：右箭头图标
            Icon(
              const IconData(0xe61f, fontFamily: 'IconFont'),
              size: 16,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}
