import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../api/qr_api.dart';

class QRCodeScanLogic extends GetxController {
  final _qrApi = QrApi();
  String? qrText; // 存储扫描到的二维码内容
  final player = AudioPlayer(); // 音频播放器
  bool isScanning = true; // 是否正在扫描（防重复扫描）

  final scannerController = MobileScannerController( // 摄像头控制器
    detectionSpeed: DetectionSpeed.noDuplicates, //检测到二维码后，同一二维码不再重复触发
    returnImage: false, //控制是否返回摄像头捕获的图像数据。（不返回图像，性能好）
  );

  //检测扫描结果
  Future<void> onDetect(BarcodeCapture capture) async {
    // 1. 安全检查
    if (!isScanning) return; // 正在处理中，忽略新的扫描
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return; // 没有扫描到任何码
    final String? code = barcodes.first.rawValue; //rawValue是二维码的原始内容
    if (code == null || code.isEmpty) return; // 二维码内容无效

    //更新UI状态
    qrText = code; // 保存扫描结果
    isScanning = false; // 停止扫描
    //暂停摄像头（节省资源）
    await scannerController.pause();
    update([const Key("qr_code_scan")]);


    // 4. 播放成功提示音
    await player.play(AssetSource('sounds/success.mp3'));

    // 5. 调用API验证二维码
    final result = await _qrApi.status(qrText);

    // 6. 根据API返回结果处理
    if (result['code'] == 0) {
      switch (result['data']['action']) {
        case 'login':
          Get.toNamed('/qr_login_affirm', arguments: {'qrCode': qrText});
          break;
        case 'mine':
          Get.toNamed('/qr_friend_affirm',
              arguments: {'result': result['data']['extend']});
          break;
        default:
          Get.toNamed('/qr_other_result',
              arguments: {'text': "二维码内容无法识别或已失效"});
          break;
      }
    } else {
      Get.toNamed('/qr_other_result', arguments: {'text': "二维码内容无法识别或已失效"});
    }
  }

  //重新扫描
  void restartScanning() {
    qrText = null; // 清空扫描结果
    isScanning = true; // 恢复扫描状态
    scannerController.start(); // 重新启动摄像头
    update([const Key("qr_code_scan")]);
  }

  @override
  void onClose() {
    scannerController.dispose();
    player.dispose();
    super.onClose();
  }
}
