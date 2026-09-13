import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../api/live_api.dart';
import '../../../components/custom_flutter_toast/index.dart';

class LiveStartLogic extends GetxController {
  final LiveApi _liveApi = LiveApi();
  // 预览轨道，后续进 LiveKit 房间时可复用发布
  final Rxn<LocalVideoTrack> previewTrack = Rxn<LocalVideoTrack>();
  final RxMap<String, dynamic> room = <String, dynamic>{}.obs;   // 直播间信息
  final RxBool previewReady = false.obs;                         // 预览是否就绪
  final RxBool isScreenSharing = false.obs;                      // 当前是否屏幕共享
  final RxBool isSwitchingSource = false.obs;                    // 是否正在切换源
  final RxBool isUploadingCover = false.obs;                     // 是否正在上传封面
  final RxBool isSavingTitle = false.obs;                        // 是否正在保存标题
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  bool _backgroundExecutionEnabled = false;                      // 后台服务是否已开启（不驱动 UI，用普通 bool）

  String get background => room['background']?.toString().trim() ?? '';
  String get portrait => room['portrait']?.toString().trim() ?? '';
  String get coverUrl => background.isNotEmpty ? background : portrait;  // 封面优先 background

  @override
  void onInit() {
    super.onInit();
    _loadRoomInfo();
    _prepareCameraPreview();
  }

  // 加载直播间信息，成功后灌进 room 并同步标题到输入框
  Future<void> _loadRoomInfo() async {
    try {
      final result = await _liveApi.info();
      if (result['code'] == 0 && result['data'] is Map) {
        room.assignAll(Map<String, dynamic>.from(result['data'] as Map));
        titleController.text = room['title']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('load live room info error: $e');
    }
  }

  // 准备摄像头预览：先要权限，再开摄像头
  Future<void> _prepareCameraPreview() async {
    try {
      final granted = await _requestMediaPermissions();
      if (!granted) return;
      await _openCamera();
    } catch (e) {
      debugPrint('open camera preview error: $e');
    }
  }

  // 请求摄像头和麦克风权限，任一未授权就提示并返回 false
  Future<bool> _requestMediaPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    if (!camera.isGranted || !microphone.isGranted) {
      CustomFlutterToast.showErrorToast('需要摄像头和麦克风权限');
      return false;
    }
    return true;
  }

  // 打开摄像头，创建本地视频轨道作为预览
  Future<void> _openCamera() async {
    final track = await LocalVideoTrack.createCameraTrack();
    await _setPreviewTrack(track, screenSharing: false);
  }

  // 打开屏幕共享：请求录屏权限，Android 额外开前台服务保活
  Future<void> _openScreen() async {
    final granted = await webrtc.Helper.requestCapturePermission();
    if (!granted) throw StateError('screen capture permission denied');
    if (Platform.isAndroid) {
      await _enableAndroidScreenShareService();
    }
    final track = await LocalVideoTrack.createScreenShareTrack();
    await _setPreviewTrack(track, screenSharing: true);
  }

  // Android 屏幕共享保活：启动前台服务，避免切后台被系统杀掉
  Future<void> _enableAndroidScreenShareService() async {
    if (_backgroundExecutionEnabled) return;
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: '正在准备直播',
      notificationText: '正在共享手机屏幕',
      notificationImportance: AndroidNotificationImportance.normal,
      notificationIcon: AndroidResource(
        name: 'ic_launcher',
        defType: 'mipmap',
      ),
    );
    final initialized = await FlutterBackground.initialize(
      androidConfig: androidConfig,
    );
    if (!initialized ||
        !await FlutterBackground.enableBackgroundExecution()) {
      throw StateError('foreground service unavailable');
    }
    _backgroundExecutionEnabled = true;
  }

  // 替换当前预览轨道：先设新轨道，再释放旧轨道
  Future<void> _setPreviewTrack(
      LocalVideoTrack track, {
        required bool screenSharing,
      }) async {
    final oldTrack = previewTrack.value;
    previewTrack.value = track;
    isScreenSharing.value = screenSharing;
    previewReady.value = true;
    await oldTrack?.dispose();
  }

  // 切换摄像头 / 屏幕共享源，失败时回退到摄像头
  Future<void> switchSource() async {
    if (isSwitchingSource.value) return;
    isSwitchingSource.value = true;
    try {
      if (isScreenSharing.value) {
        await _openCamera();
      } else {
        await _openScreen();
      }
    } catch (e) {
      CustomFlutterToast.showErrorToast(
        isScreenSharing.value ? '无法打开摄像头' : '当前设备不支持手机投屏',
      );
      if (!previewReady.value) {
        try {
          await _openCamera();
        } catch (_) {}
      }
    } finally {
      isSwitchingSource.value = false;
    }
  }

  // 跳图片选择页更换封面，确认后回调 uploadBackground
  Future<void> pickCover() async {
    if (isUploadingCover.value) return;
    await Get.toNamed('/image_viewer_update', arguments: {
      'imageUrl': coverUrl,
      'text': '更换封面',
      'onConfirm': uploadBackground,
      'isUpdate': true,
    });
  }

  // 上传封面，成功后就地更新 room['background'] 并 refresh
  Future<void> uploadBackground(File file) async {
    if (isUploadingCover.value) return;
    isUploadingCover.value = true;
    try {
      final result = await _liveApi.uploadBackground(file);
      if (result['code'] == 0) {
        room['background'] = result['data']?.toString() ?? '';
        room.refresh();
        CustomFlutterToast.showSuccessToast('封面更换成功');
      } else {
        CustomFlutterToast.showErrorToast(result['msg'] ?? '封面上传失败');
      }
    } catch (e) {
      debugPrint('upload live background error: $e');
      CustomFlutterToast.showErrorToast('封面上传失败');
    } finally {
      isUploadingCover.value = false;
    }
  }

  // 保存标题，成功后 Get.back() 返回上一页
  Future<void> saveTitle() async {
    if (isSavingTitle.value) return;
    final title = titleController.text.trim();
    if (title.isEmpty) {
      CustomFlutterToast.showErrorToast('标题不能为空');
      return;
    }
    isSavingTitle.value = true;
    try {
      final result = await _liveApi.updateTitle(title);
      if (result['code'] == 0) {
        room['title'] = title;
        room.refresh();
        Get.back();
        CustomFlutterToast.showSuccessToast('标题保存成功');
      } else {
        CustomFlutterToast.showErrorToast(result['msg'] ?? '标题保存失败');
      }
    } catch (e) {
      debugPrint('save live title error: $e');
      CustomFlutterToast.showErrorToast('标题保存失败');
    } finally {
      isSavingTitle.value = false;
    }
  }

  // 释放预览轨道；Android 上同时关闭后台服务
  Future<void> _disposePreviewTrack() async {
    final track = previewTrack.value;
    previewTrack.value = null;
    previewReady.value = false;
    await track?.dispose();
    if (Platform.isAndroid && _backgroundExecutionEnabled) {
      await FlutterBackground.disableBackgroundExecution();
      _backgroundExecutionEnabled = false;
    }
  }

  // 页面销毁时释放轨道、输入框、焦点节点
  @override
  void onClose() {
    _disposePreviewTrack();
    titleController.dispose();
    titleFocusNode.dispose();
    super.onClose();
  }
}