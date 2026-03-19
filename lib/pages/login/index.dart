import 'package:flutter/material.dart';

import '../../components/custom_text_field/index.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';


class LoginPage extends CustomWidget<LoginPageLogic>  {
  LoginPage({super.key});

/*
┌─────────────────────────────────────────────────┐
│  🌈 渐变背景 (从左上到右下：浅蓝→白→淡蓝)         │
│  ═══════════════════════════════════════════════ │
│  ↑ SafeArea (避开状态栏)                          │
│  ┌─────────────────────────────────────────────┐ │
│  │  SingleChildScrollView (可滚动)              │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │  Container (高度 = 屏幕高度 - 安全区域)   │ │ │
│  │  │  padding: EdgeInsets.all(16)            │ │ │
│  │  │  ┌─────────────────────────────────────┐ │ │ │
│  │  │  │  Column (mainAxisAlignment: center)  │ │ │ │
│  │  │  │  ┌─────────────────────────────┐    │ │ │ │
│  │  │  │  │  Spacer (flex: 1)           │    │ │ │ │
│  │  │  │  │  ┌───────────────────────┐ │    │ │ │ │
│  │  │  │  │  │  Logo (25%屏幕宽度)   │ │    │ │ │ │
│  │  │  │  │  └───────────────────────┘ │    │ │ │ │
│  │  │  │  │                             │    │ │ │ │
│  │  │  │  │  ┌───────────────────────┐ │    │ │ │ │
│  │  │  │  │  │  标题 "聊天" (30px)   │ │    │ │ │ │
│  │  │  │  │  │  fontWeight: w900     │ │    │ │ │
│  │  │  │  │  └───────────────────────┘ │    │ │ │ │
│  │  │  │  │                             │    │ │ │ │
│  │  │  │  │  ┌───────────────────────┐ │    │ │ │ │
│  │  │  │  │  │  SizedBox (20px)      │ │    │ │ │ │
│  │  │  │  │  └───────────────────────┘ │    │ │ │ │
│  │  │  │  │                             │    │ │ │ │
│  │  │  │  │  ┌───────────────────────┐ │    │ │ │ │
│  │  │  │  │  │  白色卡片              │ │    │ │ │ │
│  │  │  │  │  │  ┌─────────────────┐ │ │    │ │ │ │
│  │  │  │  │  │  │  账号输入框     │ │ │    │ │ │ │
│  │  │  │  │  │  │  suffix: 0/30  │ │ │    │ │ │ │
│  │  │  │  │  │  └─────────────────┘ │ │    │ │ │ │
│  │  │  │  │  │  ┌─────────────────┐ │ │    │ │ │ │
│  │  │  │  │  │  │  密码输入框     │ │ │    │ │ │ │
│  │  │  │  │  │  │  obscure: true │ │ │    │ │ │ │
│  │  │  │  │  │  │  suffix: 0/16  │ │ │    │ │ │ │
│  │  │  │  │  │  └─────────────────┘ │ │    │ │ │ │
│  │  │  │  │  │  ┌─────────────────┐ │ │    │ │ │ │
│  │  │  │  │  │  │  FractionallySizedBox │    │ │ │ │
│  │  │  │  │  │  │  widthFactor: 0.8│ │ │    │ │ │ │
│  │  │  │  │  │  │  ┌─────────────┐ │ │ │    │ │ │ │
│  │  │  │  │  │  │  │  登录按钮   │ │ │ │    │ │ │ │
│  │  │  │  │  │  │  │  蓝色背景   │ │ │ │    │ │ │ │
│  │  │  │  │  │  │  └─────────────┘ │ │ │    │ │ │ │
│  │  │  │  │  │  └─────────────────┘ │ │    │ │ │ │
│  │  │  │  │  │                       │ │    │ │ │ │
│  │  │  │  │  │  ┌─────────────────┐ │ │    │ │ │ │
│  │  │  │  │  │  │  TextButton      │ │ │    │ │ │ │
│  │  │  │  │  │  │  "忘记密码"      │ │ │    │ │ │ │
│  │  │  │  │  │  └─────────────────┘ │ │    │ │ │ │
│  │  │  │  │  │  ┌─────────────────┐ │ │    │ │ │ │
│  │  │  │  │  │  │  TextButton      │ │ │    │ │ │ │
│  │  │  │  │  │  │  "注册账号"      │ │ │    │ │ │ │
│  │  │  │  │  │  └─────────────────┘ │ │    │ │ │ │
│  │  │  │  │  └───────────────────────┘ │    │ │ │ │
│  │  │  │  │                             │    │ │ │ │
│  │  │  │  │  Spacer (flex: 3)           │    │ │ │ │
│  │  │  │  └─────────────────────────────┘    │ │ │ │
│  │  │  └─────────────────────────────────────┘ │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────┘ │
│  ↓ SafeArea (避开底部Home条)                      │
└─────────────────────────────────────────────────┘
*/
/*

  没有 Spacer (严格居中)：          有 Spacer (内容偏上，视觉更舒适)：

  ┌────────────────────┐          ┌────────────────────┐
  │                    │          │                    │
  │                    │          │    Logo            │← 顶部 Spacer flex:1
  │                    │          │    聊天            │   占据1份空间
  │    Logo            │          │  ┌──────────────┐  │
  │    聊天            │          │  │  登录框      │  │
  │  ┌──────────────┐  │          │  └──────────────┘  │
  │  │  登录框      │  │          │                    │
  │  └──────────────┘  │          │                    │
  │                    │          │                    │← 底部 Spacer flex:3
  │                    │          │                    │   占据3份空间
  │                    │          │                    │   (让内容偏上)
  └────────────────────┘          └────────────────────┘
*/
/*
  ┌────────────────────┐  ← 屏幕顶部
  │  状态栏 (47px)     │  ← MediaQuery.of(context).padding.top
  ├────────────────────┤
  │                    │
  │                    │
  │   可用内容区域      │
  │   (771px)          │  ← 计算出的高度
  │                    │
  │                    │
  ├────────────────────┤
  │  底部安全区 (34px)  │  ← MediaQuery.of(context).padding.bottom
  │  (Home指示条)       │  包含系统的按钮
  └────────────────────┘  ← 屏幕底部*/

