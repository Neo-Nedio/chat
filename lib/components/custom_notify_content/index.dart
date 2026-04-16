import 'package:flutter/material.dart';

import '../../api/notify_api.dart';
import '../custom_image/index.dart';

//系统通知展示
class CustomNotifyContent extends StatelessWidget {
  static final Map<String, String> _urlCache = {};
  static final NotifyApi _notifyApi = NotifyApi();

  final String title;
  final String text;
  final String imgFileName;
  final double titleSize;
  final double textSize;

  const CustomNotifyContent({
    super.key,
    required this.title,
    required this.text,
    required this.imgFileName,
    this.titleSize = 18,
    this.textSize = 14,
  });

  factory CustomNotifyContent.fromNotify(
    Map<String, dynamic> notify, {
    double titleSize = 18,
    double textSize = 14,
  }) {
    final content = notify['content'] ?? {};
    return CustomNotifyContent(
      title: content['title']?.toString() ?? '',
      text: content['text']?.toString() ?? '',
      imgFileName: content['img']?.toString().trim() ?? '',
      titleSize: titleSize,
      textSize: textSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //标题
        if (title.isNotEmpty)
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 10),

        //内容
        if (text.isNotEmpty)
          Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

        //图片
        if (imgFileName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildImage(),
          ),
      ],
    );
  }

  //获取图片url
  Future<String> _getImgUrl() async {
    final key = imgFileName.trim();
    if (key.isEmpty) return '';
    if (_urlCache.containsKey(key)) return _urlCache[key]!;
    final res = await _notifyApi.getImgUrl(key);
    if (res['code'] == 0 && res['data'] != null) {
      final url = res['data'].toString().trim();
      if (url.isNotEmpty) {
        _urlCache[key] = url;
        return url;
      }
    }
    return '';
  }

  //构建图片
  Widget _buildImage() {
    return FutureBuilder<String>(
      future: _getImgUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError || (snapshot.data ?? '').isEmpty) {
          return Image.asset('assets/images/empty-image.png');
        }
        return CustomImage(url: snapshot.data!);
      },
    );
  }
}
