import 'dart:io';

import 'package:dio/dio.dart';

import 'Http.dart';

class LiveApi {
  final Dio _dio = Http().dio;

  static final LiveApi _instance = LiveApi._internal();

  LiveApi._internal();

  factory LiveApi() => _instance;

  Future<Map<String, dynamic>> list() async {
    final response = await _dio.get('/v1/api/voip/livekit/live/list');
    return response.data;
  }

  Future<Map<String, dynamic>> info() async {
    final response = await _dio.get('/v1/api/live-room/info');
    return response.data;
  }

  Future<Map<String, dynamic>> uploadBackground(File file) async {
    final name = file.path.split(Platform.pathSeparator).last;
    final type = _mimeType(name);
    final response = await _dio.post(
      '/v1/api/live-room/upload/background',
      data: await file.readAsBytes(),
      options: Options(
        contentType: type,
        headers: {
          'name': name,
          'type': type,
          'size': await file.length(),
          'Content-Type': type,
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateTitle(String title) async {
    final response = await _dio.post(
      '/v1/api/live-room/title',
      data: {'title': title},
    );
    return response.data;
  }

  String _mimeType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
