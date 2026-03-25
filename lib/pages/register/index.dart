import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../components/custom_button/index.dart';
import '../../components/custom_text_field/index.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';

//注册页
//注释见登录页
class RegisterPage extends CustomWidget<RegisterPageLogic> {
  RegisterPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.minorColor, const Color(0xFFFFFFFF)],
          // 渐变颜色
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "欢迎注册",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text(
                  "请填写相关注册信息。",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFFF2F2F2),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomTextField(
                        labelText: "用户名",
                        controller: controller.usernameController,
                        onChanged: controller.onUserTextChanged,
                        suffix: Text('${controller.userTextLength}/30'),
                        inputLimit: 30,
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextField(
                        labelText: "账号",
                        controller: controller.accountController,
                        onChanged: controller.onAccountTextChanged,
                        suffix: Text('${controller.accountTextLength}/30'),
                        inputLimit: 30,
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextField(
                        labelText: "密码",
                        controller: controller.passwordController,
                        obscureText: true,
                        onChanged: controller.onPasswordTextChanged,
                        suffix: Text('${controller.passwordTextLength}/16'),
                        inputLimit: 16,
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextField(
                        labelText: "邮箱",
                        controller: controller.mailController,
                        onChanged: controller.onMailTextChanged,
                        suffix: Text('${controller.mailController}/16'),
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextField(
                        labelText: '验证码',
                        hintText: "请输入验证码",
                        controller: controller.codeController,
                        suffix: controller.mailController.text != ""
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: controller.onTapSendMail,
                              child: Text(
                                controller.countdownTime > 0
                                    ? '${controller.countdownTime}后重新获取'
                                    : '获取验证码',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: controller.countdownTime > 0
                                      ? const Color.fromARGB(
                                      255, 183, 184, 195)
                                      : const Color.fromARGB(
                                      255, 17, 132, 255),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                          ],
                        )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                CustomButton(
                  text: "立即注册",
                  onTap: controller.onRegister,
                  width: MediaQuery.of(context).size.width,
                  type: 'gradient',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
