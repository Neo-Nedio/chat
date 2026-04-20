import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../components/app_bar_title/index.dart';
import '../../../../components/custom_portrait/index.dart';
import '../../../../utils/getx_config/config.dart';
import 'logic.dart';

class GroupQRCodePage extends CustomWidget<GroupQRCodeLogic> {
  GroupQRCodePage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      //渐变背景
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.minorColor, const Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        //标题
        appBar: AppBar(
          backgroundColor: Colors.transparent, //有标题有返回键，透明标题不影响页面效果
          title: const AppBarTitle(''),
          centerTitle: true,
        ),

        body: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
          crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                //白色框
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                  ),
                  child: Transform.translate(
                    offset: const Offset(0, -40), // 向上偏移
                    child: Column(
                      children: [
                        //群头像
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration( //白色圆框
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: CustomPortrait(
                              portrait:
                                  controller.groupInfo['portrait']?.toString() ??
                                      '',
                              size: 80,
                              radius: 40),
                        ),

                        //群名称
                        Text(
                          controller.groupInfo['name']?.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        //群号
                        Text(
                          '群号：${controller.groupInfo['chatGroupNumber']?.toString() ?? ''}',
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF7D7D7D)),
                        ),

                        //二维码区域
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    colors: [
                                      theme.primaryColor,
                                      theme.qrColor
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.srcATop,
                                child: QrImageView(
                                  data: controller.qrCode,
                                  version: QrVersions.auto,
                                  padding: const EdgeInsets.all(5),
                                  size: 200.0,
                                  eyeStyle: const QrEyeStyle(
                                    color: Colors.black,
                                  ),
                                  embeddedImageStyle:
                                      const QrEmbeddedImageStyle(
                                    size: Size(50, 50),
                                  ),
                                ),
                              ),
                              //中心 Logo
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

            const Text("扫描二维码，加入群聊")
          ],
        ),
      ),
    );
  }
}
