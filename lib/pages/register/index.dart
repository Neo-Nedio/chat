import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

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
                      //无验证码时显示
                      if (!controller.showCodeInput) ...[
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
                          suffix: Text('${controller.mailTextLength}/25'),
                          inputLimit: 25,
                        ),
                      ],
                      //有验证码时显示
                      if (controller.showCodeInput) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '验证码',
                            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Pinput(
                          length: 6,
                          controller: controller.codeController,
                          defaultPinTheme: PinTheme( // 默认样式
                            width: 44,                    // 每个格子宽度 44px
                            height: 48,                   // 每个格子高度 48px
                            textStyle: TextStyle(         // 输入数字的样式
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: BoxDecoration(    // 格子外观
                              color: Colors.white,        // 白色背景
                              borderRadius: BorderRadius.circular(8),  // 圆角 8px
                              border: Border.all(color: Color(0xFFF2F2F2)),  // 浅灰色边框
                            ),
                          ),
                          focusedPinTheme: PinTheme( // 聚焦时的样式
                            // 宽高、字号与 defaultPinTheme 相同
                            width: 44,
                            height: 48,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.primaryColor, width: 1.5), // 主题色边框，更粗
                            ),
                          ),
                          onCompleted: (_) => controller.onRegister(), // 输完6位后自动提交
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                CustomButton(
                  text: controller.countdownTime > 0
                      ? '${controller.countdownTime}后重新获取'
                      : '获取验证码',
                  onTap: () {
                    if (controller.countdownTime > 0) return;
                    controller.onTapGetCode();
                  },
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
