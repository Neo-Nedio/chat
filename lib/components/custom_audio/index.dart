import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../utils/getx_config/GlobalThemeConfig.dart';
import '../custom_sound_icon/index.dart';

//语音消息播放组件，用于在聊天界面显示和播放语音消息，支持播放/暂停、动态动画效果。
class CustomAudio extends StatefulWidget {
  final String audioUrl;     // 音频文件 URL
  final int time;            // 音频时长（秒）
  final String type;         // 类型：'minor' 表示次要样式 ，自己发的语音（主要样式）
  final VoidCallback? onLoadedMetadata;  // 加载完成回调

  const CustomAudio({
    super.key,
    required this.audioUrl,
    required this.time,
    this.type = '',
    this.onLoadedMetadata,
  });

  @override
  State<CustomAudio> createState() => _CustomAudioWidgetState();
}

class _CustomAudioWidgetState extends State<CustomAudio> {
  final AudioPlayer _audioPlayer = AudioPlayer();  // 音频播放器
  bool _isPlaying = false;                         // 是否正在播放
  final GlobalThemeConfig _globalThemeConfig = Get.find<GlobalThemeConfig>();

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer(); // 设置播放器监听
  }

  // 设置播放器监听
  void _setupAudioPlayer() {
    // 监听播放状态
    _audioPlayer.playerStateStream.listen((playerState) async {
      if (playerState.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;  // 播放完成，重置状态
        });
        await _audioPlayer.pause();
        _audioPlayer.seek(Duration.zero); // 回到开始位置
      }
    });

    // 监听音频时长（加载完成时触发）
    _audioPlayer.durationStream.listen((duration) {
      //当音频加载完成、获取到时长时，触发回调
      widget.onLoadedMetadata?.call(); // 回调通知加载完成
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  //播放/暂停逻辑
  Future<void> _playAudio() async {
    try {
      if (_isPlaying) {
        // 正在播放 → 暂停
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        // 未播放 → 开始播放
        setState(() {
          _isPlaying = true;
        });
        // 如果还没加载音频，先加载
        //duration是时间,音频未加载，不知道时长为null
        if (_audioPlayer.duration == null) {
          await _audioPlayer.setUrl(widget.audioUrl);
        }
        //播放
        await _audioPlayer.play();
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMinor = widget.type == 'minor'; // 是否为次要样式
    return GestureDetector(
      onTap: _playAudio, // 点击播放/暂停
      child: Container(
        decoration: BoxDecoration(
          color: isMinor ? Colors.white : _globalThemeConfig.primaryColor,
          borderRadius: BorderRadius.circular(5),
        ),
        width: 120,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            // 音波动画图标
            CustomSoundIcon(
              isStart: _isPlaying, // 播放时显示动画
              barColor: isMinor ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 10),
            // 时长显示
            Text(
              '${widget.time}"',
              style: TextStyle(
                color: isMinor ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
