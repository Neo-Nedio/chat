import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Http {
  static final Http _instance = Http._internal();

  // 工厂构造函数：可以控制对象的创建过程, 总是返回同一个对象
  factory Http() => _instance;

  late Dio dio;

  // 私有的命名构造函数
  Http._internal() {
    dio = Dio(BaseOptions(
      //baseUrl: 'http://localhost:9200',
      //baseUrl: 'http://192.168.61.202:9200',
      baseUrl: 'http://172.16.7.235:9200',
      //连接超时20秒
      connectTimeout: const Duration(seconds: 20),
      //接收超时20秒
      receiveTimeout: const Duration(seconds: 20),
    ));
    // 添加拦截器
    // todo 添加统一的异常处理
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      // 从本地存储获取token
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
