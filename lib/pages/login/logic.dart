import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/user_api.dart';
import '../../utils/encrypt.dart';

class LoginPageLogic extends GetxController {
  // API 调用
  final _useApi = UserApi();

  // 文本控制器
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // 输入长度状态
  int _accountTextLength = 0;    // 账号输入长度（私有）
  int _passwordTextLength = 0;    // 密码输入长度（私有）
  // Getter/Setter
  int get accountTextLength =>_accountTextLength;
  int get passwordTextLength =>_passwordTextLength;
  set accountTextLength(int value){
    _accountTextLength = value;
    update([const Key("login")]);
  }
  set passwordTextLength(int value){
    _passwordTextLength = value;
    update([const Key("login")]);
  }

  //用户账号输入长度
  void onAccountTextChanged(String value){
    accountTextLength = value.length;      // 更新长度
    if (accountTextLength >= 30) accountTextLength = 30;  // 限制最大30
  }

  //用户密码输入长度
  void onPasswordTextChanged(String value){
    passwordTextLength = value.length;      // 更新长度
    if (passwordTextLength >= 16) passwordTextLength = 16;  // 限制最大16
  }

  //对话框
  void _dialog(
      String content,           // 提示内容
      BuildContext context,     // 上下文
      [String title = '登录失败'] // 可选标题，默认"登录失败"
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),           // 对话框标题
        content: Text(content),        // 对话框内容
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),  // 关闭对话框
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }


  void login(context) async {
    String username = usernameController.text;
    String password = passwordController.text;

    //空值校验
    if (username.isEmpty || password.isEmpty) {
      _dialog("用户名或密码不能为空~", context = context);
      return;
    }

    //密码加密
    final encryptedPassword =await passwordEncrypt(password);

    //调用登录API
    final loginResult = await _useApi.login(username, encryptedPassword);

    //登录成功
    if (loginResult['code'] == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //将内容放入储存
      await prefs.setString('x-token', loginResult['data']['token']);
      await prefs.setString('username', loginResult['data']['username']);
      await prefs.setString('userId', loginResult['data']['userId']);
      await prefs.setString('account', loginResult['data']['account']);
      await prefs.setString('portrait', loginResult['data']['portrait']);
      await prefs.setString('sex', loginResult['data']['sex']);
      //跳转到首页
      Get.offAllNamed('/?sex=${loginResult['data']['sex']}');
    } else {
      _dialog("用户名或密码错误，请重试尝试~", context = context);
    }
  }

  //去注册
  void toRegister()=>Get.toNamed('/register');

  //修改密码
  void toRetrievePassword()=>Get.toNamed('/retrieve_password');

  @override
  void onClose() {
    usernameController.dispose();   // 释放用户名控制器
    passwordController.dispose();    // 释放密码控制器
    super.onClose();                 // 调用父类清理
  }
}
