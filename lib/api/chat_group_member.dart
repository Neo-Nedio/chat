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

  // 禁言/解除禁言群成员
  /// [banDuration] 禁言时长（秒），0 表示解除禁言
  Future<Map<String, dynamic>> ban(
      String groupId, String targetId, int banDuration) async {
    final response = await _dio.post(
      '/v1/api/chat-group-member/ban',
      data: {
        'groupId': groupId,
        'targetId': targetId,
        'banDuration': banDuration,
      },
    );
    return response.data;
  }

  // 查询某成员是否处于禁言中
  Future<Map<String, dynamic>> isBan(String groupId, String targetId) async {
    final response = await _dio.post(
      '/v1/api/chat-group-member/is/ban',
      data: {
        'groupId': groupId,
        'targetId': targetId,
        // 后端 BanMemberVo 的 banDuration 标注了 @NotNull，这里填 0 占位
        'banDuration': 0,
      },
    );
    return response.data;
  }
}
