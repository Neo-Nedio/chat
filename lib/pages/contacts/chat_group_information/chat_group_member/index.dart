import 'package:chat_mobile/utils/String.dart';
import 'package:flutter/material.dart';

import '../../../../components/app_bar_title/index.dart';
import '../../../../components/custom_badge/index.dart';
import '../../../../components/custom_portrait/index.dart';
import '../../../../components/custom_search_box/index.dart';
import '../../../../components/custom_text_button/index.dart';
import '../../../../utils/getx_config/config.dart';
import 'logic.dart';

class ChatGroupMemberPage extends CustomWidget<ChatGroupMemberLogic> {
  ChatGroupMemberPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
/*
    ┌─────────────────────────────────────────────────┐
    │  ← 成员列表                         [邀请]      │  ← AppBar（邀请按钮）
    ├─────────────────────────────────────────────────┤
    │  🔍 搜索成员                                     │
    ├─────────────────────────────────────────────────┤
    │  ┌─────────────────────────────────────────────┐│
    │  │  [头像]  张三                     [转让]   ││  ← 群主显示转让
    │  │                  [群主]                    ││  ← 群主标识
    │  └─────────────────────────────────────────────┘│
    │  ┌─────────────────────────────────────────────┐│
    │  │  [头像]  李四                     [移除]   ││  ← 群主显示移除
    │  └─────────────────────────────────────────────┘│
    │  ┌─────────────────────────────────────────────┐│
    │  │  [头像]  王五                     [添加]   ││  ← 非好友显示添加
    │  └─────────────────────────────────────────────┘│
    └─────────────────────────────────────────────────┘*/
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        title: const AppBarTitle('成员列表'),
        centerTitle: true,
        actions: [
          // 邀请好友
          CustomTextButton('邀请',
              onTap: controller.onInviteFriend,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              fontSize: 14),
        ],
      ),

      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            //搜索框
            CustomSearchBox(
              isCentered: false,
              onChanged: (value) => {controller.handlerSearchUser(value)},
            ),

            const SizedBox(height: 10),

            //群成员
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.memberList.length,
                itemBuilder: (context, index) {
                  return _buildUserItem(
                      context, controller.memberList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //成员项组件
  Widget _buildUserItem(context, dynamic user) {
    // 显示优先级：备注 > 群昵称 > 昵称
    final displayText = StringUtil.isNotNullOrEmpty(user['remark']) == true
        ? user['remark']
        : StringUtil.isNotNullOrEmpty(user['groupName']) == true
            ? user['groupName']
            : user['name'];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), //上下间隔
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            //头像
            CustomPortrait(
                portrait: user['portrait'],
                onTap: () => controller.handlerUserTapped(user['userId']),
            ),

            const SizedBox(width: 12),

            //占据剩余空间
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左侧：昵称 + 群主标识
                  Row(
                    children: [
                      Text(
                        displayText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (user['userId'] == controller.chatGroupDetails['ownerUserId'])
                        const CustomBadge(text: '群主'),
                    ],
                  ),
                  // 右侧：操作按钮
                  Row(
                    children: [
                      //群主可以转让给好友
                      if (controller.isOwner && user['friendId'] != null)
                        CustomTextButton(
                          '转让',
                          onTap: () => controller.onTransferGroup(context, user['userId']),
                          fontSize: 14,
                        ),
                      //非好友且不是自己
                      if (user['friendId'] == null && user['userId'] != globalData.currentUserId)
                        CustomTextButton(
                          '添加',
                          onTap: () => controller.onAddFriend(context, user['userId']),
                          fontSize: 14,
                        ),
                      //群主可以移除任何成员（不是自己）
                      if (controller.isOwner && user['userId'] != globalData.currentUserId)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: CustomTextButton(
                            '移除',
                            onTap: () => controller.onKickMember(context, user['userId']),
                            fontSize: 14,
                            textColor: theme.errorColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
