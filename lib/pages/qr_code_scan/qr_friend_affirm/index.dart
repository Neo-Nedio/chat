import 'package:flutter/material.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_button/index.dart';
import '../../../components/custom_label_value/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_shadow_text/index.dart';
import '../../../utils/date.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

//二维码添加好友确认页面，当用户扫描好友二维码后，显示好友的个人资料并提供添加好友的功能
class QRFriendAffirmPage extends CustomWidget<QRFriendAffirmLogic> {
  QRFriendAffirmPage({super.key});
/*
  ┌─────────────────────────────────────┐
  │               个人资料               │ ← AppBar
  ├─────────────────────────────────────┤
  │  ┌─────────────────────────────────┐│
  │  │  ╭─────═          ┌──────────┐  │ │ ← 渐变背景卡片
  │  │  │     │          │ 张三      │  │ │
  │  │  │头像 │          │ san       │  │ │
  │  │  ╰─────╯          └──────────┘  │ │
  │  └─────────────────────────────────┘ │
  │  ┌─────────────────────────────────┐ │
  │  │ 性别              男             │ │ ← CustomLabelValue
  │  ├─────────────────────────────────┤ │
  │  │ 年龄              25             │ │
  │  ├─────────────────────────────────┤ │
  │  │ 生日            1999-01-01       │ │
  │  ├─────────────────────────────────┤ │
  │  │ 签名            热爱生活...       │ │
  │  └─────────────────────────────────┘ │
  │                                      │
  │  ┌─────────────────────────────────┐ │
  │  │        添加好友                   │ │ ← 添加按钮
  │  └─────────────────────────────────┘ │
  └─────────────────────────────────────┘*/

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        centerTitle: true,
        title: const AppBarTitle('个人资料'),
        backgroundColor: const Color(0xFFF9FBFF),
      ),

      //主体内容 (body)
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,  // 水平居中
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 上下两端分布
            children: [

              // 上半部分：好友信息
              Column(
                children: [
                  //顶部渐变卡片（好友头像和基本信息
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.minorColor, const Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        //左侧：头像
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            border: Border.all( //白色边框
                              color: Colors.white,
                              width: 5,
                            ),
                            borderRadius: BorderRadius.circular(35), // 圆形
                          ),
                          child: CustomPortrait(
                              url: controller.result['portrait'] ?? '',
                              size: 70,
                              radius: 35),
                        ),

                        //左右间隔
                        const SizedBox(width: 20),

                        //右侧：用户信息
                        Expanded( // 占据剩余空间
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,  // 左对齐
                                mainAxisAlignment: MainAxisAlignment.center,   // 垂直居中
                                children: [
                                  // 用户名（带渐变背景特效）
                                  CustomShadowText(text: controller.result['name'] ?? ''),


                                  const SizedBox(height: 10), // 间距

                                  // 账号
                                  Text(
                                    controller.result['account'] ?? '',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                          ),
                      ],
                    ),
                  ),

                  //标签-值对的展示组件
                  const SizedBox(height: 1),

                  CustomLabelValue(
                      label: '性别', value: controller.result['sex'] ?? ''),

                  const SizedBox(height: 1),

                  CustomLabelValue(
                      label: '年龄',
                      value:
                          DateUtil.calculateAge(controller.result['birthday'])),

                  const SizedBox(height: 1),

                  CustomLabelValue(
                      label: '生日',
                      value: DateUtil.getYearDayMonth(
                          controller.result['birthday'])),

                  const SizedBox(height: 1),

                  CustomLabelValue(
                      label: '签名', value: controller.result['signature'] ?? ''),
                ],
              ),

              //下半部分：按钮
              Column(
                children: [
                  CustomButton(
                    text: '添加好友',
                    onTap: controller.onAddFriend,
                    width: MediaQuery.of(context).size.width,
                  ),
                  const SizedBox(height: 50),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
