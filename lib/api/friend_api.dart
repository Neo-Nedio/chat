// lib/services/user_service.dart
import 'package:dio/dio.dart';

import 'Http.dart';

class FriendApi {
  final Dio _dio = Http().dio;

  static final FriendApi _instance = FriendApi._internal();

  FriendApi._internal();

  factory FriendApi() {
    return _instance;
  }

  //好友列表（按分组等）
  Future<Map<String, dynamic>> list() async {
    final response = await _dio.get('/v1/api/friend/list');
    return response.data;
  }

  //搜索好友
  Future<Map<String, dynamic>> search(String friendInfo) async {
    final response = await _dio.post(
      '/v1/api/friend/search',
      data: {'searchInfo': friendInfo},
    );
    return response.data;
  }
}
