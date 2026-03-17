import 'package:flutter/material.dart';

import '../../components/custom_text_field/index.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  //登录校验
  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == "admin" && password == "123456") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("登录成功"),//
          content: Text("欢迎，$username!"),
          //选择按钮
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("确定"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("登录失败"),
          content: Text("用户名或密码错误，请重试"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("确定"),
            ),
          ],
        ),
      );
    }
  }
/*
  ─────────────────────────────────────────────────┐
│  🌈 渐变背景：从左上浅蓝 → 中间白 → 右下淡蓝       │
│  (Color(0xFFBED7F6) → 白色 → Color(0xFFDFF4FF)) │
│═════════════════════════════════════════════════│
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │  Padding (四周16px)                      │   │
│  │                                         │   │
│  │           ┌─────────────────┐           │   │
│  │           │                 │           │   │
│  │           │   🖼️  Logo       │           │   │
│  │           │   (宽度30%屏幕)   │           │   │
│  │           │                 │           │   │
│  │           └─────────────────┘           │   │
│  │                                         │   │
│  │              📱 聊天                      │   │
│  │         (字体30，字重900)                  │   │
│  │                                         │   │
│  │           ← 间距32px →                   │   │
│  │                                         │   │
│  │   ┌─────────────────────────────────┐   │   │
│  │   │  白色卡片背景                      │   │   │
│  │   │  (白色，圆角10px，灰色边框)         │   │   │
│  │   │  padding: 上下30px, 左右20px      │   │   │
│  │   │                                 │   │   │
│  │   │   账号                            │   │   │
│  │   │   ┌─────────────────────────┐   │   │   │
│  │   │   │ 请输入内容              │   │   │   │
│  │   │   │ (背景色 #EDF2F9)        │   │   │   │
│  │   │   └─────────────────────────┘   │   │   │
│  │   │                                 │   │   │
│  │   │         ← 间距15px →             │   │   │
│  │   │                                 │   │   │
│  │   │   密码                            │   │   │
│  │   │   ┌─────────────────────────┐   │   │   │
│  │   │   │ 请输入内容              │   │   │   │
│  │   │   │ (密码模式)              │   │   │   │
│  │   │   └─────────────────────────┘   │   │   │
│  │   │                                 │   │   │
│  │   │         ← 间距20px →             │   │   │
│  │   │                                 │   │   │
│  │   │      ┌───────────────────┐      │   │   │
│  │   │      │     登  录        │      │   │   │
│  │   │      │   (宽度80%，蓝色)  │      │   │   │
│  │   │      └───────────────────┘      │   │   │
│  │   │                                 │   │   │
│  │   └─────────────────────────────────┘   │   │
│  │                                         │   │
│  │                                         │   │
│  │  ← 底部留空 20% 屏幕高度 →                │   │
│  │                                         │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
*/

  @override
  Widget build(BuildContext context) {
    //获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 设置为false时，键盘弹出时页面不会自动调整
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBED7F6), Color(0xFFFFFFFF), Color(0xFFDFF4FF)],  // 3种颜色
            begin: Alignment.topLeft,      // 渐变起点：左上角
            end: Alignment.bottomRight,    // 渐变终点：右下角
          ),
        ),
        child: Padding(
          padding:
              //底部预留空间
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,//大体居中
              children: <Widget>[
                // 应用 Logo
                Image.asset(
                  'assets/images/logo.png', // 确保在pubspec.yaml中添加了logo图片路径
                  height: screenWidth * 0.3,
                  width: screenWidth * 0.3,
                ),
                //应用名称
                const Text(
                  "聊天",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                //间隔
                const SizedBox(height: 32.0),

                //白色卡片背景
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFFF2F2F2), // 边框颜色
                      width: 1.0, // 边框宽度
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      // 账号输入框
                      CustomTextField(
                        labelText: "账号",
                        controller: _usernameController,
                      ),
                      //间隔
                      const SizedBox(height: 15.0),
                      //密码输入框
                      CustomTextField(
                        labelText: "密码",
                        controller: _passwordController,
                        obscureText: true, // 密码输入框
                      ),
                      //间隔
                      const SizedBox(height: 20.0),

                      //可以让子组件按照父容器尺寸的一定比例来设置大小
                      FractionallySizedBox(
                        widthFactor: 0.8,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            //backgroundColor = 按钮的背景颜色
                            backgroundColor: const Color(0xFF4C9BFF),
                            //foregroundColor = 按钮上所有内容（文字、图标）的颜色
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            "登  录",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
