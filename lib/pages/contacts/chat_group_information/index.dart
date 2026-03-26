import 'package:flutter/material.dart';

import '../../../components/app_bar_title/index.dart';
import '../../../components/custom_icon_button/index.dart';
import '../../../components/custom_label_value_button/index.dart';
import '../../../components/custom_least_button/index.dart';
import '../../../components/custom_portrait/index.dart';
import '../../../components/custom_shadow_text/index.dart';
import '../../../components/custom_update_portrait/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class ChatGroupInformationPage extends CustomWidget<ChatGroupInformationLogic> {
  ChatGroupInformationPage({super.key});
/*

  ┌─────────────────────────────────────────────────┐
  │  ← 群资料                                        │
  ├─────────────────────────────────────────────────┤
  │  ┌─────────────────────────────────────────────┐│
  │  │  [头像]  群名称                    [编辑]   ││
  │  └─────────────────────────────────────────────┘│
  │  ┌─────────────────────────────────────────────┐│
  │  │  群名称           xxx群                     ││
  │  └─────────────────────────────────────────────┘│
  │  ┌─────────────────────────────────────────────┐│
  │  │  群备注           未设置备注                 ││
  │  └─────────────────────────────────────────────┘│
  │  ┌─────────────────────────────────────────────┐│
  │  │  群昵称           未设置昵称                 ││
  │  └─────────────────────────────────────────────┘│
  │  ┌─────────────────────────────────────────────┐│
  │  │  群公告           暂无群公告~                ││
  │  └─────────────────────────────────────────────┘│
  │  ┌─────────────────────────────────────────────┐│
  │  │  查看所有成员(10)                           ││
  │  │  [👤] [👤] [👤] [👤]                       ││
  │  │  [👤] [👤] [👤] [👤]                       ││
  │  │  [➕邀请] [➖移除]                           ││
  │  └─────────────────────────────────────────────┘│
  │                                                 │
  │  [解散群聊] 或 [退出群聊] (红色文字)             │
  └─────────────────────────────────────────────────┘
*/

  //分割线
  PopupMenuEntry<int> _buildPopupDivider() {
    return PopupMenuItem<int>(
      enabled: false,
      height: 1,
      child: Container(
        height: 1,
        padding: const EdgeInsets.all(0),
        color: Colors.grey[200],
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        centerTitle: true,
        title: const AppBarTitle('群资料'),
        backgroundColor: const Color(0xFFF9FBFF),
      ),
      //主体内容
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //头部卡片（群头像 + 群名称）
                    Container(
                      decoration: BoxDecoration( //渐变背景
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
                        // 头像区域（带白色边框）
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 5,
                              ),
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: CustomUpdatePortrait(
                                isEdit: controller.isOwner, //不是群主时没有编辑遮罩层，点击后前往不能编辑的图片页面
                                onTap: () => controller.selectPortrait(),
                                url: controller.chatGroupDetails['portrait'] ?? '',
                                ),
                          ),
                          const SizedBox(width: 20),
                          // 群名称
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomShadowText(
                                    text: controller.chatGroupDetails['name']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //信息列表
                    const SizedBox(height: 1),
                    CustomLabelValueButton(
                        onTap: controller.setGroupName,
                        width: 60,
                        label: '群名称',
                        value: controller.chatGroupDetails['name']),
                    const SizedBox(height: 1),
                    CustomLabelValueButton(
                        onTap: controller.setGroupRemark,
                        width: 60,
                        label: '群备注',
                        hint: '未设置备注',
                        value: controller.chatGroupDetails['groupRemark']),
                    const SizedBox(height: 1),
                    CustomLabelValueButton(
                        onTap: controller.setGroupNickname,
                        width: 60,
                        label: '群昵称',
                        hint: '未设置昵称',
                        value: controller.chatGroupDetails['groupName']),
                    const SizedBox(height: 1),
                    CustomLabelValueButton(
                        onTap: controller.chatGroupNotice,
                        width: 60,
                        label: '群公告',
                        hint: '暂无群公告~',
                        maxLines: 10,
                        value: controller.chatGroupDetails['notice']
                            ['noticeContent']),
                    const SizedBox(height: 1),

                    // 成员列表区域
                    CustomLabelValueButton(
                      onTap: () {},
                      width: 140,
                      compact: false, // 宽松模式，内容换行显示
                      label:
                          '查看所有成员(${controller.chatGroupDetails['memberNum']})',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Wrap( //流式布局，根据内容量自动换行
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              // 成员头像列表
                              ...controller.chatGroupMembers.map(
                                (member) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //头像
                                    CustomPortrait(
                                      url: member['portrait'],
                                      size: 40,
                                    ),
                                    const SizedBox(height: 4),
                                    //名字
                                    SizedBox(
                                      width: 40,
                                      child: Center(
                                        child: Text(
                                          member['name'],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              //邀请按钮
                              CustomIconButton(
                                onTap: () {},
                                icon: Icons.add,
                                text: '邀请成员',
                              ),
                              //移除按钮
                              CustomIconButton(
                                onTap: () {},
                                icon: Icons.remove,
                                text: '移除成员',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    //底部操作按钮
                    // 群主显示"解散群聊"
                    if (controller.isOwner)
                      CustomLeastButton(
                        onTap: () {},
                        text: '解散群聊',
                        textColor: const Color(0xFFFF4C4C),
                      ),
                    // 非群主显示"退出群聊"
                    if (!controller.isOwner)
                      CustomLeastButton(
                        onTap: () {},
                        text: '退出群聊',
                        textColor: const Color(0xFFFF4C4C),
                      ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
