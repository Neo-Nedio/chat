import 'package:dio/dio.dart';

import 'Http.dart';

class ChatGroupMemberApi {
  final Dio _dio = Http().dio;

  static final ChatGroupMemberApi _instance = ChatGroupMemberApi._internal();

  ChatGroupMemberApi._internal();

  factory ChatGroupMemberApi() {
    return _instance;
  }

  //群成员列表
  Future<Map<String, dynamic>> list(String chatGroupId) async {
    final response = await _dio.post('/v1/api/chat-group-member/list',
        data: {'chatGroupId': chatGroupId});
    return response.data;
  }

  //群成员列表分页
  Future<Map<String, dynamic>> listPage(String chatGroupId) async {
    final response = await _dio.post('/v1/api/chat-group-member/list/page',
        data: {'chatGroupId': chatGroupId});
    return response.data;
  }

  //查看是否是群成员
  Future<Map<String, dynamic>> isMember(String groupId) async {
    final response = await _dio.get(
        '/v1/api/chat-group-member/isMember',
        queryParameters: {'groupId': groupId});
    return response.data;
  }
}
