import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../components/app_bar_title/index.dart';
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
        title: const AppBarTitle('扫一扫'),
        backgroundColor: const Color(0xFFF9FBFF),
      ),

      //主体内容
      body: Stack(
        children: [

          // 主内容：摄像头 + 底部文字
          Column(
            children: <Widget>[
              //摄像头预览区域
              Expanded(
                flex: 5,  // 摄像头占5份高度
                child:  MobileScanner(
                  controller: controller.scannerController,  // 控制摄像头
                  onDetect: controller.onDetect,             // 扫描回调
                  //MobileScanner 在布局阶段会先把自己的预览区域尺寸确定下来（来自外层 Expanded/父级约束）
                  //MobileScanner 内部会再为 overlayBuilder 提供一个“覆盖层容器”（通常就是一个和预览画面同尺寸的布局/绘制区域）。
                  //因为这个覆盖层容器会把约束（constraints）传给 overlayBuilder，
                  //所以在 overlayBuilder 里返回的 Stack，在 Flutter 布局里会被放到这个容器中，并按照该容器的约束去布局
                  overlayBuilder: (context, constraints) { // 自定义覆盖层
                   return Stack( //
                    children: [
                     CustomPaint(
                     //size为整个MobileScanner的大小
                     size: Size(constraints.maxWidth, constraints.maxHeight),
                     //背景层 (先绘制)
                     painter: ScannerOverlayPainter(), // 绘制半透明遮罩(中间透明)
                     // 前景层 (后绘制，在上面)
                     child: Stack( //内部stack和外部stack一样大
                      children: [
                        // 四个角装饰(中间透明区域)
                        ...buildCorners(constraints),

                        // 手电筒按钮
                        Positioned(
                          bottom: 40,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.flashlight_on,
                                  color: Colors.white),
                            onPressed: () {
                              controller.scannerController
                                  .toggleTorch();  // 开关闪光灯
                                },
                               ),
                              ),
                             ),
                            ],
                           ),
                          ),
                         ],
                       );
                      },
                    ),
                  ),

              //底部提示文字
              Expanded(
                flex: 1,
                child: Container(
                  color: const Color(0xFFF9FBFF),
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
  //绘制扫描框的四个角装饰
  List<Widget> buildCorners(constraints) {
    return [
      // 左上角
      //从摄像区域中心(宽高减半到就是摄像区域中心），向上移动125，向左移动125(透明框是120，设置125是为了有些许出去)
      //通过边框为蓝，增加视觉效果
      Positioned(
        top: constraints.maxHeight / 2 - 125,
        left: constraints.maxWidth / 2 - 125,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.primaryColor, width: 4),
              left: BorderSide(color: theme.primaryColor, width: 4),
            ),
          ),
        ),
      ),
      // 右上角
      Positioned(
        top: constraints.maxHeight / 2 - 125,
        right: constraints.maxWidth / 2 - 125,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.primaryColor, width: 4),
              right: BorderSide(color: theme.primaryColor, width: 4),
            ),
          ),
        ),
      ),
      // 左下角
      Positioned(
        bottom: constraints.maxHeight / 2 - 125,
        left: constraints.maxWidth / 2 - 125,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.primaryColor, width: 4),
              left: BorderSide(color: theme.primaryColor, width: 4),
            ),
          ),
        ),
      ),
      // 右下角
      Positioned(
        bottom: constraints.maxHeight / 2 - 125,
        right: constraints.maxWidth / 2 - 125,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.primaryColor, width: 4),
              right: BorderSide(color: theme.primaryColor, width: 4),
            ),
          ),
        ),
      ),
    ];
  }
}


/*

┌─────────────────────────────────────────┐
│ ██████████████████████████████████████ │ ← 半透明黑色 (50%透明度)
│ ██████████████████████████████████████ │
│ ██████████████████████████████████████ │
│ ██████                           ██████ │
│ ██████        ┌─────────┐        ██████ │
│ ██████        │         │        ██████ │ ← 透明扫描区域
│ ██████        │  透明   │        ██████ │   (摄像头画面显示)
│ ██████        │         │        ██████ │
│ ██████        └─────────┘        ██████ │
│ ██████                           ██████ │
│ ██████████████████████████████████████ │
│ ██████████████████████████████████████ │
└─────────────────────────────────────────┘
*/

class ScannerOverlayPainter extends CustomPainter {
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false; // 不需要重绘

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)  // 50% 不透明度
      ..style = PaintingStyle.fill; // 填充模式

    // 扫描区域（透明区域）
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),  // 指定"中心点在哪里"
      width: 240,   // 扫描框宽度
      height: 240,  // 扫描框高度
    );

    // 创建路径：整个屏幕减去扫描区域
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height)) // ① 添加整个屏幕
      ..addRRect(RRect.fromRectAndRadius( // ② 添加扫描区域
        centerRect,
        const Radius.circular(1), // 轻微圆角
      ));

    //路径填充模式
    canvas.drawPath(path..fillType = PathFillType.evenOdd, paint);
    /* evenOdd 填充规则：从任意点向外画射线，数穿过路径边界的次数：
    - 奇数 → 填充
    - 偶数 → 不填充（挖空）
    点 A (在屏幕内，扫描区外):
  ┌─────────────────────┐
  │  A → 射线 → 穿过1次边界 │ 奇数 → 填充 ✅
  └─────────────────────┘

点 B (在扫描区内):
  ┌─────────────────────┐
  │    ┌─────────┐      │
  │    │  B →    │      │  射线穿过2次边界
  │    │  射线   │      │  (第一次进入矩形，第二次离开)
  │    └─────────┘      │  偶数 → 不填充 ❌
  └─────────────────────┘
  因此扫码框可以空出*/
  }
}
