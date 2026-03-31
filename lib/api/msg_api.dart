import 'package:dio/dio.dart';

import 'Http.dart';

class MsgApi {
  final Dio _dio = Http().dio;

  static final MsgApi _instance = MsgApi._internal();

  MsgApi._internal();

  factory MsgApi() {
    return _instance;
  }

  //聊天记录（正序）
  Future<Map<String, dynamic>> record(
      String targetId, int index, int num) async {
    final response = await _dio.post('/v1/api/message/record',
        data: {'targetId': targetId, 'index': index, 'num': num});
    return response.data;
  }

  //发送消息
  Future<Map<String, dynamic>> send(dynamic msg) async {
    final response = await _dio.post('/v1/api/message/send', data: msg);
    return response.data;
  }

  //获取媒体预览 URL
  Future<Map<String, dynamic>> getMedia(String msgId) async {
    final response = await _dio
        .get('/v1/api/message/get/media', queryParameters: {'msgId': msgId});
    return response.data;
  }

  //发送文件（表单）
  Future<Map<String, dynamic>> sendMedia(FormData formData) async {
    final response =
    await _dio.post('/v1/api/message/send/file/form', data: formData);
    return response.data;
  }

  //撤回消息
  Future<Map<String, dynamic>> retract(String msgId,String? targetId) async {
    final response =
    await _dio.post('/v1/api/message/retraction', data: {
      'msgId': msgId,
      'targetId':targetId
    });
    return response.data;
  }

  //重新编辑（获取撤回前内容）
  Future<Map<String, dynamic>> reEdit(String msgId) async {
    final response =
    await _dio.post('/v1/api/message/reedit', data: {''
        'msgId': msgId}
    );
    return response.data;
  }
}
