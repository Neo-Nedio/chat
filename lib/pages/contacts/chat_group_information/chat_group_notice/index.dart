import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../components/app_bar_title/index.dart';
import '../../../../components/custom_material_button/index.dart';
import '../../../../components/custom_portrait/index.dart';
import '../../../../components/custom_text_button/index.dart';
import '../../../../utils/date.dart';
import '../../../../utils/getx_config/config.dart';
import 'logic.dart';

class ChatGroupNoticePage extends CustomWidget<ChatGroupNoticeLogic> {
  ChatGroupNoticePage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const AppBarTitle('群公告'),
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          // 只有群主显示"创建"按钮
          actions: [
            if (controller.isOwner)
              CustomTextButton(
                  '创建',
                  onTap: controller.handlerAddNotice,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 5.0),
                  fontSize: 14),
          ]),

      //公告列表
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 有公告时显示列表
              if (controller.chatGroupNoticeList.isNotEmpty)
                ...controller.chatGroupNoticeList
                    .map((notice) => _buildNoticeItem(notice, context)),

              // 无公告时显示空状态
              if (controller.chatGroupNoticeList.isEmpty)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('暂无公告', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //通知项
  Widget _buildNoticeItem(notice, context) {
    return Column(
      children: [
        CustomMaterialButton(
          // 只有发布者可以点击编辑
          onTap: () {
            if (globalData.currentUserId == notice['userId']) {
              controller.handlerEditNotice(
                  notice['id'], notice['noticeContent']);
            }
          },
          //内容
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部：头像 + 名称 + 时间
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        //头像
                        CustomPortrait(portrait: notice['portrait'], size: 26),
                        const SizedBox(width: 10),
                        //昵称
                        SizedBox(
                          width: 60,
                          child: Text(
                            '${notice['name']}',
                            style: const TextStyle(
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black54),
                          ),
                        ),
                        const SizedBox(width: 2),
                        //时间
                        Text(
                          DateUtil.formatTime(notice['createTime']),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    // 只有发布者显示删除按钮
                    if (globalData.currentUserId == notice['userId'])
                      CustomTextButton('删除',
                          onTap: () => controller.onDelChatGroupNotice(
                              context, notice['id'])),
                  ],
                ),

                const SizedBox(height: 10),

                //内容
                Text(
                  '${notice['noticeContent']}',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        //与其他通知的间隔
        const SizedBox(height: 15),
      ],
    );
  }
}
