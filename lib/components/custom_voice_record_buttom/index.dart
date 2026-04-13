import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';

import '../../utils/getx_config/GlobalThemeConfig.dart';
import '../custom_flutter_toast/index.dart';

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
  Offset _startPosition = Offset.zero;               // 按下的起始位置（用于判断上滑）
  Offset _currentPosition = Offset.zero;             // 当前手指位置
  OverlayEntry? _overlayEntry;                       // 浮动弹窗（显示录音状态）
  String? _filePath;                                // 录音文件路径
  Timer? _timer;                                    // 计时器
  int _recordingSeconds = 0;                        // 录音秒数
  //创建一个包含20个元素的列表，每个元素初始值都是 0.0
  List<double> _amplitudes = List.filled(20, 0.0);  // 音波数据（20个点，用于动画）

  GlobalThemeConfig theme = Get.find<GlobalThemeConfig>();

  //开始录音
  void startRecording() async {
    //检查权限
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      CustomFlutterToast.showErrorToast("权限申请失败，请在设置中手动开启麦克风权限");
      return; // 关键修复
    }

    // 振动反馈
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50); //振动持续 50毫秒
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
        _recordingSeconds++;
        // Overlay 与父 State 不同步重建，必须显式刷新（仅靠 setState 不会重绘弹窗）
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  //音量采集（音波动画）
  Future<void> _updateAmplitude() async {
    while (_isRecording) { //正在录音
      try {
        //获取音量
        /*{
          "current": -25.6,  // 当前音量（dB）
          "max": -20.3,      // 最大音量（dB）
          "min": -48.2       // 最小音量（dB）
        }*/
        final amplitude = await _record.getAmplitude();
        // 将 dB 转换为 0-1 的值（dB范围约 -50 ~ 0）
        double normalizedAmplitude = (amplitude.current + 50) / 50;
        //数值限制 clamp 确保值在指定范围内
        normalizedAmplitude = normalizedAmplitude.clamp(0.0, 1.0);

        // 音波只画在 Overlay 里，用 markNeedsBuild；setState 不会触发 Overlay 重建
        // 将现有数据左移，右侧添加新数据（形成滚动效果）
        for (int i = 0; i < _amplitudes.length - 1; i++) {
          _amplitudes[i] = _amplitudes[i + 1];
        }
        //添加新数据
        _amplitudes[_amplitudes.length - 1] = normalizedAmplitude;
        _overlayEntry?.markNeedsBuild();
      } catch (e) {
        print(e);
      }
      await Future.delayed(const Duration(milliseconds: 50));  // 每秒20次
    }
  }

  //停止录音
  void _stopRecording({bool autoStop = false}) async { //标识是否是自动停止（60秒超时）
    if (!_isRecording) return;
    _isRecording = false;  // ① 先停止音量采集循环
    _timer?.cancel();      // ② 再取消计时器

    final filePath = await _record.stop();  // 停止录音

    // 移除浮动弹窗
    //_overlayEntry?.mounted=ture 弹窗正常显示 可以安全remove
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
      widget.onFinish?.call('', 0); // 取消发送,空路径时onFinish会取消发送
    }

    setState(() {
      _recordingSeconds = 0;                    // 重置时长
      _amplitudes = List.filled(20, 0.0);      // 重置音波数据
      _isCanceled = false;                     // 重置取消标志
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( //手势监听
      onLongPressStart: (details) {
        Vibration.vibrate(duration: 30);  // 长按开始时也震动一下
        startRecording();                    // ① 开始录音
        setState(() {                       // ② 更新状态
          _isRecording = true;              // 标记录音中
          _isCanceled = false;              // 重置取消标志
          _startPosition = details.globalPosition;  // 记录起始位置
          _currentPosition = _startPosition;        // 当前位置=起始位置
        });
        _showRecordDialog(context);         // ③ 显示录音弹窗
      },
      //长按移动
      onLongPressMoveUpdate: (details) {
        setState(() {
          _currentPosition = details.globalPosition; // 更新当前位置
          // 上滑超过 50px 时进入取消模式
          if (_currentPosition.dy < _startPosition.dy - 50) {
            if (!_isCanceled) {
              _isCanceled = true;   // 进入取消模式
              Vibration.vibrate(duration: 50); // 振动反馈
            }
          } else {
            if (_isCanceled) {
              _isCanceled = false;  // 更新弹窗
            }
          }
        });
        _overlayEntry?.markNeedsBuild(); // 刷新弹窗UI
      },
      onLongPressEnd: (details) {
        _stopRecording(); // 停止录音
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
    // Overlay 是 Flutter 的顶层画布

/*    ✅ 不阻挡用户交互
    ✅ 可以跟随手指移动更新
    ✅ 性能更好，更轻量
    ✅ 适合实时更新的 UI*/

/*    一旦创建，需要手动管理生命周期
    builder 会在需要时重新构建
    通过 markNeedsBuild() 触发重建*/
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,      // 左边距0
        right: 0,     // 右边距0
        bottom: 100,  // 距离底部100px
        child: Center( // 水平居中
          child: Material(
            color: Colors.transparent, // 透明背景
            child: Container(
              width: 200,
              height: 160,
              decoration: BoxDecoration(
                //由GestureDetector的长按移动维护，当距离过远时会_overlayEntry?.markNeedsBuild();
                color: _isCanceled
                    ? theme.errorColor.withValues(alpha: 0.9)  // 取消模式：红色透明
                    : Colors.black54,                          // 正常模式：半透明黑
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //图标区域
                  //由GestureDetector的长按移动维护，当距离过远时会_overlayEntry?.markNeedsBuild();
                  Icon(
                    //正常模式：🎤 麦克风图标 → "正在录音"
                    //取消模式：🗑️ 删除图标 → "准备取消"
                    _isCanceled ? Icons.delete : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 5),
                  // 音波动画区域
                  SizedBox(
                    height: 30, // 固定高度30px
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(20, (index) {
                        double height = _isRecording
                            ? 5 + (_amplitudes[index] * 10)  // 录音中：动态高度
                            : 5;                              // 未录音：最小高度
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 50),
                            width: 3,
                            height: height,  // 动态变化
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // 提示文字
                  const SizedBox(height: 5),
                  Text(
                    _isCanceled ? "松开手指，取消发送" : "上滑取消，松开发送",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  //时长显示
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

  @override
  void dispose() {
    _timer?.cancel();
    _record.dispose();
    super.dispose();
  }
}
