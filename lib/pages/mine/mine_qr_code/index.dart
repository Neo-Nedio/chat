import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../components/custom_portrait/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class MineQRCodePage extends CustomWidget<MineQRCodeLogic> {
  MineQRCodePage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
/*
    ┌─────────────────────────────────────────┐
    │  渐变背景 (浅蓝→白色)                    │
    │  ┌─────────────────────────────────────┐ │
    │  │  白色卡片容器                        │ │
    │  │  ┌─────────────────────────────────┐ │
    │  │  │  圆形头像 (80x80)               │ │
    │  │  │  姓名: Heath                     │ │
    │  │  │  账号: heath                     │ │
    │  │  │  ┌─────────────────────────┐    │ │
    │  │  │  │  二维码区域              │    │ │
    │  │  │  │  (带渐变遮罩 + 中心Logo) │    │ │
    │  │  │  └─────────────────────────┘    │ │
    │  │  └─────────────────────────────────┘ │
    │  │                                       │
    │  └─────────────────────────────────────┘ │
    │  提示文字: "扫描二维码，添加我为好友"      │
    └─────────────────────────────────────────┘
    */
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.minorColor, const Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,      // 渐变起点：左上角
              end: Alignment.bottomRight,    // 渐变终点：右下角
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // 垂直居中
            crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Container(
                    height: 350,                    // 固定高度350
                    width: double.infinity,         // 宽度填满
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),

                    child: Transform.translate(
                      offset: const Offset(0, -40), // 向上偏移40像素
                      child: Column(
                        children: [
                          //头像
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              //白色边框
                              border: Border.all(
                                color: Colors.white,
                                width: 5,
                              ),
                              borderRadius: BorderRadius.circular(40), // 圆形
                            ),
                            child: CustomPortrait(
                                url: // 头像URL
                                controller.currentUserInfo['portrait'] ?? '',
                                size: 80,
                                radius: 40),
                          ),
                          //用户信息
                          Text( // 显示名称
                            controller.currentUserInfo['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Text( // 账号
                            controller.currentUserInfo['account'] ?? '',
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF7D7D7D)),
                          ),

                          //二维码区域
                          Expanded( //占据剩余空间
                            //Stack	叠加二维码和中心Logo
                            child: Stack(  // 叠加组件
                            alignment: Alignment.center,  // 所有子组件居中对齐
                              children: [
                                // 底层：渐变遮罩 + 二维码
                                //ShaderMask	给二维码添加渐变色彩效果
                                ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return  LinearGradient(  //渐变
                                      colors: [
                                        theme.primaryColor,
                                        theme.qrColor
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcATop, // 混合模式：源在目标上,渐变颜色叠加在二维码上
                                  //QrImageView	生成并显示二维码
                                  child: QrImageView(  // 二维码组件
                                    data: controller.qrCode, // 二维码内容
                                    version: QrVersions.auto,  // 自动选择版本
                                    padding: const EdgeInsets.all(5),
                                    size: 200.0,
                                    eyeStyle: const QrEyeStyle( // 眼睛样(三个角的样式)
                                      color: Colors.black,
                                    ),
                                    //embeddedImageStyle	允许在二维码中心嵌入图片
                                    embeddedImageStyle:
                                        const QrEmbeddedImageStyle( // 嵌入图片大小
                                      size: Size(50, 50),
                                    ),
                                  ),
                                ),
                                // 顶层：中心Logo
                                Container(
                                  width: 40,
                                  height: 40,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.white,
                                  ),
                                  child: Image.asset(
                                      'assets/images/logo-qr-${theme.themeMode}.png'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text("扫描二维码，添加我为好友")
            ],
          )),
    );
  }
}
