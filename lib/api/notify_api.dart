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

  //发送好友申请
  Future<Map<String, dynamic>> friendApply(
      String userId, String content) async {
    final response = await _dio.post(
      '/v1/api/notify/friend/apply',
      data: {'userId': userId, 'content': content},
    );
    return response.data;
  }

  //通知已读
  Future<Map<String, dynamic>> read(type) async {
    final response =
    await _dio.post('/v1/api/notify/read', data: {'notifyType': type});
    return response.data;
  }

  //系统通知列表
  Future<Map<String, dynamic>> systemListNotify() async {
    final response = await _dio.get('/v1/api/notify/system/list');
    return response.data;
  }
}
