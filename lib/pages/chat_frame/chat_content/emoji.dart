import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/custom_image/index.dart';
import '../../../utils/getx_config/GlobalThemeConfig.dart';

// 自定义表情消息：msgContent.type == emoji，content 为 minio 文件名
// 与 [ImageMessage] 一样仅限制最大宽高，由图片本身比例撑开
class EmojiMessage extends StatefulWidget {
  final dynamic value;
  final bool isRight;

  /// 与 [ChatFrameLogic.getCustomEmojiImageUrl] 一致，共用内存缓存
  final Future<String> Function(String fileName) getCustomEmojiImageUrl;

  const EmojiMessage({
    super.key,
    required this.value,
    required this.isRight,
    required this.getCustomEmojiImageUrl,
  });

  @override
  State<EmojiMessage> createState() => _EmojiMessageState();
}

class _EmojiMessageState extends State<EmojiMessage> {
  late final Future<String> _urlFuture;

  String get _fileName =>
      widget.value['msgContent']?['content']?.toString() ?? '';

  GlobalThemeConfig get _theme => Get.find<GlobalThemeConfig>();

  @override
  void initState() {
    super.initState();
    _urlFuture = _loadUrl();
  }

  Future<String> _loadUrl() {
    if (_fileName.isEmpty) {
      return Future.value('');
    }
    return widget.getCustomEmojiImageUrl(_fileName);
  }

  @override
  Widget build(BuildContext context) {
    final maxSize = MediaQuery.sizeOf(context).width * 0.4;
    return ConstrainedBox(
      // 限制最大宽高，而不是定死，便于图片按原比例在范围内展示
      constraints: BoxConstraints(maxWidth: maxSize, maxHeight: maxSize),
      child: FutureBuilder<String>(
        future: _urlFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data ?? '').isNotEmpty) {
            return CustomImage(url: snapshot.data!);
          }
          return Container(
            width: maxSize,
            color: widget.isRight ? _theme.primaryColor : Colors.white,
            height: maxSize,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xffffffff),
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }
}
