import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/custom_label_value/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class AboutPage extends CustomWidget<AboutLogic> {
  AboutPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient( // 渐变颜色
          colors: [theme.minorColor, const Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        //标题
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('关于我们'),
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              //与顶部间隔
              const SizedBox(height: 30),
              //头像
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                ),
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 80,
                ),
              ),

              //上下间隔
              const SizedBox(height: 10),

              //文字图片
              Image.asset(
                "assets/images/linyu.png",
                height: 30,
              ),

              //上下间隔
              const SizedBox(height: 30),

              const CustomLabelValue(label: '作者', value: "Heath", width: 80),

              const SizedBox(height: 1),

              const CustomLabelValue(
                  label: 'QQ群', value: "729158695", width: 80),

              const SizedBox(height: 1),

              const CustomLabelValue(
                  label: '开源地址',
                  value: "https://github.com/DWHengr/linyu_mobile",
                  width: 80),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "基于",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    "assets/images/flutter.png",
                    height: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "开发",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
