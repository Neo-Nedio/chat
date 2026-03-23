import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';



import '../../api/user_api.dart';
import '../../components/custom_flutter_toast/index.dart';
import '../../utils/encrypt.dart';

class RegisterPageLogic extends GetxController {
  final _useApi = UserApi();

  //用户名
  final usernameController = TextEditingController();

  //账号
  final accountController = TextEditingController();

  //密码
  final passwordController = TextEditingController();

  //邮箱
  final mailController = TextEditingController();

  //验证码
  final codeController = TextEditingController();

  //定时器
  late Timer _timer;
  int _countdownTime = 0;// 倒计时秒数

  int get countdownTime => _countdownTime;
  set countdownTime(int value) {
    _countdownTime = value;
    update([
      const Key("register"), //用来指定要更新组件的key，而不是全部更新
    ]);
  }

  int _userTextLength = 0;
  int get userTextLength => _userTextLength;
  set userTextLength(int value) {
    _userTextLength = value;
    update([const Key("register")]);//用来指定要更新组件的key，而不是全部更新
  }

  int _accountTextLength = 0;
  int get accountTextLength =>_accountTextLength;
  set accountTextLength(int value){
    _accountTextLength = value;
    update([const Key("register")]);//用来指定要更新组件的key，而不是全部更新
  }

  int _passwordTextLength = 0;
  int get passwordTextLength =>_passwordTextLength;
  set passwordTextLength(int value){
    _passwordTextLength = value;
    update([const Key("register")]); //用来指定要更新组件的key，而不是全部更新
  }

  //用户名输入长度
  void onUserTextChanged(String value) {
    userTextLength = value.length;
    if (userTextLength >= 30) userTextLength = 30;
  }

  //用户账号输入长度
  void onAccountTextChanged(String value){
    accountTextLength = value.length;
    if (accountTextLength >= 30) accountTextLength = 30;
  }

  //用户密码输入长度
  void onPasswordTextChanged(String value){
    passwordTextLength = value.length;
    if (passwordTextLength >= 16) passwordTextLength = 16;
  }

  //发送验证码
  void onTapSendMail() async {
    // 只有不在倒计时状态才能发送
    if (countdownTime == 0) {
      //TODO Http请求发送验证码(其他地方逻辑还有问题)
      final String mail = mailController.text;

      final emailVerificationResult = await _useApi.emailVerification(mail);

      if (emailVerificationResult['code'] == 0) {
        CustomFlutterToast.showSuccessToast("发送成功~");

        countdownTime = 30;  // 设置倒计时30秒
        _startCountdownTimer();  // 开始倒计时
      } else {
        CustomFlutterToast.showErrorToast(emailVerificationResult['msg']);
      }
    }
  }

  //注册
  void onRegister() async {
    String username = usernameController.text;
    String account = accountController.text;
    String password = passwordController.text;
    String email = mailController.text;
    String code = codeController.text;

    //空值校验
    if (username.isEmpty ||
        account.isEmpty ||
        password.isEmpty ||
        email.isEmpty ||
        code.isEmpty) {
      CustomFlutterToast.showErrorToast("不能为空，请填写完整！");
    } else {
      //密码加密
      final encryptedPassword = await passwordEncrypt(password);
      assert(encryptedPassword != "-1"); // 确保加密成功

      //调用注册API
      final registerResult = await _useApi.register(
          username, account, encryptedPassword, email, code);
      //注册成功返回上一页
      if (registerResult['code'] == 0) {
        CustomFlutterToast.showSuccessToast(registerResult['msg']);
        Get.back();  // 返回登录页
      }else {
        CustomFlutterToast.showErrorToast(registerResult['msg']);
      }
    }
  }

  //开始倒计时
  void _startCountdownTimer() {
    const oneSec = Duration(seconds: 1);           // 1秒间隔
    callback(timer) => {                           // 回调函数
      if (countdownTime < 1)                       // 如果倒计时结束
        { _timer.cancel() }                         // 取消定时器
      else                                          // 否则
        { countdownTime = countdownTime - 1 }       // 秒数减1
    };
    _timer = Timer.periodic(oneSec, callback);     // 启动定时器
  }

  @override
  void onClose() {
    usernameController.dispose();
    accountController.dispose();
    passwordController.dispose();
    mailController.dispose();
    codeController.dispose();
    super.onClose();
  }
}
