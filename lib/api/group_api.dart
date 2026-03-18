import 'package:dio/dio.dart';

import 'Http.dart';


class GroupApi {
  final Dio _dio = Http().dio;

  static final GroupApi _instance = GroupApi._internal();

  GroupApi._internal();

  factory GroupApi() {
    return _instance;
  }

  //获取分组列表
  Future<Map<String, dynamic>> list() async {
    final response = await _dio.get('/v1/api/group/list');
    return response.data;
  }
}
