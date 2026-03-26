import 'package:dio/dio.dart';

import 'Http.dart';

class ChatGroupNoticeApi {
  final Dio _dio = Http().dio;

  static final ChatGroupNoticeApi _instance = ChatGroupNoticeApi._internal();

  ChatGroupNoticeApi._internal();

  factory ChatGroupNoticeApi() {
    return _instance;
  }

  //群公告列表
  Future<Map<String, dynamic>> list(String chatGroupId) async {
    final response = await _dio
        .post('/v1/api/chat-group-notice/list', data: {'groupId': chatGroupId});
    return response.data;
  }

  //删除群公告
  Future<Map<String, dynamic>> delete(String groupId, String noticeId) async {
    final response = await _dio.post('/v1/api/chat-group-notice/delete',
        data: {'groupId': groupId, 'noticeId': noticeId});
    return response.data;
  }

  //创建群公告
  Future<Map<String, dynamic>> create(String groupId, String content) async {
    final response = await _dio.post('/v1/api/chat-group-notice/create',
        data: {'groupId': groupId, 'content': content});
    return response.data;
  }

  //编辑群公告
  Future<Map<String, dynamic>> update(
      String groupId, String groupNoticeId, String content) async {
    final response = await _dio.post('/v1/api/chat-group-notice/update', data: {
      'groupId': groupId,
      'noticeId': groupNoticeId,
      'noticeContent': content
    });
    return response.data;
  }
}
