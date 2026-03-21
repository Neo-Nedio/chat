
import 'package:chat_mobile/utils/getx_config/ControllerBinding.dart';
import 'package:chat_mobile/utils/getx_config/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // 确保Flutter框架初始化完成,才能继续工作
  WidgetsFlutterBinding.ensureInitialized();

  //获取token,并判断是否需要登录
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('x-token');
  String? sex = prefs.getString('sex');
  //runApp(MyApp(initialPage: token != null ? const CustomBottomNavigationBar() : LoginPage()));
  runApp(MyApp(
      initialRoute:
          //有token时去主页面，并携带性别参数 sex=$sex
      token != null ? '/?sex=$sex' : '/login'));
}

class MyApp extends StatelessWidget {
  final String? initialRoute;
  final Widget? initialPage;

  const MyApp({super.key, this.initialPage,this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '聊天',
      //全局绑定Controller
      initialBinding: ControllerBinding(),
      // todo GetX 框架的日志开关
      enableLog: true,
      //路由配置
      getPages: pageRoute,
      //路由从右侧向左滑入（对GetX有效）
      defaultTransition: Transition.rightToLeft,
      initialRoute: initialRoute,
      //路由监听
      routingCallback: routingCallback,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,        // 基础种子颜色
          // 主要颜色系列
          primary: Colors.blue,           // 主要颜色：按钮背景、导航栏
          onPrimary: Colors.white,        // 在主要颜色上的内容：按钮文字
          // 表面颜色系列
          surface: const Color(0xFFFFFFFF), // 表面颜色：卡片背景、对话框
          onSurface: Colors.black,          // 在表面上的内容：卡片上的文字
        ),
        splashColor: const Color(0x80EAEAEA),    // 点击波纹颜色 (半透明浅灰)
        highlightColor: const Color(0x80EAEAEA), // 点击高亮颜色 (半透明浅灰)
          //启用 Material Design 3(另一种风格)
        useMaterial3: true,
      ),
      //home: initialPage,
    );
  }
}
