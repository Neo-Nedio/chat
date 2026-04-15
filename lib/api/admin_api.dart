import 'package:dio/dio.dart';

import 'Http.dart';

class AdminApi{
  final Dio _dio = Http().dio;

  static final AdminApi _instance = AdminApi._internal();

  AdminApi._internal();

  factory AdminApi() {
    return _instance;
  }

  //是否管理员
  Future<Map<String, dynamic>> isAdmin() async {
    final response = await _dio.get('/admin/v1/api/user/isAdmin');
    return response.data;
  }

  // 用户列表
  Future<Map<String, dynamic>> userPage(
      {int currentPage = 1 ,pageSize = 10, String? keyword, String? onlineStatus}) async {
    final response = await _dio.post(
        '/admin/v1/api/user/page',
        data: {
          'currentPage': currentPage,
          'pageSize': pageSize,
          'keyword' :keyword, //为空时全部
          'onlineStatus' :onlineStatus //为空时不分类
        },);
      return response.data;
  }

  // 禁用
  Future<Map<String, dynamic>> disableUser(String userId) async {
    final response = await _dio.post(
      '/admin/v1/api/user/disable',
      data: {'userId' : userId });
    return response.data;
  }

  // 解除禁用
  Future<Map<String, dynamic>> unDisableUser(String userId) async {
    final response = await _dio.post(
      '/admin/v1/api/user/unDisable',
      data: {'userId' : userId },);
    return response.data;
  }

  //重置密码
  Future<Map<String, dynamic>> restPassword(String userId) async {
    final response = await _dio.post('/admin/v1/api/user/reset/password',
        data: {'userId' : userId });
    return response.data;
  }
}