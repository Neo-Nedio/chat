import 'package:dio/dio.dart';

import 'Http.dart';

class ChatGroupApi {
  final Dio _dio = Http().dio;

  static final ChatGroupApi _instance = ChatGroupApi._internal();

  ChatGroupApi._internal();

  factory ChatGroupApi() {
    return _instance;
  }

  //获得群列表
  Future<Map<String, dynamic>> list() async {
    final response = await _dio.get('/v1/api/chat-group/list');
    return response.data;
  }
}
