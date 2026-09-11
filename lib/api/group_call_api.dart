import 'package:dio/dio.dart';

import 'Http.dart';

class GroupCallApi {
  final Dio _dio = Http().dio;

  static final GroupCallApi _instance = GroupCallApi._internal();
  GroupCallApi._internal();
  factory GroupCallApi() => _instance;

  Future<Map<String, dynamic>> invite(
    String groupId,
    List<String> userIds,
    String callType,
  ) async {
    final response = await _dio.post(
      '/v1/api/voip/call/group/invite',
      data: {'groupId': groupId, 'userIds': userIds, 'callType': callType},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> hangup( //用于挂断整个电话
    String groupId,
    List<String> userIds,
  ) async {
    final response = await _dio.post(
      '/v1/api/voip/call/group/hangup',
      data: {'groupId': groupId, 'userIds': userIds},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> host() async {
    final response = await _dio.post('/v1/api/voip/livekit/host');
    return response.data;
  }

  Future<Map<String, dynamic>> token(String sessionId) async {
    final response = await _dio.post(
      '/v1/api/voip/livekit/token/group',
      data: {'sessionId': sessionId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> roomUsers(String sessionId) async {
    final response = await _dio.post(
      '/v1/api/voip/livekit/room/users',
      data: {'sessionId': sessionId},
    );
    return response.data;
  }
}
