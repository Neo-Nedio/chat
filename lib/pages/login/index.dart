import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../components/custom_button/index.dart';
import '../../components/custom_gradient_line/index.dart';
import '../../components/custom_material_button/index.dart';
import '../../components/custom_shadow_text/index.dart';
import '../../components/custom_text_field/index.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';


class LoginPage extends CustomWidget<LoginPageLogic>  {
  LoginPage({super.key});

/*
┌─────────────────────────────────────────────┐
│  🌈 渐变背景 (浅蓝→白)                        │
│  ═══════════════════════════════════════════ │
│  ↑ SafeArea                                   │
│  ┌─────────────────────────────────────────┐ │
│  │  SingleChildScrollView                   │ │
│  │  ┌─────────────────────────────────────┐│ │
│  │  │  Column                              ││ │
│  │  │                                      ││ │
│  │  │  ┌─────────────────────────────────┐││ │
│  │  │  │  Row (头部)                     │││ │
│  │  │  │  ┌──────────┐  ┌────────────┐  │││ │
│  │  │  │  │ HELLO    │  │  Logo      │  │││ │
│  │  │  │  │ 欢迎使用  │  │  (120px)   │  │││ │
│  │  │  │  └──────────┘  └────────────┘  │││ │
│  │  │  └─────────────────────────────────┘││ │
│  │  │                                      ││ │
│  │  │  ┌─────────────────────────────────┐││ │
│  │  │  │  白色卡片                        │││ │
│  │  │  │  ┌─────────────────────────────┐│││ │
│  │  │  │  │ 账号: [🔑] 请输入... 0/30  ││││ │
│  │  │  │  └─────────────────────────────┘│││ │
│  │  │  │  ┌─────────────────────────────┐│││ │
│  │  │  │  │ 密码: [🔒] 请输入... 0/16  ││││ │
│  │  │  │  └─────────────────────────────┘│││ │
│  │  │  │  ┌─────────────────────────────┐│││ │
│  │  │  │  │         忘记密码?            ││││ │
│  │  │  │  └─────────────────────────────┘│││ │
│  │  │  │  ┌─────────────────────────────┐│││ │
│  │  │  │  │      [立即登录] 渐变按钮     ││││ │
│  │  │  │  └─────────────────────────────┘│││ │
│  │  │  │  ┌─────────────────────────────┐│││ │
│  │  │  │  │  没有账号?  立即注册         ││││ │
│  │  │  │  └─────────────────────────────┘│││ │
│  │  │  │  ┌─────────────────────────────┐│││ │
│  │  │  │  │  ─── 相关地址 ───           ││││ │
│  │  │  │  │  [GitHub]  [B站]            ││││ │
│  │  │  │  └─────────────────────────────┘│││ │
│  │  │  └─────────────────────────────────┘││ │
│  │  │                                      ││ │
│  │  └─────────────────────────────────────┘│ │
│  └─────────────────────────────────────────┘ │
│  ↓ SafeArea                                   │
└─────────────────────────────────────────────┘
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
    //获取屏幕高度
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // 用于控制当键盘弹出时，页面是否自动调整大小以避免键盘遮挡输入框。
      resizeToAvoidBottomInset: false,
      body: Container(
        //明确说明要占满
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.minorColor,
              const Color(0xFFFFFFFF),
              const Color(0xFFFFFFFF),
              const Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,      // 渐变起点：左上角
            end: Alignment.bottomRight,    // 渐变终点：右下角
          ),
        ),
        child: SafeArea(
          //让弹出键盘时，用户可用向上移动屏幕，看清输入
            child: SingleChildScrollView(
              child: SizedBox(
                //得出可用高度
              /*总容器高度 = screenHeight - topPadding - bottomPadding
              内容区域高度 = 总容器高度 - (上下padding之和)
              内容起始位置 = 距离顶部 topPadding + padding.top*/
                height: screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,

                child: Column(
                  children: [
                    //顶部间隔
                    const SizedBox(height: 50.0),

                    //上部信息
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //文字
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //带特殊效果
                              CustomShadowText(
                                text: 'HELLO',
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                shadowTop: 22,
                              ),
                              Text(
                                "欢迎使用，Chat",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 10),

                          //图标
                          Flexible( //允许图片在主轴方向灵活调整，但受到父级布局约束。
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 120,
                              ),
                              child: Image.asset(
                                'assets/images/logo-login.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // 登录框部分
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(30.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: const Color(0xFFF2F2F2),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //输入框
                            Obx(
                                  () => CustomTextField(
                                hintText: '请输入账号',
                                iconData: const IconData(0xe60d,
                                    fontFamily: 'IconFont'),
                                controller: controller.usernameController,
                                inputLimit: 30,
                                onChanged: controller.onAccountTextChanged,
                                suffix: Text(
                                    '${controller.accountTextLength.value}/30'),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Obx(
                                  () => CustomTextField(
                                hintText: '请输入密码',
                                iconData: const IconData(0xe620,
                                    fontFamily: 'IconFont'),
                                controller: controller.passwordController,
                                obscureText: true,
                                inputLimit: 16,
                                onChanged: controller.onPasswordTextChanged,
                                suffix: Text(
                                    '${controller.passwordTextLength.value}/16'),
                              ),
                            ),
                            //忘记密码
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      Get.toNamed('/set_ip'),
                                  child: const Text(
                                    "设置访问ip",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFb0b0ba),
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      controller.toRetrievePassword(),
                                  child: const Text(
                                    "忘记密码?",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFb0b0ba),
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //登录按钮
                            CustomButton(
                              text: '立即登录',
                              type: 'gradient',
                              onTap: () => controller.login(context),
                              width: MediaQuery.of(context).size.width,
                            ),
                            const SizedBox(height: 5.0),
                            //注册按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text( //文字
                                  "没有账号?",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFb0b0ba),
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(//注册按钮
                                  onPressed: () => controller.toRegister(),
                                  child: Text(
                                    "立即注册",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.primaryColor,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //底部内容
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //渐变效果的线条
                                      CustomGradientLine(
                                        width: 80,
                                        height: 1.5,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Color(0xFFb0b0ba)
                                          ],
                                        ),
                                      ),
                                      Text(
                                        " 相关地址 ",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFb0b0ba),
                                        ),
                                      ),
                                      //渐变效果的线条
                                      CustomGradientLine(
                                        width: 80,
                                        height: 1.5,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFb0b0ba),
                                            Colors.white
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 15),

                                  //图标(带链接)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //github
                                      CustomMaterialButton(
                                        child: const Icon(
                                          IconData(0xe6f6,
                                              fontFamily: 'IconFont'),
                                          size: 36.0,
                                          color: Color(0xFFb0b0ba),
                                        ),
                                        onTap: () => controller.launchURL(
                                            'https://github.com/DWHengr/linyu_mobile'),
                                      ),
                                      const SizedBox(width: 15),
                                      //b站
                                      CustomMaterialButton(
                                        child: const Icon(
                                          IconData(0xe600,
                                              fontFamily: 'IconFont'),
                                          size: 36.0,
                                          color: Color(0xFFb0b0ba),
                                        ),
                                        onTap: () => controller.launchURL(
                                            'https://space.bilibili.com/135427028/channel/series'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
            ),
        )
    );
  }
}
