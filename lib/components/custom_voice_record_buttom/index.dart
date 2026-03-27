import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';

import '../../utils/getx_config/GlobalThemeConfig.dart';

//todo 按住说话的语音录制按钮，支持上滑取消、实时音波动画、时长限制等功能。
class CustomVoiceRecordButton extends StatefulWidget {
  final Function(String path, int time)? onFinish;

  const CustomVoiceRecordButton({super.key, this.onFinish});

  @override
  State<CustomVoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<CustomVoiceRecordButton> {
  final AudioRecorder _record = AudioRecorder();    // 录音器
  bool _isRecording = false;                        // 是否录音中
  bool _isCanceled = false;                         // 是否取消发送
  Offset _startPosition = Offset.zero;               // 按下起始位置
  Offset _currentPosition = Offset.zero;             // 当前手指位置
  OverlayEntry? _overlayEntry;                      // 浮动弹窗
  String? _filePath;                                // 录音文件路径
  Timer? _timer;                                    // 计时器
  int _recordingSeconds = 0;                        // 录音秒数
  List<double> _amplitudes = List.filled(20, 0.0);  // 音波数据（20个点）

  GlobalThemeConfig theme = Get.find<GlobalThemeConfig>();

  //开始录音
  void startRecording() async {
    // 振动反馈
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }

    // 获取临时目录
    final directory = await getTemporaryDirectory();
    _filePath = '${directory.path}/voice.wav';

    // 开始录音
    await _record.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,  // WAV 格式
        bitRate: 128000,            // 比特率
        sampleRate: 44100,          // 采样率
      ),
      path: _filePath!,
    );

    _startTimer();       // 开始计时
    _updateAmplitude();  // 开始采集音量
  }

  //计时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordingSeconds >= 60) {
        _stopRecording(autoStop: true); // 60秒自动停止
      } else {
        setState(() {
          _recordingSeconds++;
        });
      }
    });
  }

  //音量采集（音波动画）
  Future<void> _updateAmplitude() async {
    while (_isRecording) { //正在录音
      try {
        final amplitude = await _record.getAmplitude();
        // 将 dB 转换为 0-1 的值（dB范围约 -50 ~ 0）
        double normalizedAmplitude = (amplitude.current + 50) / 50;
        normalizedAmplitude = normalizedAmplitude.clamp(0.0, 1.0);

        setState(() {
          // 将现有数据左移，右侧添加新数据（形成滚动效果）
          for (int i = 0; i < _amplitudes.length - 1; i++) {
            _amplitudes[i] = _amplitudes[i + 1];
          }
          _amplitudes[_amplitudes.length - 1] = normalizedAmplitude;
        });
      } catch (e) {
        print(e);
      }
      await Future.delayed(const Duration(milliseconds: 50));  // 每秒20次
    }
  }

  //停止录音
  void _stopRecording({bool autoStop = false}) async {
    if (!_isRecording) return;
    _isRecording = false;
    _timer?.cancel();

    final filePath = await _record.stop();  // 停止录音

    // 移除浮动弹窗
    if (_overlayEntry?.mounted ?? false) {
      _overlayEntry?.remove();
    }
    _overlayEntry = null;

    // 根据状态回调
    if (!_isCanceled && !autoStop && filePath != null) {
      widget.onFinish?.call(filePath, _recordingSeconds);  // 正常发送
    } else if (autoStop && filePath != null) {
      widget.onFinish?.call(filePath, _recordingSeconds);  // 自动停止
    }

    if (_isCanceled) {
      widget.onFinish?.call('', 0); // 取消发送
    }

    setState(() {
      _recordingSeconds = 0;
      _amplitudes = List.filled(20, 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( //手势监听
      onLongPressStart: (details) {
        startRecording();
        setState(() {
          _isRecording = true;
          _isCanceled = false;
          _startPosition = details.globalPosition;
          _currentPosition = _startPosition;
        });
        _showRecordDialog(context); // 显示浮动弹窗
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          _currentPosition = details.globalPosition;
          // 上滑超过 50px 时进入取消模式
          if (_currentPosition.dy < _startPosition.dy - 50) {
            if (!_isCanceled) {
              _isCanceled = true;
              Vibration.vibrate(duration: 50); // 振动反馈
            }
          } else {
            if (_isCanceled) {
              _isCanceled = false;  // 更新弹窗
            }
          }
        });
        _overlayEntry?.markNeedsBuild();
      },
      onLongPressEnd: (details) {
        _stopRecording();
      },
      child: Container( // 按钮
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "按住 说话",
            style: TextStyle(
              fontSize: 14,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  //浮动弹窗
  void _showRecordDialog(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: 100,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 200,
              height: 160,
              decoration: BoxDecoration(
                color: _isCanceled
                    ? theme.errorColor.withValues(alpha: 0.9)
                    : Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCanceled ? Icons.delete : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(20, (index) {
                        double height =
                            _isRecording ? 5 + (_amplitudes[index] * 10) : 5;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 50),
                            width: 3,
                            height: height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isCanceled ? "松开手指，取消发送" : "上滑取消，松开发送",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${_recordingSeconds}s",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }
}