  @override
  Widget buildWidget(BuildContext context) {
    //获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // 用于控制当键盘弹出时，页面是否自动调整大小以避免键盘遮挡输入框。
      resizeToAvoidBottomInset: false,
      body: Container(
        //明确说明要占满
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBED7F6), Color(0xFFFFFFFF), Color(0xFFDFF4FF)],  // 3种颜色
            begin: Alignment.topLeft,      // 渐变起点：左上角
            end: Alignment.bottomRight,    // 渐变终点：右下角
          ),
        ),
        child: SafeArea(
          //让弹出键盘时，用户可用向上移动屏幕，看清输入
            child: SingleChildScrollView(
              child: Container(
                //得出可用高度
              /*总容器高度 = screenHeight - topPadding - bottomPadding
              内容区域高度 = 总容器高度 - (上下padding之和)
              内容起始位置 = 距离顶部 topPadding + padding.top*/
                height: screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,//大体居中
                  children: <Widget>[
                    //Spacer 是一个弹性空间占位符，它会自动填充 Row 或 Column 中的空白区域。
                    const Spacer(flex: 1),

                    // 应用 Logo
                    Image.asset(
                      'assets/images/logo.png', // 确保在pubspec.yaml中添加了logo图片路径
                      height: screenWidth * 0.25,
                      width: screenWidth * 0.25,
                    ),
                    //应用名称
                    const Text(
                      "聊天",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    //间隔
                    const SizedBox(height: 20.0),

                    //白色卡片背景
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: const Color(0xFFF2F2F2), // 边框颜色
                          width: 1.0, // 边框宽度
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                   /*
                      ┌─────────────────────────────────────┐
                      │ 账号                                  │ ← 标签
                      │                                     │
                      │  ┌─────────────────────────────────┐ │
                      │  │                                  │ │
                      │  │  请输入内容             0/30     │ │ ← 输入框 + 右侧suffix
                      │  │                                  │ │
                      │  └─────────────────────────────────┘ │
                      └─────────────────────────────────────┘*/
                          // 账号输入框
                          CustomTextField(
                            labelText: "账号",
                            controller: controller.usernameController,
                            inputLimit: 30,
                            onChanged: controller.onAccountTextChanged,
                            suffix: Text('${controller.accountTextLength}/30'),
                          ),
                          //间隔
                          const SizedBox(height: 15.0),
                          //密码输入框
                          CustomTextField(
                            labelText: "密码",
                            controller: controller.passwordController,
                            obscureText: true,
                            inputLimit: 16,
                            onChanged: controller.onPasswordTextChanged,
                            suffix: Text('${controller.passwordTextLength}/16'),
                          ),
                          //间隔
                          const SizedBox(height: 20.0),

                          //可以让子组件按照父容器尺寸的一定比例来设置大小
                          FractionallySizedBox(
                            widthFactor: 0.8,
                            //todo 给登录按钮加一个点击效果
                            child: ElevatedButton(
                              onPressed: () => controller.login(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                //backgroundColor = 按钮的背景颜色
                                backgroundColor: const Color(0xFF4C9BFF),
                                //foregroundColor = 按钮上所有内容（文字、图标）的颜色
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                "登  录",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          //上下分割
                          const SizedBox(height: 10.0),

                          //忘记密码与注册
                          TextButton(
                            onPressed: () => controller.toRetrievePassword(),
                            child: const Text(
                              "忘记密码",
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => controller.toRegister(),
                            child: const Text(
                              "注册账号",
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            )
            ),
        )
    );
  }
}
