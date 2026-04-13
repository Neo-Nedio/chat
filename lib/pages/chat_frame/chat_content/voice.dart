import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/msg_api.dart';
import '../../../components/custom_audio/index.dart';
import '../../../utils/getx_config/GlobalThemeConfig.dart';

//语音消息组件,用于在聊天界面显示语音消息，包含语音文件下载、播放控制和文字识别内容。
class VoiceMessage extends StatefulWidget {
  final dynamic value;   // 完整的消息对象
  final bool isRight;    // 是否是自己发的

  const VoiceMessage({
    super.key,
    required this.value,
    this.isRight = false,
  });

  @override
  State<VoiceMessage> createState() => _ChatContentVoiceState();
}

class _ChatContentVoiceState extends State<VoiceMessage> {
  final _msgApi = MsgApi();
  String audioUrl = '';      // 音频文件 URL
  int audioTime = 0;         // 音频时长（秒）
  String text = '';          // 语音转文字的内容
  bool loading = true;       // 是否加载中
  final GlobalThemeConfig _theme = GetInstance().find<GlobalThemeConfig>();

  @override
  void initState() {
    super.initState();
    _parseValue();
  }

  //解析消息内容
  void _parseValue() {
    final content = jsonDecode(widget.value['msgContent']['content']);
    if (content != null) {
      setState(() {
        audioTime = content['time'] ?? 0;   // 获取时长
        text = content['text'] ?? '';       // 获取语音转文字
        loading = false;
      });
    } else {
      setState(() {
        loading = true;
      });
    }
  }

  //获取语音文件 URL
  String? _cachedUrl;  // 缓存 URL
  Future<String> onGetVoice() async {
    if (_cachedUrl != null) return _cachedUrl!;  // 使用缓存

    dynamic res = await _msgApi.getMedia(widget.value['id']);
    if (res['code'] == 0) {
      _cachedUrl = res['data'];
      return _cachedUrl!;
    }
    return '';
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _parseValue();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 根据消息方向决定对齐方式
    final alignment =
        widget.isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: alignment,  // 左对齐或右对齐
        children: [
          // 1. 语音播放器（有时长时显示）
          if (audioTime > 0)
            FutureBuilder<String>(
              future: onGetVoice(),
              builder: (context, snapshot) {
                //音频完成
                if (snapshot.hasData) {
                  return CustomAudio( //语音播放器
                    audioUrl: snapshot.data ?? '',
                    time: audioTime,
                    type: widget.isRight ? '' : 'minor',
                    onLoadedMetadata: () {},
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting) {//加载中
                  return Container(
                    width: 120,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: widget.isRight ? _theme.primaryColor : Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Color(0xffffffff),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                } else {
                  return Container(
                    width: 120,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: widget.isRight
                          ? _theme.primaryColor.withValues(alpha: 0.6)
                          : Colors.grey[300],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "加载失败",
                      style: TextStyle(
                        color: widget.isRight ? Colors.white : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                }
              },
            ),

          // 2. 加载中提示
          if (loading && text.isEmpty)
            const Text(
              "加载中...",
              style: TextStyle(color: Colors.grey),
            ),

          // 3. 语音转文字内容（可选）
          if (text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 0.5),
              decoration: BoxDecoration(
                color: widget.isRight ? _theme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(8),  // 内边距 8px
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                text,
                style: TextStyle(
                  color: widget.isRight ? Colors.white : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
