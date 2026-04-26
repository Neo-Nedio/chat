import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../components/custom_button/index.dart';
import '../../../components/custom_text_field/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

//找回密码页面
class RetrievePassword extends CustomWidget<RetrievePasswordLogic> {
  RetrievePassword({super.key});

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
        backgroundColor: Colors.transparent, //透明
        resizeToAvoidBottomInset: false,
        appBar: AppBar( //空标题，用来显示返回键
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        //主体内容
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),

                //上方文本
                const Text(
                  "找回密码",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text(
                  "请输入账号，验证码，新密码。验证码会发送到账号所对应的邮箱内。",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20.0),

                // 登录框部分
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
                    children: [
                      //无验证码时展示
                      if (!controller.showCodeInput) ...[
                        CustomTextField(
                          labelText: "账号",
                          controller: controller.accountController,
                          onChanged: controller.onAccountTextChanged,
                          suffix: Text('${controller.accountTextLength}/30'),
                          inputLimit: 30,
                        ),
                        const SizedBox(height: 20.0),
                        CustomTextField(
                          labelText: "新密码",
                          controller: controller.passwordController,
                          obscureText: true,
                          onChanged: controller.onPasswordTextChanged,
                          suffix: Text('${controller.passwordTextLength}/16'),
                          inputLimit: 16,
                        ),
                      ],
                      //有验证码时展示
                      if (controller.showCodeInput) ...[
                        const SizedBox(height: 20.0),
                        const Align( //标签文字
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '验证码',
                            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Pinput(
                          length: 6,  // 固定 6 位验证码
                          controller: controller.codeController, // 绑定控制器，获取输入值
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
                          onCompleted: (_) => controller.onSubmit(),  // 输完6位后自动提交
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
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
