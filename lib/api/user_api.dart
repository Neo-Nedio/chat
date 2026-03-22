import 'package:dio/dio.dart';

import 'Http.dart';

//用户登录的api
class UserApi {
  final Dio _dio = Http().dio;
  //构建单例
  static final UserApi _instance = UserApi._internal();

  UserApi._internal();

  factory UserApi() {
    return _instance;
  }

  //电脑端扫码登录
  Future<Map<String, dynamic>> qrLogin(String? key) async {
    final response = await _dio.post(
      '/v1/api/login/qr',
      data: {'key': key},
    );
    return response.data;
  }

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

  //获取用户信息
  Future<Map<String, dynamic>> info() async {
    final response = await _dio.get('/v1/api/user/info');
    return response.data;
  }

  //获取图片预览 URL
  Future<Map<String, dynamic>> getImg(String fileName, String targetId) async {
    final response = await _dio.get(
      '/v1/api/user/get/img',
      queryParameters: {'fileName': fileName, 'targetId': targetId},
    );
    return response.data;
  }

  //上传用户头像（表单）
  Future<Map<String, dynamic>> upload(FormData formData) async {
    final response = await _dio.post(
      '/v1/api/user/upload/portrait/form',
      data: formData,
    );
    return response.data;
  }

  //修改用户信息（birthday：UTC 日历日 0 点的毫秒时间戳，与 Jackson 默认 Date 反序列化一致）
  Future<Map<String, dynamic>> update({
    required String name,
    required String sex,
    required String birthday,
    required String signature,
    required String portrait,
  }) async {
    final response = await _dio.post(
      '/v1/api/user/update',
      data: {
        'name': name,
        'sex': sex,
        'birthday': birthday,
        'signature': signature,
        'portrait': portrait
      },
    );
    return response.data;
  }

  //发送邮箱验证码（按邮箱）
  Future<Map<String, dynamic>> emailVerification(String email) async {
    final response = await _dio.post(
      '/v1/api/user/email/verify',
      data: {'email':email},
    );
    return response.data;
  }

  //用户注册
  Future<Map<String, dynamic>> register(
      String username,String account,String password,String email,String code) async {
    final response = await _dio.post(
      '/v1/api/user/register',
      data: {
        'username':username,
        'account':account,
        'password':password,
        'email':email,
        'code':code
      },
    );
    return response.data;
  }

  //忘记密码
  Future<Map<String, dynamic>> forget(
      String account,String password,String email,String code) async {
    final response = await _dio.post(
      '/v1/api/user/forget',
      data: {
        'account':account,
        'password':password,
        'email':email,
        'code':code
      },
    );
    return response.data;
  }

  //修改密码
  Future<Map<String, dynamic>> updatePassword(
      String oldPassword,String newPassword,String confirmPassword) async {
    final response = await _dio.post(
      '/v1/api/user/update/password',
      data: {
        'oldPassword':oldPassword,
        'newPassword':newPassword,
        'confirmPassword':confirmPassword,
      },
    );
    return response.data;
  }
}
