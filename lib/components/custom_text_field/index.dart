// custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//输入框
class CustomTextField extends StatelessWidget {
  final String labelText;//上方标签
  final TextEditingController controller;
  final bool obscureText;//是否展示密码
  final String hintText;//占位文案
  final Widget? suffixIcon;            // 右侧图标
  final Widget? suffix;                // 右侧自定义组件
  final ValueChanged<String>? onChanged;  // 输入变化回调
  final int? inputLimit;                // 输入字符数量限制
  final bool readOnly;
  final int? maxLines; // 新增maxLines参数

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.hintText = '请输入内容',
    this.obscureText = false,
    this.suffix,
    this.onChanged,
    this.suffixIcon,
    this.inputLimit,
    this.readOnly = false, //控制文本输入框是否可编辑
    this.maxLines = 1, // 默认为1行
  });


  /*CustomTextField
  ┌─────────────────────────────────────────────────┐
  │  Column (垂直布局)                                │
  │  ┌─────────────────────────────────────────────┐ │
  │  │  Text (上方标签)                             │ │
  │  │  "账号"                                      │ │
  │  │  style: 14px, Color(0xFF1F1F1F)             │ │
  │  └─────────────────────────────────────────────┘ │
  │                                                   │
  │  SizedBox(height: 5) ← 标签和输入框间距           │
  │                                                   │
  │  ┌─────────────────────────────────────────────┐ │
  │  │  Container                                  │ │
  │  │  decoration:                                │ │
  │  │  • color: Color(0xFFEDF2F9) (浅灰蓝)         │ │
  │  │  • borderRadius: 10px                       │ │
  │  │  ┌─────────────────────────────────────────┐ │ │
  │  │  │  TextField                               │ │ │
  │  │  │  ┌─────────────────────────────────────┐ │ │ │
  │  │  │  │  输入区域                            │ │ │ │
  │  │  │  │  • controller: 文本控制器             │ │ │ │
  │  │  │  │  • obscureText: 是否密码模式          │ │ │ │
  │  │  │  │  • onChanged: 输入回调                │ │ │ │
  │  │  │  │  • inputFormatters: 长度限制          │ │ │ │
  │  │  │  │                                     │ │ │ │
  │  │  │  │  InputDecoration                     │ │ │ │
  │  │  │  │  ┌─────────────────────────────────┐ │ │ │ │
  │  │  │  │  │  ← hintText →    [suffixIcon]   │ │ │ │ │
  │  │  │  │  │  "请输入内容"      [suffix]      │ │ │ │ │
  │  │  │  │  │                                  │ │ │ │ │
  │  │  │  │  │  ← contentPadding →              │ │ │ │ │
  │  │  │  │  │  vertical:8, horizontal:8        │ │ │ │ │
  │  │  │  │  └─────────────────────────────────┘ │ │ │ │
  │  │  │  └─────────────────────────────────────┘ │ │ │
  │  │  └─────────────────────────────────────────┘ │ │
  │  └─────────────────────────────────────────────┘ │
  └─────────────────────────────────────────────────┘
  */
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 标签左对齐
      children: [
        Text(
          labelText,//上方标签
          style: const TextStyle(color: Color(0xFF1F1F1F), fontSize: 14.0), // 标签样式
        ),

        const SizedBox(height: 5.0), // 标签和输入框之间的间距

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2F9), // 设置背景颜色
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,//函数回调
            readOnly: readOnly,
            maxLines: maxLines,
            inputFormatters: inputLimit != null
                ? <TextInputFormatter>[
              LengthLimitingTextInputFormatter(inputLimit) //限制输入长度
            ]
                : null, // 不设置任何限制
            decoration: InputDecoration(
              hintText: hintText,//占位文案
              suffixIcon: suffixIcon, // 右侧图标
              suffix: suffix, // 右侧自定义组件
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
              // 填充背景
              filled: true,
              // 填充背景颜色
              fillColor: const Color(0xFFEDF2F9),
              // 缩小输入框高度，让输入框更紧凑
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none, // 去除边框
              ),
              //设置输入框内部内容的内边距（padding）
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            ),
          ),
        ),
      ],
    );
  }
}
