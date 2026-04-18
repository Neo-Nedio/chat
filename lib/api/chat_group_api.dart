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


  //群详情
  Future<Map<String, dynamic>> details(String chatGroupId) async {
    final response = await _dio
        .post('/v1/api/chat-group/details', data: {'chatGroupId': chatGroupId});
    return response.data;
  }

  //群头像上传（表单）
  Future<Map<String, dynamic>> upload(FormData formData) async {
    final response = await _dio.post(
      '/v1/api/chat-group/upload/portrait/form',
      data: formData,
    );
    return response.data;
  }

  //更新群信息
  Future<Map<String, dynamic>> update(
      String chatGroupId, String key, dynamic value) async {
    final response = await _dio.post('/v1/api/chat-group/update',
        //根据updateKey判断要更新什么
        data: {'groupId': chatGroupId, 'updateKey': key, 'updateValue': value});
    return response.data;
  }

  //更新群名称
  Future<Map<String, dynamic>> updateName(
      String chatGroupId, String name) async {
    final response = await _dio.post('/v1/api/chat-group/update/name', data: {
      'groupId': chatGroupId,
      'name': name,
    });
    return response.data;
  }

  //踢出成员
  Future<Map<String, dynamic>> kickChatGroup(
      String groupId, String userId) async {
    final response = await _dio.post('/v1/api/chat-group/kick', data: {
      'groupId': groupId,
      'userId': userId,
    });
    return response.data;
  }

  //邀请成员
  Future<Map<String, dynamic>> inviteMember(
      String groupId, List<dynamic> ids) async {
    final response = await _dio.post('/v1/api/chat-group/invite', data: {
      'groupId': groupId,
      'userIds': ids,
    });
    return response.data;
  }

  //转让群主
  Future<Map<String, dynamic>> transferChatGroup(
      String groupId, String userId) async {
    final response = await _dio.post('/v1/api/chat-group/transfer', data: {
      'groupId': groupId,
      'userId': userId,
    });
    return response.data;
  }

  //创建群聊
  Future<Map<String, dynamic>> create(String name) async {
    final response = await _dio.post('/v1/api/chat-group/create', data: {
      'name': name,
    });
    return response.data;
  }

  //创建群聊并邀请好友
  Future<Map<String, dynamic>> createWithPerson(
      String name, String? notice, List users) async {
    final response = await _dio.post('/v1/api/chat-group/create', data: {
      'name': name,
      'notice': notice,
      'users': users,
    });
    return response.data;
  }

  //退出群聊
  Future<Map<String, dynamic>> quitChatGroup(String groupId) async {
    final response = await _dio.post('/v1/api/chat-group/quit', data: {
      'groupId': groupId,
    });
    return response.data;
  }

  //解散群聊
  Future<Map<String, dynamic>> dissolveChatGroup(String groupId) async {
    final response = await _dio.post('/v1/api/chat-group/dissolve', data: {
      'groupId': groupId,
    });
    return response.data;
  }

  //查看群聊是否解散
  Future<Map<String, dynamic>> isDissolveChatGroup(String groupId) async {
    final response = await _dio.post('/v1/api/chat-group/isDissolve', data: {
      'groupId': groupId,
    });
    return response.data;
  }
}
