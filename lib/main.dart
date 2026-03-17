import 'package:chat_mobile/pages/login/index.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        home: LoginPage(),
    );
  }
}
