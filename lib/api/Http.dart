import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/custom_flutter_toast/index.dart';
import '../utils/getx_config/GlobalData.dart';

class Http {
  static final baseIp = '172.16.7.235';

  // 优先 [GlobalData.baseIp]；为空则从本地键 `baseIp` 读取；仍无则用 [baseIp]
  static Future<String> resolveEffectiveBaseIp() async {
    if (Get.isRegistered<GlobalData>()) {
      final ip = Get.find<GlobalData>().baseIp.trim();
      if (ip.isNotEmpty) return ip;
    }
    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = prefs.getString('baseIp')?.trim() ?? '';
    if (fromPrefs.isNotEmpty) return fromPrefs;
    return baseIp;
  }

  static final Http _instance = Http._internal();

  // 工厂构造函数：可以控制对象的创建过程, 总是返回同一个对象
  factory Http() => _instance;

  late Dio dio;

  // 防止多个并发请求同时返回 -1 时重复弹 toast 和重复跳转。
  static bool _isHandlingAuthExpired = false;

  Http._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://$baseIp:9200',
      //连接超时20秒
      connectTimeout: const Duration(seconds: 20),
      //接收超时20秒
      receiveTimeout: const Duration(seconds: 20),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      //请求设置
      onRequest: (options, handler) async {
        options.baseUrl = 'http://${await resolveEffectiveBaseIp()}:9200';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // 从本地存储获取token
        //todo 全局变量储存token,防止每次都获取
        final token = prefs.getString('x-token');
        if (token != null) {
          options.headers['x-token'] = token;
        }
        return handler.next(options);
      },
      //返回设置
      onResponse: (response, handler) async {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('code')) {
          final int code = data['code'];
          final String msg = data['msg'] ?? '';

          switch (code) {
            case 0://成功
              break;
            case 1: //失败
              break;
            case -1:// 认证失效 - 清除token并跳转登录
              CustomFlutterToast.showErrorToast(msg.isNotEmpty ? msg : '认证失效,请重新登录~');
              await _handleAuthExpired();
              return handler.reject(
                DioException( //进入 onError 回调或 catchError
                  requestOptions: response.requestOptions,
                  response: response,
                  type: DioExceptionType.badResponse,
                  message: msg,
                ),
              );
            case -2:  // 权限不足
              CustomFlutterToast.showErrorToast(
                  msg.isNotEmpty ? msg : '该用户没有权限~');
              break;
          }
        }
        return handler.next(response);
      },
        onError: (error, handler) {

          String msg = '请求失败';
          final data = error.response?.data;
          msg = data?['msg'] ?? error.message ?? msg;

          CustomFlutterToast.showErrorToast(msg);
          return handler.next(error);
        }
    ));
  }

  //清除token并跳转登录
  static Future<void> _handleAuthExpired() async {
    if (_isHandlingAuthExpired) return;
    _isHandlingAuthExpired = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('x-token');
    Get.offAllNamed('/login');

    Future.delayed(const Duration(seconds: 2), () {
      _isHandlingAuthExpired = false;
    });
  }
}
