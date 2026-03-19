import 'package:dio/dio.dart';

import 'Http.dart';

class NotifyApi {
  final Dio _dio = Http().dio;

  static final NotifyApi _instance = NotifyApi._internal();

  NotifyApi._internal();

  factory NotifyApi() {
    return _instance;
  }

  //好友通知列表
  Future<Map<String, dynamic>> friendList() async {
    final response = await _dio.get('/v1/api/notify/friend/list');
    return response.data;
  }
}
