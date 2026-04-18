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
  Future<Map<String, dynamic>> list() async {
    final response = await _dio.get('/v1/api/notify/list');
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

  //发送群聊申请
  Future<Map<String, dynamic>> groupApply(
      String groupId, String content) async {
    final response = await _dio.post(
      '/v1/api/notify/group/apply',
      data: {'groupId': groupId, 'content': content},
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

  //获取通知图片url
  Future<Map<String, dynamic>> getImgUrl(String fileName) async {
    final response = await _dio.get('/v1/api/notify/get/img',
        queryParameters: {'fileName': fileName});
    return response.data;
  }

  //最新未读系统通知
  Future<Map<String, dynamic>> systemLatest() async {
    final response = await _dio.get('/v1/api/notify/system/latest');
    return response.data;
  }

  //系统通知已读
  Future<Map<String, dynamic>> systemRead() async {
    final response = await _dio.get('/v1/api/notify/system/read');
    return response.data;
  }

  //管理员创建系统通知
  Future<Map<String, dynamic>> createNotify(FormData formData) async {
    final response =
        await _dio.post('/admin/v1/api/notify/system/create', data: formData);
    return response.data;
  }

  //管理员删除系统通知
  Future<Map<String, dynamic>> deleteNotify(String notifyId) async {
    final response = await _dio.post(
      '/admin/v1/api/notify/system/delete',
      data: {'notifyId': notifyId},  // 包装成 Map
    );
    return response.data;
  }
}
