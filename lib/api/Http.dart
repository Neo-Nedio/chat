import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 私有的命名构造函数
  Http._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://$baseIp:9200',
      //连接超时20秒
      connectTimeout: const Duration(seconds: 20),
      //接收超时20秒
      receiveTimeout: const Duration(seconds: 20),
    ));
    // 添加拦截器
    // todo 添加统一的异常处理
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      options.baseUrl =
          'http://${await resolveEffectiveBaseIp()}:9200';
      // 从本地存储获取token
      //todo 全局变量储存token,防止每次都获取
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('x-token');
      if (token != null) {
        options.headers['x-token'] = token;
      }
      return handler.next(options);
    }, onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        // 处理token过期
      }
      return handler.next(error);
    }));
  }
}
