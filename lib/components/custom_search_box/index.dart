import 'package:flutter/material.dart';

import '../../utils/getx_config/config.dart';

//自定义搜索框
class CustomSearchBox extends StatelessThemeWidget {
  final bool isCentered;           // 是否居中显示
  final Color backgroundColor;      // 背景颜色
  final double borderRadius;        // 圆角大小
  final ValueChanged<String> onChanged;  // 输入改变时的回调

  const CustomSearchBox({
    super.key,
    this.isCentered = false,        // 默认左对齐
    this.backgroundColor = const Color(0xFFE3ECFF),  // 默认浅蓝色背景
    this.borderRadius = 10.0,       // 默认圆角10
    required this.onChanged,         // 必须提供回调
  });

/*
  ┌─────────────────────────────────┐  ← Container (高度40，背景色#E3ECFF)
  │  ┌───────────────────────────┐  │
  │  │ Row                       │  │
  │  │  ┌────┐  ┌─────────────┐  │  │
  │  │  │ 🔍 │  │ 搜索框       │  │  │
  │  │  │图标│  │ (TextField)  │  │  │
  │  │  └────┘  └─────────────┘  │  │
  │  │      ←8px→                │  │
  │  └───────────────────────────┘  │
  └─────────────────────────────────┘
  padding: 左右10px*/

  @override
  Widget build(BuildContext context) {

    Color iconColor = theme.primaryColor;

    return Container(
      alignment: isCentered ? Alignment.center : Alignment.centerLeft,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: theme.searchBarColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),

      child: Row(
        mainAxisAlignment:
            isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 搜索图标
          Icon(const IconData(0xe669, fontFamily: 'IconFont'),
              size: 20, color: iconColor),

          //间距
          const SizedBox(width: 8),

          //占据剩下内容
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textAlign: isCentered ? TextAlign.center : TextAlign.start,
              style: TextStyle(color: iconColor, fontSize: 16),

              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0), // 无内边距
                hintText: '搜索', // 提示文字
                hintStyle: TextStyle(
                    color: iconColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                // 无边框
                // 1. 普通边框（默认状态）
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 1),
                ),
                // 2. 启用状态下的边框（未选中时）
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 1),
                ),
                // 3. 聚焦状态下的边框（选中输入时）
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 1),
                ),
                // 4. 紧凑模式
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
