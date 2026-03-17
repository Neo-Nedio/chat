
import 'package:chat_mobile/pages/login/index.dart';
import 'package:chat_mobile/pages/navigation/index.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // 确保Flutter框架初始化完成,才能继续工作
  WidgetsFlutterBinding.ensureInitialized();

  //获取token,并判断是否1需要登录
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('x-token');
  runApp(MyApp(initialPage: token != null ? const CustomBottomNavigationBar() : LoginPage()));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '聊天',
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
          //启用 Material Design 3(另一种风格)
        useMaterial3: true,
      ),
      home: initialPage,
    );
  }
}
