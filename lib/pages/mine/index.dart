import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../components/custom_material_button/index.dart';
import '../../components/custom_portrait/index.dart';
import '../../components/custom_shadow_text/index.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';


//我的页面
class MinePage extends CustomWidget<MineLogic> {
  MinePage({super.key});

  @override
  void init(BuildContext context) {
    super.init(context);
    controller.init();
  }
/*
  ┌─────────────────────────────────────┐
  │  Gradient Container (渐变背景)       │
  │  ┌─────────────────────────────────┐ │
  │  │  Row                            │ │
  │  │  ┌─────┐  ┌───────────────────┐ │ │
  │  │  │     │  │ 用户名            │ │ │
  │  │  │ 头像 │  │ 账号：xxx        │ │ │
  │  │  │70x70│  └───────────────────┘ │ │
  │  │  └─────┘  ←──间距10──→  󰀃      │ │
  │  └─────────────────────────────────┘ │
  ├─────────────────────────────────────┤
  │  Transform.translate (上移30px)      │
  │  ┌─────────────────────────────────┐ │
  │  │  Column                         │ │
  │  │  ┌───────────────────────────┐  │ │
  │  │  │ 我的说说             ▶   │  │ │ ← 主要按钮 (高60)
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 系统通知             ▶   │  │ │
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 修改密码   󰀃  ▶           │  │ │ ← 次要按钮 (高50)
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 关于我们   󰀃  ▶           │  │ │
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 设置       󰀃  ▶           │  │ │
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 切换账号                   │  │ │ ← 最小按钮 (居中)
  │  │  ├───────────────────────────┤  │ │
  │  │  │ 退出 (红色)                │  │ │
  │  │  └───────────────────────────┘  │ │
  │  └─────────────────────────────────┘ │
  └─────────────────────────────────────┘
  */
  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF), // 浅蓝色背景
      body: Column(
        children: [
          //上方头像与用户区域
          Container(
            decoration:  BoxDecoration(
              gradient: LinearGradient(  // 线性渐变
                colors: [theme.minorColor, const Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,      // 渐变起点：左上角
                end: Alignment.bottomRight,    // 渐变终点：右下角
              ),
              borderRadius: const BorderRadius.only(  // 底部圆角
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            height: 200,  // 高度200像素

            padding: const EdgeInsets.symmetric(horizontal: 30),  // 左右内边距30
            child: Row(
              children: [
                //头像区域
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/edit_mine');
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: CustomPortrait(
                        portrait: controller.currentUserInfo['portrait'] ?? '',
                        size: 70,
                        radius: 35),
                  ),
                ),

                //分割
                const SizedBox(width: 10),

                // 文字信息区域
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 用户名（带特殊效果）
                          CustomShadowText(text: controller.currentUserInfo['name'] ?? ''),

                          const SizedBox(height: 10), // 间距

                          //账号信息
                          Text(
                            '账号：${controller.currentUserInfo['account'] ?? ''}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),

                      //右侧图标
                      CustomMaterialButton(
                          child: const Icon(
                              IconData(0xe615, fontFamily: 'IconFont'),
                              size: 45),
                          onTap: () => Get.toNamed('/mine_qr_code'))
                    ],
                  ),
                ),
              ],
            ),
          ),
//Transform.translate 是 Flutter 中用于对子组件进行位置偏移的组件。它可以在不改变布局的情况下，让子组件相对于其原始位置移动。
          Transform.translate(
            offset: const Offset(0, -30), // 向上偏移30像素
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  _primarySelectButton(
                    '我的说说',
                    'mine-talk-${theme.themeMode}.png',
                        () => Get.toNamed('/talk', arguments: {
                      'userId': globalData.currentUserId,
                      'title': '我的说说'
                    }),
                  ),
                  const SizedBox(height: 2),
                  _primarySelectButton('系统通知', 'mine-notify-${theme.themeMode}.png',
                          () => Get.toNamed('/system_notify')),
                  const SizedBox(height: 30),
                  _minorSelectButton('修改密码', 'mine-password.png',  () {
                    Get.toNamed('/update_password');
                  }),
                  const SizedBox(height: 2),
                  const SizedBox(height: 2),
                  _minorSelectButton('关于我们', 'mine-about.png', () {
                    //todo Get.toNamed('/about');
                  }),
                  const SizedBox(height: 2),
                  _minorSelectButton('设置', 'mine-set.png', () {}),
                  const SizedBox(height: 30),
                  _leastSelectButton('切换账号', () {}),
                  const SizedBox(height: 2),
                  _leastSelectButton('退出', controller.handlerLogout,
                      color: theme.errorColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //主要按钮
  Widget _primarySelectButton(String text, String iconStr, Function() onTap) {
    return CustomMaterialButton(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,  // 透明背景
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
          children: [
            Text(                                             // 左侧文字
              text,
              style: const TextStyle(fontSize: 16),
            ),
            Image.asset('assets/images/$iconStr', width: 40), // 右侧图片
          ],
        ),
      ),
    );
  }

  //次要按钮
  Widget _minorSelectButton(String text, String iconStr, Function() onTap) {
    return CustomMaterialButton(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 左侧图标+文字
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/$iconStr', width: 20),
                const SizedBox(width: 1),
                Text(
                  text,
                  style: const TextStyle(fontSize: 14, height: 1),
                ),
              ],
            ),
            // 这个 Center 只是让它的 child 居中，而不是让它在 Row 中居中
            Center( // 右侧箭头图标
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  const IconData(0xe61f, fontFamily: 'IconFont'),
                  size: 18,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 最小按钮
  Widget _leastSelectButton(String text, Function() onTap, {Color? color}) {
    return CustomMaterialButton(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,// // 居中对齐
          children: [
            Text(
              text,
              style: TextStyle(
                  fontSize: 14, height: 1, color: color ?? Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
