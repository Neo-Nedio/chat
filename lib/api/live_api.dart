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
}
