// lib/services/user_service.dart
import 'package:dio/dio.dart';

import 'Http.dart';

class ChatListApi {
  final Dio _dio = Http().dio;

  static final ChatListApi _instance = ChatListApi._internal();

  ChatListApi._internal();

  //获取会话列表，返回 tops、others 等
  Future<Map<String, dynamic>> list() async {
    final response = await _dio.get('/v1/api/chat-list/list');
    return response.data;
  }

  factory ChatListApi() {
    return _instance;
  }

  //置顶/取消置顶
  Future<Map<String, dynamic>> top(String chatListId, bool isTop) async {
    final response = await _dio.post(
      '/v1/api/chat-list/top',
      data: {'chatListId': chatListId, 'isTop': isTop},
    );
    return response.data;
  }

  //删除会话
  Future<Map<String, dynamic>> delete(String chatListId) async {
    final response = await _dio.post(
      '/v1/api/chat-list/delete',
      data: {'chatListId': chatListId},
    );
    return response.data;
  }

  //会话已读
  Future<Map<String, dynamic>> read(String targetId) async {
    final response = await _dio.get('/v1/api/chat-list/read/$targetId');
    return response.data;
  }

  //会话详情
  Future<Map<String, dynamic>> detail(String targetId, String type) async {
    final response = await _dio.post('/v1/api/chat-list/detail',
        data: {'targetId': targetId, 'type': type});
    return response.data;
  }

  //创建会话（用来获得关于那个会话的信息）
  Future<Map<String, dynamic>> create(String userId, String type) async {
    final response = await _dio.post('/v1/api/chat-list/create',
        data: {'toId': userId, 'type': type});
    return response.data;
  }
}
