import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/custom_image/index.dart';
import '../../../utils/getx_config/GlobalThemeConfig.dart';

class EmojiMessage extends StatefulWidget {
  final dynamic value;
  final bool isRight;

  // 与 [ChatFrameLogic.getCustomEmojiImageUrl] 一致，共用内存缓存
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
    final maxSize = MediaQuery.sizeOf(context).width * 0.28;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxSize, maxHeight: maxSize),
      child: FutureBuilder<String>(
        future: _urlFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data ?? '').isNotEmpty) {
            return CustomImage(url: snapshot.data!);
          }
          return Container(
            width: maxSize * 0.6,
            height: maxSize * 0.6,
            color: widget.isRight
                ? _theme.primaryColor.withValues(alpha: 0.2)
                : Colors.grey.shade200,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}
