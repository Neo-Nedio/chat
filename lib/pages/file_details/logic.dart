import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../components/custom_flutter_toast/index.dart';
import '../../utils/getx_config/GlobalData.dart';

class FileDetailsLogic extends GetxController {
  late String fileName;      // 文件名
  late String fileUrl;       // 文件下载URL
  late String fileType;      // 文件类型（如.pdf, .jpg等）
  late int fileSize;         // 文件大小（字节）

  RxDouble downloadProgress = 0.0.obs;      // 下载进度 0.0-1.0
  RxBool isDownloading = false.obs;          // 是否正在下载
  bool isDownloaded = false;      // 是否已下载完成
  String? localFilePath;          // 本地文件路径
  CancelToken? cancelToken;       // 用于取消下载的令牌

  GlobalData get globalData => GetInstance().find<GlobalData>();

  @override
  void onInit() {
    super.onInit();
    fileName = Get.arguments['fileName'];
    fileUrl = Get.arguments['fileUrl'];
    fileType = Get.arguments['fileType'];
    fileSize = Get.arguments['fileSize'];
    checkFileExists(); //检查文件是否存在
  }

  //检查文件是否存在
  Future<void> checkFileExists() async {
    final localPath = await getLocalFilePath();  // 获取本地存储路径
    var file = File(localPath);                  // 创建文件对象

    // 文件存在且大小匹配，说明已下载完成
    if (file.existsSync() && file.lengthSync() == fileSize) {
      isDownloaded = true;
      localFilePath = localPath;
      update([const Key('file_details')]);  // 手动更新UI
    }
  }

  // 获取本地存储路径
  Future<String> getLocalFilePath() async {
    final directory = await getTemporaryDirectory(); // 获取临时目录
    //临时目录/用户账号/文件名
    return '${directory.path}/${globalData.currentUserAccount}/$fileName';
  }

  //开始下载
  Future<void> startDownload() async {
    if (isDownloading.value) { // 防止重复下载
      return;
    }

    isDownloading.value = true;      // 设置下载状态为true
    cancelToken = CancelToken();     // 创建取消令牌

    try {
      final dio = Dio();             // 创建Dio实例
      final localPath = await getLocalFilePath();  // 目标保存路径

      await dio.download(
        fileUrl,                     // 下载地址
        localPath,                   // 保存路径
        cancelToken: cancelToken,    // 取消令牌
        onReceiveProgress: (received, total) {  // 进度回调
          if (total != -1) {         // total为-1表示无法获取总大小
            downloadProgress.value = received / total;  // 计算进度百分比
          }
        },
      );

      // 下载成功
      isDownloaded = true;
      localFilePath = localPath;
    } on DioException catch (e) {  // 捕获Dio异常
      if (CancelToken.isCancel(e)) {  // 判断是否为主动取消
        CustomFlutterToast.showSuccessToast('下载已取消~');
      } else {
        CustomFlutterToast.showErrorToast('下载失败，请稍后再试~');
      }
    } finally {
      isDownloading.value = false; // 无论成功或失败，重置下载状态
      update([const Key('file_details')]);
    }
  }

  //取消下载
  void cancelDownload() {
    if (!isDownloading.value) return;  // 不在下载中则直接返回

    cancelToken?.cancel('下载取消');    // 取消下载，参数为取消原因
    downloadProgress.value = 0.0;       // 重置进度
    isDownloading.value = false;        // 重置下载状态

    update([const Key('file_details')]); // 更新UI
  }

  //打开文件
  Future<void> openFile() async {
    if (localFilePath != null) {
      OpenResult result = await OpenFilex.open(localFilePath!);
      // 处理打开结果
      if (result.type == ResultType.noAppToOpen) {
        CustomFlutterToast.showErrorToast('没有找到对应的打开方式~');
      }
      if (result.type == ResultType.permissionDenied) {
        CustomFlutterToast.showErrorToast('权限不足，无法打开文件~');
      }
    }
  }
}
