// custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//输入框
class CustomTextField extends StatelessWidget {
  final String? labelText;//上方标签
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;//是否展示密码
  final String hintText;//占位文案
  final Widget? suffixIcon;            // 右侧图标
  final Widget? suffix;                // 右侧自定义组件
  final double vertical;
  final ValueChanged<String>? onChanged;  // 输入变化回调
  final int? inputLimit;                // 输入字符数量限制
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final Color? labelTextColor; //标签文字颜色
  final Color? hintTextColor;
  final IconData? iconData;
  final VoidCallback? onTap;
  final Color? fillColor;


  const CustomTextField({
    super.key,
    this.labelText,
    required this.controller,
    this.focusNode,
    this.hintText = '请输入内容',
    this.obscureText = false,
    this.suffix,
    this.onChanged,
    this.suffixIcon,
    this.inputLimit,
    this.labelTextColor = const Color(0xFF1F1F1F),
    this.readOnly = false, //控制文本输入框是否可编辑
    this.maxLines = 1, // 默认为1行
    this.minLines,
    this.vertical = 12.0,
    this.hintTextColor = Colors.grey,
    this.iconData,
    this.onTap,
    this.fillColor,
  });


  /*CustomTextField
┌─────────────────────────────────────────────────┐
│  Column (垂直布局)                                │
│  ┌─────────────────────────────────────────────┐ │
│  │  Text (上方标签) - 可选                       │ │
│  │  "账号"                                      │ │
│  │  style: 14px, Color(0xFF1F1F1F)             │ │
│  └─────────────────────────────────────────────┘ │
│                                                   │
│  SizedBox(height: 5) ← 标签和输入框间距           │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │  Container (背景容器)                        │ │
│  │  decoration:                                │ │
│  │  • color: #EDF2F9 (浅灰蓝色)                 │ │
│  │  • borderRadius: 10px                       │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │  Row (水平布局)                          │ │ │
│  │  │  ┌──────┐ ┌────────────────────┐ ┌────┐ │ │ │
│  │  │  │ Icon │ │   TextField        │ │suf-│ │ │ │
│  │  │  │(可选)│ │   (Expanded)       │ │fix │ │ │ │
│  │  │  └──────┘ └────────────────────┘ └────┘ │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
  */
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 标签左对齐
      children: [
        //上方标签
        if (labelText != null)
          Text(
            labelText ?? '',
            style: TextStyle(color: labelTextColor, fontSize: 14.0),
          ),
        if (labelText != null) const SizedBox(height: 5.0),//标签与输入框的间距

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: fillColor ?? const Color(0xFFEDF2F9), // 设置背景颜色
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 左侧图标（可选）
              if (iconData != null)
                Row(
                  children: [
                    Icon(iconData, size: 16.0, color: hintTextColor),
                    const SizedBox(width: 5.0),
                  ],
                ),
              //输入框
              Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    obscureText: obscureText,
                    onChanged: onChanged,//函数回调
                    readOnly: readOnly,
                    maxLines: maxLines,
                    minLines: minLines,
                    onTap: onTap,
                    inputFormatters: inputLimit != null
                        ? <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(inputLimit) //限制输入长度
                    ]
                        : null, // 不设置任何限制
                    decoration: InputDecoration(
                      hintText: hintText,//占位文案
                      suffixIcon: suffixIcon, // 右侧图标
                      suffix: suffix, // 右侧自定义组件
                      hintStyle: TextStyle(color: hintTextColor, fontSize: 14.0),
                      // 填充背景
                      filled: true,
                      // 填充背景颜色
                      fillColor: fillColor ?? const Color(0xFFEDF2F9),
                      // 缩小输入框高度，让输入框更紧凑
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none, // 去除边框
                      ),
                      //设置输入框内部内容的内边距（padding）
                      contentPadding: EdgeInsets.symmetric(vertical: vertical),
                    ),
                  ),
              )
            ],
          )
        ),
      ],
    );
  }
}
