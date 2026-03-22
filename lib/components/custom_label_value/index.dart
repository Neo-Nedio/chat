import 'package:flutter/material.dart';

//标签-值对的展示组件
class CustomLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final double? width;

  const CustomLabelValue({
    super.key,
    required this.label,
    required this.value,
    this.width = 60, //控制标签大小
  });

/*
  ┌─────────────────────────────────────┐
  │  姓名             张三               │
  │  ─────────────────────────────────  │
  │  年龄             25                │
  │  ─────────────────────────────────  │
  │  地址             北京市朝阳区...    │
  └─────────────────────────────────────┘*/
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white, //白色边框
        borderRadius: BorderRadius.circular(8),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,  // 顶部对齐
        mainAxisSize: MainAxisSize.min,                // 宽度自适应内容
        mainAxisAlignment: MainAxisAlignment.center,   // 水平居中
        children: [
          SizedBox(
            width: width,
            //标签
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54, // 半透明黑色，视觉权重较低
              ),
            ),
          ),
          const SizedBox(width: 20),
          //内容
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87, // 深色，更醒目
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
