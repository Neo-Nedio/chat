import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_button/index.dart';
import '../../components/custom_portrait/index.dart';
import '../../components/custom_text_field/index.dart';
import '../../utils/String.dart';
import '../../utils/getx_config/config.dart';
import 'chat_content/msg.dart';
import 'logic.dart';

class ChatFramePage extends CustomWidget<ChatFrameLogic>
    with WidgetsBindingObserver {  // ← 监听系统变化（如键盘）
  ChatFramePage({super.key});

  @override
  void init(BuildContext context) {
    WidgetsBinding.instance.addObserver(this); // 添加监听器
  }

  @override
  //	系统指标变化时触发（键盘、状态栏等）
  void didChangeMetrics() {
    super.didChangeMetrics();
    //等待 UI 渲染完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //键盘高度（>0 表示键盘弹出）
      //viewInsets 表示系统 UI 遮盖内容区域的大小，键盘弹出时会增加底部遮盖区域。
      if (MediaQuery.of(Get.context!).viewInsets.bottom > 0) {
        controller.scrollBottom(); // 键盘弹出时滚动到底部
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, //当键盘弹出时，页面是否自动调整大小以避免键盘遮挡输入框。
        backgroundColor: const Color(0xFFF9FBFF),
        appBar: AppBar(
          centerTitle: true,
          title: AppBarTitle(
              StringUtil.isNotNullOrEmpty(controller.chatInfo['remark'])
                  ? controller.chatInfo['remark']   // 优先显示备注名
                  : controller.chatInfo['name'],    // 否则显示昵称
          ),
          backgroundColor: const Color(0xFFF9FBFF),
          actions: [
            //右上角详情图标
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: controller.toDetailsPage, // 点击跳转详情页
                child: CustomPortrait(
                    url: controller.chatInfo['portrait'], size: 32),
              ),
            )
          ],
        ),

        body: Column(
          children: [
            // 消息列表部分
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GetBuilder<ChatFrameLogic>(
                  id: const Key('chat_frame'), // 指定更新 ID
                  builder: (controller) {
                    return Stack(
                      children: [
                        ListView(
                          cacheExtent: 99999, // 预加载大量内容，保证滚动流畅
                          controller: controller.scrollController,
                          children: [
                            // 没有更多消息的提示
                            if (!controller.hasMore)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    '没有更多消息了',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            // 消息列表
                            ...controller.msgList.map((msg) => ChatMessage(
                                msg: msg, chatInfo: controller.chatInfo)),
                          ],
                        ),
                        // 加载指示器
                        if (controller.isLoading)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              color: const Color(0xFFEDF2F9),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //语音按钮
                      const Icon(IconData(0xe602, fontFamily: 'IconFont'), size: 26.0),

                      const SizedBox(width: 10),

                      //文本输入框
                      Expanded(
                        child: CustomTextField(
                          controller: controller.msgContentController,
                          maxLines: 3,
                          minLines: 1,
                          hintTextColor: theme.primaryColor,
                          hintText: '请输入消息',
                          vertical: 8,
                          fillColor: Colors.white,
                          onTap: () => controller.scrollBottom(),
                          onChanged: (value) {
                            controller.isSend.value = value.trim().isNotEmpty;
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      //附件按钮
                      const Icon(IconData(0xe632, fontFamily: 'IconFont'), size: 26.0),

                      const SizedBox(width: 10),

                      //动态按钮（表情/发送）
                      Obx(() {
                        if (controller.isSend.value) {
                          return CustomButton(
                            text: '发送',
                            onTap: controller.sendTextMsg,
                            width: 60,
                            textSize: 14,
                            height: 34,
                          );
                        } else {
                          return const Icon(
                              IconData(0xe636, fontFamily: 'IconFont'),
                              size: 26.0);
                        }
                      }),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  //消息气泡
  Widget _buildMsgContent(msg) {
    bool isRight = msg['fromId'] == globalData.currentUserId; // 是否自己发的
    return Column(
      children: [
        Align(
          //自己在左边，对方在右边
          alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRight ? theme.primaryColor : Colors.white, //自己：蓝色，对方：白色
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            constraints: BoxConstraints(  // 最大宽度 = 屏幕宽度的 80% ,防止消息过长时撑满整个屏幕
              maxWidth: MediaQuery.of(Get.context!).size.width * 0.8,
            ),
            //消息
            child: Text(
              msg['msgContent']['content'],
              style: TextStyle(color: isRight ? Colors.white : Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 15), // 消息间距
      ],
    );
  }

  @override
  void close(BuildContext context) {
    super.close(context);
    WidgetsBinding.instance.removeObserver(this);  // 移除监听器
  }
}
