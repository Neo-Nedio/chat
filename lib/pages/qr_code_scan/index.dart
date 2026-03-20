import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../components/custom_button/index.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';


//pc端扫描登录
class QRCodeScanPage extends CustomWidget<QRCodeScanLogic> {
  QRCodeScanPage({super.key});


  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 标题栏
        centerTitle: true,
        title: const Text('扫一扫'),
        backgroundColor: const Color(0xFFF9FBFF),
      ),

      //主体内容
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              //摄像头预览区域
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand, // 子组件铺满整个Stack
                  children: [
                    // 真正的摄像头预览
                    MobileScanner(
                      controller: controller.scannerController, // 绑定控制器
                      onDetect: controller.onDetect, // 扫描到二维码的回调
                    ),
                    // 扫描框（覆盖在摄像头预览上面）
                    Center(
                      child: IgnorePointer(
                        // 忽略触摸事件，让触摸穿透到下面的摄像头
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF4C9BFF), // 蓝色边框
                              width: 8, // 边框宽度
                            ),
                            borderRadius:
                                BorderRadius.circular(1), // 轻微圆角
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //底部提示文字
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.tealAccent.withValues(alpha: 0.1), // 半透明背景
                  child: const Center(
                    child: Text(
                      '请对准二维码扫描',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),

          ///动态提示层
          if (controller.qrText != null && controller.isScanning)
            Center(
              // 扫描成功提示
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54, // 半透明黑色背景
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "扫描成功~",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          if (controller.qrText != null && !controller.isScanning)
            Center(
              // 重新扫描按钮
              child: CustomButton(
                text: '重新扫描',
                onTap: controller.restartScanning, //重新扫描函数
                type: 'minor',
                width: 120,
              ),
            ),
        ],
      ),
    );
  }
}
