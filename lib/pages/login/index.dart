import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/user_api.dart';
import '../../components/custom_text_field/index.dart';
import '../chat_list/index.dart';

//用户登录的api
final _useApi = UserApi();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //封装弹窗功能
  void _showDialog(String content, [String title = '登录失败']) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("确定"),
          ),
        ],
      ),
    );
  }

  //登录校验
  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    //输入验证
    if (username.isEmpty || password.isEmpty) {
      _showDialog("用户名或密码不能为空~");
      return;
    }

    //获取加密公钥
    final publicKeyResult = await _useApi.publicKey();
    if (publicKeyResult['code'] != 0) {}
    String key = publicKeyResult['data'];

    //解析公钥字符串为RSA公钥对象
    final parsedKey = encrypt.RSAKeyParser().parse(key) as RSAPublicKey;
    //创建RSA加密器
    final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: parsedKey));
    //加密密码并转为Base64字符串
    final encryptedPassword = encrypter.encrypt(password).base64;

    //获取登录结果
    final loginResult = await _useApi.login(username, encryptedPassword);

    //登录逻辑
    if (loginResult['code'] == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('x-token', loginResult['data']['token']);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ChatListPage()),
            (route) => false,
      );
    } else {
      _showDialog("用户名或密码错误，请重试尝试~");
    }
  }
/*
┌─────────────────────────────────────────────────┐
│  🌈 渐变背景：左上浅蓝 → 中间白 → 右下淡蓝        │
│  (Color(0xFFBED7F6) → 白色 → Color(0xFFDFF4FF)) │
│═════════════════════════════════════════════════│
│  ↑ SafeArea (避开状态栏/刘海屏)                   │
│  ┌─────────────────────────────────────────┐   │
│  │  Padding (四周16px)                      │   │
│  │  ┌───────────────────────────────────┐  │   │
│  │  │  Column (垂直布局)                 │  │   │
│  │  │                                     │  │   │
│  │  │  ← Spacer (flex:1) →                │  │   │
│  │  │  (占剩余空间的 25%)                  │  │   │
│  │  │                                     │  │   │
│  │  │        ┌─────────────────┐          │  │   │
│  │  │        │                 │          │  │   │
│  │  │        │   🖼️  Logo       │          │  │   │
│  │  │        │   (宽度25%屏幕)   │          │  │   │
│  │  │        │                 │          │  │   │
│  │  │        └─────────────────┘          │  │   │
│  │  │                                     │  │   │
│  │  │            📱 聊天                    │  │   │
│  │  │       (字体30，字重900)               │  │   │
│  │  │                                     │  │   │
│  │  │         ← 间距20px →                 │  │   │
│  │  │                                     │  │   │
│  │  │   ┌─────────────────────────────┐   │  │   │
│  │  │   │  白色卡片背景                 │   │  │   │
│  │  │   │  (圆角10px，灰色边框)         │   │  │   │
│  │  │   │  padding: 上下20px, 左右20px │   │  │   │
│  │  │   │                             │   │  │   │
│  │  │   │   ┌─────────────────────┐   │   │  │   │
│  │  │   │   │  账号输入框          │   │   │  │   │
│  │  │   │   │  (背景色#EDF2F9)     │   │   │  │   │
│  │  │   │   └─────────────────────┘   │   │  │   │
│  │  │   │                             │   │  │   │
│  │  │   │         ← 间距15px →         │   │  │   │
│  │  │   │                             │   │  │   │
│  │  │   │   ┌─────────────────────┐   │   │  │   │
│  │  │   │   │  密码输入框          │   │   │  │   │
│  │  │   │   │  (密码模式)          │   │   │  │   │
│  │  │   │   └─────────────────────┘   │   │  │   │
│  │  │   │                             │   │  │   │
│  │  │   │         ← 间距20px →         │   │  │   │
│  │  │   │                             │   │  │   │
│  │  │   │   ┌─────────────────────┐   │   │  │   │
│  │  │   │   │    [登录按钮]        │   │   │  │   │
│  │  │   │   │   (宽度80%，蓝色)     │   │   │  │   │
│  │  │   │   │    "登  录"          │   │   │  │   │
│  │  │   │   └─────────────────────┘   │   │  │   │
│  │  │   │                             │   │  │   │
│  │  │   └─────────────────────────────┘   │  │   │
│  │  │                                     │  │   │
│  │  │  ← Spacer (flex:3) →                │  │   │
│  │  │  (占剩余空间的 75%)                  │  │   │
│  │  │                                     │  │   │
│  │  └───────────────────────────────────┘  │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ↓ SafeArea (避开底部手势区域)                   │
└─────────────────────────────────────────────────┘

📊 布局比例分析：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Spacer (flex:1)  ── 25%  │
  Logo + 标题      ── 固定高度 │
  白色卡片         ── 自适应高度 │
  Spacer (flex:3)  ── 75%  │
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
*/
/*

  没有 Spacer (严格居中)：          有 Spacer (内容偏上，视觉更舒适)：

  ┌────────────────────┐          ┌────────────────────┐
  │                    │          │                    │
  │                    │          │    Logo            │← 顶部 Spacer flex:1
  │                    │          │    聊天            │   占据1份空间
  │    Logo            │          │  ┌──────────────┐  │
  │    聊天            │          │  │  登录框      │  │
  │  ┌──────────────┐  │          │  └──────────────┘  │
  │  │  登录框      │  │          │                    │
  │  └──────────────┘  │          │                    │
  │                    │          │                    │← 底部 Spacer flex:3
  │                    │          │                    │   占据3份空间
  │                    │          │                    │   (让内容偏上)
  └────────────────────┘          └────────────────────┘
*/

  @override
  Widget build(BuildContext context) {
    //获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 用于控制当键盘弹出时，页面是否自动调整大小以避免键盘遮挡输入框。
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBED7F6), Color(0xFFFFFFFF), Color(0xFFDFF4FF)],  // 3种颜色
            begin: Alignment.topLeft,      // 渐变起点：左上角
            end: Alignment.bottomRight,    // 渐变终点：右下角
          ),
        ),
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,//大体居中
                  children: <Widget>[
                    //Spacer 是一个弹性空间占位符，它会自动填充 Row 或 Column 中的空白区域。
                    const Spacer(flex: 1),

                    // 应用 Logo
                    Image.asset(
                      'assets/images/logo.png', // 确保在pubspec.yaml中添加了logo图片路径
                      height: screenWidth * 0.25,
                      width: screenWidth * 0.25,
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
                    const SizedBox(height: 20.0),

                    //白色卡片背景
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: const Color(0xFFF2F2F2), // 边框颜色
                          width: 1.0, // 边框宽度
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                    horizontal: 5, vertical: 5),
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
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
        )
    );
  }
}
