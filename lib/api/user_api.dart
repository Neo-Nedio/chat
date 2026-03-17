import 'package:dio/dio.dart';

import 'Http.dart';

//用户登录的api
class UserApi {
  final Dio _dio = Http().dio;

  // 登录接口
  Future<Map<String, dynamic>> login(String account, String password) async {
    try {
      final response = await _dio.post(
        '/v1/api/login',
        data: {'account': account, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      print('Get profile error: ${e.message}');
      rethrow;
    }
  }

  // 获取公钥接口
  //获取RSA加密公钥的API，主要用于密码加密传输，确保登录密码在网络传输过程中是安全的。
  Future<Map<String, dynamic>> publicKey() async {
    try {
      final response = await _dio.get('/v1/api/login/public-key');
      return response.data;
    } on DioException catch (e) {
      print('Get publicKey error: ${e.message}');
      rethrow;
    }
  }
}
