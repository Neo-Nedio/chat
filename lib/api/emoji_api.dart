import 'package:dio/dio.dart';

import 'Http.dart';

class EmojiApi {
  final Dio _dio = Http().dio;

  static final EmojiApi _instance = EmojiApi._internal();

  EmojiApi._internal();

  factory EmojiApi() {
    return _instance;
  }

  // 获取表情列表
  Future<Map<String, dynamic>> list() async {
    final response = await _dio.get('/v1/api/emoji/list');
    return response.data;
  }

  // 添加表情
  Future<Map<String, dynamic>> add(String emoji) async {
    final response = await _dio.post(
      '/v1/api/emoji/add',
      queryParameters: {'emoji': emoji},
    );
    return response.data;
  }

  // 上传自定义表情
  Future<Map<String, dynamic>> upload(FormData formData) async {
    final response = await _dio.post(
      '/v1/api/emoji/upload',
      data: formData,
    );
    return response.data;
  }

  // 获取图片预览地址（入参为服务端返回的 [fileName]）
  Future<Map<String, dynamic>> getImage(String fileName) async {
    final response = await _dio.get(
      '/v1/api/emoji/get',
      queryParameters: {'fileName': fileName},
    );
    return response.data;
  }
}
