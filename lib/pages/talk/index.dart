import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_image_group/index.dart';
import '../../components/custom_portrait/index.dart';
import '../../components/custom_text_button/index.dart';
import '../../utils/String.dart';
import '../../utils/date.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';


class TalkPage extends CustomWidget<TalkLogic> {
  TalkPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
  /*
    ┌─────────────────────────────────────┐
    │  ← 说说                    发表 ▶  │ ← AppBar
    ├─────────────────────────────────────┤
    │  ┌─────────────────────────────────┐ │
    │  │  ┌─────┐ 张三          10:30   │ │
    │  │  └─────┘                         │ │
    │  │  今天天气真好，出来玩啊~           │ │
    │  │  ┌───┬───┬───┐                  │ │
    │  │  │🖼️ │🖼️ │🖼️ │                  │ │
    │  │  ├───┼───┼───┤                  │ │
    │  │  │🖼️ │   │   │                  │ │
    │  │  └───┴───┴───┘                  │ │
    │  │  点赞(5) 评论(3)        删除    │ │
    │  │  查看更多内容 >                  │ │
    │  └─────────────────────────────────┘ │
    │  ┌─────────────────────────────────┐ │
    │  │  ┌─────┐ 李四          09:15   │ │
    │  │  └─────┘                         │ │
    │  │  分享一张照片                     │ │
    │  │  ┌───┐                           │ │
    │  │  │🖼️ │                           │ │
    │  │  └───┘                           │ │
    │  │  点赞(2) 评论(1)        删除    │ │
    │  │  查看更多内容 >                  │ │
    │  └─────────────────────────────────┘ │
    │                                      │
    │          没有更多内容了~              │ ← 底部footer
    └─────────────────────────────────────┘*/
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),// 浅蓝色背景
      appBar: AppBar(
          centerTitle: true,
          title: AppBarTitle(controller.title),
          backgroundColor: const Color(0xFFF9FBFF),
          actions: [
            //当目标id为空(导航栏打开时为空)或者目标是自己时显示发布按钮
            if (StringUtil.isNullOrEmpty(controller.targetUserId)
                || controller.targetUserId == globalData.currentUserId)
            CustomTextButton(
                  '发表',
                  onTap: () => Get.toNamed('/talk_create'),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  fontSize: 14),
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //刷新组件
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: theme.primaryColor,
          child: ListView.builder(
            controller: controller.scrollController,
            itemCount: controller.talkList.length + 1, // +1 用于底部footer
            itemBuilder: (context, index) {
              if (index < controller.talkList.length) {
                return _buildTalkItem(context,controller.talkList[index]); // 说说项
              } else {
                return _buildFooter(); // 底部加载更多
              }
            },
          ),
        ),
      ),
    );
  }

  //底部Footer（加载更多/没有更多）
  Widget _buildFooter() {
    if (controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 30.0,
            height: 30.0,
            //滚动圆圈
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: theme.primaryColor,
            ),
          ),
        ),
      );
    } else if (!controller.hasMore) {
      // 没有更多数据
      return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Center(
          child: Text(
            '没有更多内容了~',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // 说说项构建
  Widget _buildTalkItem(context,dynamic talk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),  // 底部间距
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          onTap: () => Get.toNamed('/talk_details',
              arguments: {'talkId': talk['talkId']}),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //用户信息
                  Row(
                    children: [
                      // 头像部分
                      CustomPortrait(url: talk['portrait'] ?? ''),

                      // 头像和文字的间距
                      const SizedBox(width: 10),

                      // 用户信息文字部分
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,  // 左对齐
                        children: [
                          Text(
                            talk['remark'] ?? talk['name'], // 优先显示备注，没有则显示姓名
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          const SizedBox(height: 2), // 姓名和时间的小间距
                          Text(
                            DateUtil.formatTime(talk['time']),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[800]),
                          )
                        ],
                      ),
                    ],
                  ),

                  //用户信息与内容区域的间隔
                  const SizedBox(height: 10),

                  //内容区域
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(    // 上边框
                            color: Colors.grey[100]!,
                            width: 1.0
                        ),
                        bottom: BorderSide( // 下边框
                            color: Colors.grey[100]!,
                            width: 1.0
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 文本内容
                        Text(
                          talk['content']['text'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        // 图片网格
                        CustomImageGroup(
                            imagesList: talk['content']['img'] ?? [], //img不是url,是文件名字
                            userId: talk['userId']),
                      ],
                    ),
                  ),

                  //内容区域与底部区域的间隔
                  const SizedBox(height: 5),

                  //底部统计行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("点赞（${talk['likeNum'] ?? 0}）",
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text("评论（${talk['commentNum'] ?? 0}）",
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      if (controller.currentUserId == talk['userId'])
                        CustomTextButton('删除',
                            onTap: () => controller.handlerDeleteTalkTip(
                                context, talk['talkId'])),
                    ],
                  ),
                  const SizedBox(height: 5),
                  CustomTextButton(
                    '查看更多内容',
                    onTap: () => Get.toNamed('/talk_details',
                        arguments: {'talkId': talk['talkId']}),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
