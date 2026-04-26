import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';



import '../../../api/user_api.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../../../utils/encrypt.dart';

//忘记密码页
//注释见注册页
class RetrievePasswordLogic extends GetxController{

  final _useApi = UserApi();


  //账号
  final accountController = TextEditingController();

  //密码
  final passwordController = TextEditingController();

  //验证码
  final codeController = TextEditingController();

  // 已发送过验证码，展示 Pinput
  bool _showCodeInput = false;
  bool get showCodeInput => _showCodeInput;

  int _countdownTime = 0;

  //计时器
  Timer? _timer;

  int get countdownTime => _countdownTime;
  set countdownTime(int value) {
    _countdownTime = value;
    update([
      const Key("retrieve_password"), //刷新页面
    ]);
  }

  int _accountTextLength = 0;
  int get accountTextLength =>_accountTextLength;
  set accountTextLength(int value){
    _accountTextLength = value;
    update([const Key("retrieve_password")]);
  }

  int _passwordTextLength = 0;
  int get passwordTextLength =>_passwordTextLength;
  set passwordTextLength(int value){
    _passwordTextLength = value;
    update([const Key("retrieve_password")]);
  }

  // 底部「获取验证码」：首次会校验账号+新密码；之后重新获取
  Future<void> onTapGetCode() async {
    if (!_showCodeInput) {
      if (accountController.text.trim().isEmpty || passwordController.text.isEmpty) {
        CustomFlutterToast.showSuccessToast('不能为空，请填写完整！');
        return;
      }
    }
    await _sendVerificationEmail();
  }

  //发送验证码
  Future<void> _sendVerificationEmail() async {
    if (countdownTime > 0) return;

    final String account = accountController.text.trim();
    if (account.isEmpty) {
      CustomFlutterToast.showErrorToast('请填写账号');
      return;
    }
    final emailVerificationResult = await _useApi.emailVerificationByAccount(account);
    if (emailVerificationResult['code'] == 0) {
      CustomFlutterToast.showSuccessToast('发送成功~');
      _showCodeInput = true;
      codeController.clear(); //删除输入框的验证码
      countdownTime = 30;
      _startCountdownTimer(); //开始倒计时
    } else {
      CustomFlutterToast.showErrorToast(emailVerificationResult['msg']);
    }
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

  void onSubmit() async {
    String account = accountController.text;
    String password = passwordController.text;
    String code = codeController.text;
    if (account.isEmpty || password.isEmpty || code.isEmpty) {
      CustomFlutterToast.showSuccessToast('不能为空，请填写完整！');
    } else {
      final encryptedPassword =await passwordEncrypt(password);
      assert (encryptedPassword!="-1");
      final passwordForgetResult = await _useApi.forget(account, encryptedPassword, code);
        if (passwordForgetResult['code'] == 0) {
          CustomFlutterToast.showSuccessToast(passwordForgetResult['msg']);
          Get.back();
        } else {
          CustomFlutterToast.showErrorToast(passwordForgetResult['msg']);
          codeController.clear();
          update([const Key("retrieve_password")]);
        }
    }
  }

  //开始倒计时
  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownTime <= 1) {
        countdownTime = 0;
        timer.cancel();
        _timer = null;
      } else {
        countdownTime = countdownTime - 1;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    accountController.dispose();
    passwordController.dispose();
    codeController.dispose();
    super.onClose();
  }

}
