import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../api/user_api.dart';
import '../../components/custom_button/index.dart';


final _userAPi = UserApi();

//用户扫描二维码后，确认登录的界面
class QrLoginAffirmPage extends StatefulWidget {
  final String? qrCode; // 从扫码页面传来的二维码内容

  const QrLoginAffirmPage({super.key, required this.qrCode});

  @override
  State<StatefulWidget> createState() => _QrLoginAffirmPagePageState();
}

class _QrLoginAffirmPagePageState extends State<QrLoginAffirmPage> {
  // 点击确认登录按钮时调用
  void _onQrLogin() {
    // 调用登录API，传入二维码
    _userAPi.qrLogin(widget.qrCode).then((res) {

      // 如果登录成功（code为0）
      if (res['code'] == 0) {
        // 显示Toast提示
        Fluttertoast.showToast(
            msg: "登录成功~",  // 提示信息
            toastLength: Toast.LENGTH_SHORT,  // 显示时长
            gravity: ToastGravity.TOP,  // 显示位置（顶部）
            timeInSecForIosWeb: 1,  // iOS/Web显示时间
            backgroundColor: const Color(0xFF4C9BFF),  // 蓝色背景
            textColor: Colors.white,  // 白色文字
            fontSize: 16.0);
      }

      // 无论成功失败，都跳转到首页，并清除所有历史路由
      Get.offAllNamed("/");
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: _onQrLogin,  // 点击调用登录方法
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
