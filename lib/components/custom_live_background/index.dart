import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/live_api.dart';

final _liveApi = LiveApi();
final Map<String, String> _backgroundUrlCache = {};
final Map<String, Future<String>> _backgroundUrlRequests = {};

// 获取直播间背景 URL，并缓存已经解析过的地址。
Future<String> resolveLiveBackgroundUrl(String? fileName) async {
  final key = (fileName ?? '').trim();
  if (key.isEmpty) return '';
  if (_backgroundUrlCache.containsKey(key)) {
    return _backgroundUrlCache[key]!;
  }

  final uri = Uri.tryParse(key);
  if (uri?.hasScheme == true) {
    _backgroundUrlCache[key] = key;
    return key;
  }

  final cachedRequest = _backgroundUrlRequests[key];
  if (cachedRequest != null) return cachedRequest;

  final request = _fetchBackgroundUrl(key);
  _backgroundUrlRequests[key] = request;
  try {
    final url = await request;
    if (url.isNotEmpty) _backgroundUrlCache[key] = url;
    return url;
  } finally {
    _backgroundUrlRequests.remove(key);
  }
}

Future<String> _fetchBackgroundUrl(String fileName) async {
  final result = await _liveApi.getBackground(fileName);
  if (result['code'] == 0 && result['data'] != null) {
    return result['data'].toString().trim();
  }
  return '';
}

// 直播间背景组件：背景文件名 -> 背景 URL -> 默认图。
class CustomLiveBackground extends StatelessWidget {
  final String? background;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CustomLiveBackground({
    super.key,
    required this.background,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundName = background?.trim() ?? '';
    if (backgroundName.isEmpty) return _defaultImage();

    return FutureBuilder<String>(
      future: resolveLiveBackgroundUrl(backgroundName),
      builder: (context, snapshot) {
        final url = snapshot.data?.trim() ?? '';
        if (url.isNotEmpty) {
          return CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            errorWidget: (context, url, error) => _defaultImage(),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingPlaceholder();
        }
        return _defaultImage();
      },
    );
  }

  Widget _loadingPlaceholder() => AspectRatio(
    aspectRatio: 1,
    child: Container(
      width: width,
      height: height,
      color: const Color(0xFFE8EEF7),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );

  Widget _defaultImage() => Image.asset(
    'assets/images/default-portrait.jpeg',
    width: width,
    height: height,
    fit: fit,
  );
}
