import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../api/qr_api.dart';

class QRCodeScanLogic extends GetxController {
  final _qrApi = QrApi();
  late final MobileScannerController scannerController; // 摄像头控制器
  String? qrText; // 存储扫描到的二维码内容
  final player = AudioPlayer(); // 音频播放器
  bool isScanning = true; // 是否正在扫描（防重复扫描）

  @override
  void onInit() {
    super.onInit();
    //初始化控制器
    scannerController = MobileScannerController();
  }

  @override
  void onReady() {
    super.onReady();
    if (GetPlatform.isAndroid) {
      /*Android 的摄像头是独占式的：一个应用占用后，其他应用无法使用
      热重载时，Flutter 重新构建 UI，但摄像头资源可能还处于被占用状态
      如果不先释放（stop），直接启动（start）可能会失败*/
      unawaited(// 不等待Future完成，避免阻塞UI
         scannerController.stop()// 先停止摄像头
             .then((_) => scannerController.start())); // 停止后再启动
    }else {//else防止重复启动
      /*iOS 的摄像头系统设计更加容错
      支持"优雅恢复"：热重载后能自动重建连接*/
      unawaited(scannerController.start()); // 非Android平台直接启动
    }
  }

  //检测扫描结果
  Future<void> onDetect(BarcodeCapture capture) async {
    // 1. 安全检查
    if (!isScanning) return; // 正在处理中，忽略新的扫描
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return; // 没有扫描到任何码
    final String? code = barcodes.first.rawValue; //rawValue是二维码的原始内容
    if (code == null || code.isEmpty) return; // 二维码内容无效

    // 2. 更新UI状态
    qrText = code; // 保存扫描结果
    isScanning = false; // 停止扫描
    update();

    // 3. 暂停摄像头（节省资源）
    await scannerController.pause();

    // 4. 播放成功提示音
    await player.play(AssetSource('sounds/success.mp3'));

    // 5. 调用API验证二维码
    final result = await _qrApi.status(code);

    // 6. 根据API返回结果处理
    if (result['code'] == 0) {
      switch (result['data']['action']) {
        case 'login':
          Get.toNamed('/qr_login_affirm', arguments: {'qrCode': code});
          break;
      }
    }
  }

  //重新扫描
  void restartScanning() {
    qrText = null; // 清空扫描结果
    isScanning = true; // 恢复扫描状态
    update();
    unawaited(scannerController.start()); // 重新启动摄像头
  }

  @override
  void onClose() {
    unawaited(scannerController.dispose());
    player.dispose();
    super.onClose();
  }
}
