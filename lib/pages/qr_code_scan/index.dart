import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../api/qr_api.dart';
import '../../components/custom_button/index.dart';
import '../qr_login_affirm/index.dart';

final _qrApi = QrApi();

//pc端扫描登录
class QRCodeScannerPage extends StatefulWidget {
  const QRCodeScannerPage({super.key});

  @override
  State<StatefulWidget> createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  late final MobileScannerController _scannerController;  // 摄像头控制器
  String? qrText;           // 存储扫描到的二维码内容
  final player = AudioPlayer();  // 音频播放器
  bool _isScanning = true;  // 是否正在扫描（防重复扫描）

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(); // 初始化摄像头控制器
  }

  @override
  //reassemble() 是 Flutter 中的一个生命周期方法，专门用于热重载（Hot Reload）场景。
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {  // 判断是否为Android平台
      /*Android 的摄像头是独占式的：一个应用占用后，其他应用无法使用
      热重载时，Flutter 重新构建 UI，但摄像头资源可能还处于被占用状态
      如果不先释放（stop），直接启动（start）可能会失败*/
      unawaited(  // 不等待Future完成，避免阻塞UI
        _scannerController.stop()  // 先停止摄像头
            .then((_) => _scannerController.start()),  // 停止后再启动
      );
    } else {
      /*iOS 的摄像头系统设计更加容错
      支持"优雅恢复"：热重载后能自动重建连接*/
      unawaited(_scannerController.start());  // 非Android平台直接启动
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // 标题栏
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
                  fit: StackFit.expand,  // 子组件铺满整个Stack
                  children: [
                    // 真正的摄像头预览
                    MobileScanner(
                      controller: _scannerController,  // 绑定控制器
                      onDetect: _onDetect,  // 扫描到二维码的回调
                    ),
                    // 扫描框（覆盖在摄像头预览上面）
                    Center(
                      child: IgnorePointer( // 忽略触摸事件，让触摸穿透到下面的摄像头
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF4C9BFF),  // 蓝色边框
                              width: 8,  // 边框宽度
                            ),
                            borderRadius: BorderRadius.circular(1),  // 轻微圆角
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),

          ///动态提示层
          if (qrText != null && _isScanning)
            Center( // 扫描成功提示
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
          if (qrText != null && !_isScanning)
            Center(  // 重新扫描按钮
              child: CustomButton(
                text: '重新扫描',
                onTap: _restartScanning, //重新扫描函数
                type: 'minor',
                width: 120,
              ),
            ),
        ],
      ),
    );
  }

  //检测扫描结果
  Future<void> _onDetect(BarcodeCapture capture) async {
    // 1. 安全检查
    if (!_isScanning) return;  // 正在处理中，忽略新的扫描
    //capture包含了一次扫描到的所有二维码信息
    //capture.barcodes 是一个 List<Barcode>（二维码列表），因为一次扫描可能同时识别到多个二维码
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;  // 没有扫描到任何码
    final String? code = barcodes.first.rawValue; //rawValue是二维码的原始内容
    if (code == null || code.isEmpty) return;  // 二维码内容无效

    // 2. 更新UI状态
    setState(() {
      qrText = code;  // 保存扫描结果
      _isScanning = false;  // 停止扫描
    });

    // 3. 暂停摄像头（节省资源）
    await _scannerController.pause();

    // 4. 播放成功提示音
    await player.play(AssetSource('sounds/success.mp3'));

    // 5. 调用API验证二维码
    final result = await _qrApi.status(code);

    // 6. 检查页面是否还在（防止异步完成后页面已关闭）
    //mounted 是 Flutter 中每个 State 类都自带的布尔属性，用于判断当前 State 对象是否仍然附着在 widget 树上。
    if (!mounted) return;

    // 7. 根据API返回结果处理
    if (result['code'] == 0) {
      switch (result['data']['action']) {
        case 'login':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QrLoginAffirmPage(qrCode: code),
            ),
          );
          break;
      }
    }
  }

  //重新扫描
  void _restartScanning() {
    setState(() {
      qrText = null;        // 清空扫描结果
      _isScanning = true;    // 恢复扫描状态
    });
    unawaited(_scannerController.start());  // 重新启动摄像头
  }

  @override
  void dispose() {
    unawaited(_scannerController.dispose());
    player.dispose();
    super.dispose();
  }
}
