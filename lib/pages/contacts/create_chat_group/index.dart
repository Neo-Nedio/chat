import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_label_value_button/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_text_button/index.dart';
import '../../../components/custom_text_field/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class CreateChatGroupPage extends CustomWidget<CreateChatGroupLogic> {
  CreateChatGroupPage({super.key});
/*

  ┌─────────────────────────────────────────────────┐
  │  [取消]          创建群聊            [完成]      │  ← AppBar
  ├─────────────────────────────────────────────────┤
  │                                                 │
  │  ┌─────────────────────────────────────────────┐│
  │  │  群名称                                      ││
  │  │  [请输入群名称~]                      0/10  ││  ← 输入框
  │  └─────────────────────────────────────────────┘│
  │                                                 │
  │  ┌─────────────────────────────────────────────┐│
  │  │  群公告                                      ││
  │  │  [输入群公告~]                        0/100 ││  ← 多行输入框
  │  │                                             ││
  │  └─────────────────────────────────────────────┘│
  │                                                 │
  │  ┌─────────────────────────────────────────────┐│
  │  │  邀请好友                    [头像1][头像2] ││  ← 按钮+头像列表
  │  └─────────────────────────────────────────────┘│
  │                                                 │
  └─────────────────────────────────────────────────┘
*/

  //已选好友头像显示
  Widget _selectedUserItem(dynamic user) => Container(
    width: 20,
    margin: const EdgeInsets.only(right: 5),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    child: CustomPortrait(
        url: user['portrait'],
        size: 20,
        radius: 10),
  );

  @override
  Widget buildWidget(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9FBFF),
    appBar: AppBar(
        //返回按钮
        leading: CustomTextButton('取消',
            onTap: () => Get.back(),
            padding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            fontSize: 14),
        backgroundColor: Colors.transparent,
        title: const AppBarTitle('创建群聊'),
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          //创建群聊按钮
          CustomTextButton('完成',
              onTap: controller.onCreateChatGroup,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 5.0),
              fontSize: 14),
        ]),

    body: SingleChildScrollView(
      child: Column(
        children: [
          //群名称
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CustomTextField(
                  labelText: "群名称",
                  controller: controller.nameController,
                  inputLimit: 10,
                  hintText: "请输入群名称~",
                  onChanged: controller.onRemarkChanged,
                  suffix: Text('${controller.nameLength}/10'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          //群公告
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                CustomTextField(
                  labelText: "群公告",
                  controller: controller.noticeController,
                  inputLimit: 100,
                  hintText: "输入群公告~",
                  maxLines: 4,
                  onChanged: controller.onNoticeTextChanged,
                  suffix: Text('${controller.noticeLength}/100'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          //邀请好友按钮
          CustomLabelValueButton(
            label: '邀请好友',
            color: const Color(0xFFEDF2F9),
            width: 80,
            onTap: () => Get.toNamed('/chat_group_select_user'),
            //当 users 列表不为空时，水平滚动显示所有已选好友的头像
            child: controller.users.isNotEmpty
                ? SizedBox(
              width: 70,
              height: 20,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: controller.users
                    .map((user) => _selectedUserItem(user))
                    .toList(),
              ),
            )
                : const Text(
              '暂无好友',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black38,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
