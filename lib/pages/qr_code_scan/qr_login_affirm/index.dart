import 'package:flutter/material.dart';

import '../../../components/custom_button/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';


//用户扫描二维码后，确认登录的界面
class QrLoginAffirmPage extends CustomWidget<QRLoginAffirmLogic> {
  QrLoginAffirmPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      // 背景色：浅蓝色
      backgroundColor: const Color(0xFFF9FBFF),
      // 标题栏
      appBar: AppBar(
        centerTitle: true,  // 标题居中
        title: const Text('登录确认'),
        backgroundColor: const Color(0xFFF9FBFF),  // 与背景同色
      ),

      // 主体内容
      body: Padding(
        // 上下间距100，左右间距20
        padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 20.0),
        child: Center(
          child: Column(
            // 主轴方向：两端分布（顶部图片，底部按钮）
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // 交叉轴：居中
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // 上半部分：图片和文字
              Column(
                children: [
                  // 插图（可能是电脑图标）
                  Image.asset('assets/images/qr-affirm.png', width: 180),
                  const SizedBox(height: 10),  // 间距
                  const Text(
                    '电脑版本请求登录',  // 提示文字
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),

              // 下半部分：两个按钮
              Column(
                children: [
                  // 确认登录按钮
                  CustomButton(
                    text: '确认登录',
                    onTap: controller.onQrLogin,  // 点击调用登录方法
                    width: 220,
                  ),

                  const SizedBox(height: 10),  // 按钮间距

                  // 取消按钮
                  CustomButton(
                    text: '取消',
                    type: 'minor',  // 次要按钮样式
                    onTap: () {
                      // TODO: 添加返回功能
                      // 建议：Navigator.pop(context);
                    },
                    width: 220,
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
