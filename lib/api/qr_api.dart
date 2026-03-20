import 'package:dio/dio.dart';

import 'Http.dart';

class QrApi {
  final Dio _dio = Http().dio;

  static final QrApi _instance = QrApi._internal();

  QrApi._internal();

  factory QrApi() {
    return _instance;
  }

  //二维码状态（已扫码）
  Future<Map<String, dynamic>> status(String? key) async {
    final response = await _dio.get('/qr/code/status', data: {'key': key});
    return response.data;
  }

  //获取二维码 key
  Future<Map<String, dynamic>> code() async {
    final response =
    await _dio.get('/qr/code', queryParameters: {'action': 'mine'});
    return response.data;
  }
}
