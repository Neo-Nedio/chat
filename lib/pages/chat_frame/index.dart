import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_button/index.dart';
import '../../components/custom_icon_button/index.dart';
import '../../components/custom_portrait/index.dart';
import '../../components/custom_text_field/index.dart';
import '../../components/custom_voice_record_buttom/index.dart';
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

    //于检测键盘是否收起，当键盘收起时关闭"更多"面板。
    final keyboardHeight = MediaQuery.of(Get.context!).viewInsets.bottom;
    if (keyboardHeight == 0) {
      controller.isShowMore.value = false;
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
/*
    ┌─────────────────────────────────────────────────────────────────┐
    │  ← 张三                                           [头像]      │  ← AppBar
    ├─────────────────────────────────────────────────────────────────┤
    │  ┌─────────────────────────────────────────────────────────────┐│
    │  │  消息列表区域                                                ││
    │  │  ┌─────────────────────────────────────────────────────────┐││
    │  │  │  没有更多消息了                                          │││
    │  │  └─────────────────────────────────────────────────────────┘││
    │  │  ┌─────────────────────────────────────────────────────────┐││
    │  │  │          [对方消息]  ← 左侧白色气泡                      │││
    │  │  └─────────────────────────────────────────────────────────┘││
    │  │  ┌─────────────────────────────────────────────────────────┐││
    │  │  │  [自己消息]               ← 右侧蓝色气泡                 │││
    │  │  └─────────────────────────────────────────────────────────┘││
    │  └─────────────────────────────────────────────────────────────┘│
    ├─────────────────────────────────────────────────────────────────┤
    │  ┌─────────────────────────────────────────────────────────────┐│
    │  │  [🎙️]  [按住说话 / 输入框]  [📎]  [😊/发送]               ││  ← 输入栏
    │  └─────────────────────────────────────────────────────────────────┘│
    │  ┌─────────────────────────────────────────────────────────────┐│
    │  │  更多操作面板（展开时）                                      ││
    │  │  [语音通话] [视频通话] [图片] [文件]                         ││
    │  └─────────────────────────────────────────────────────────────┘│
    └─────────────────────────────────────────────────────────────────┘*/
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
              child: GestureDetector(
                //点击消息列表，把“更多”面板收起
                onTap: (){
                  controller.isShowMore.value = false;
                },
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
                                msg: msg,
                                chatInfo: controller.chatInfo,
                                member: controller.members[msg['fromId']],
                              )),
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
              )
            ),
            //下部操作栏
            Obx(
                () => Container(
                  color: const Color(0xFFEDF2F9),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //语音/键盘切换
                          if (controller.isRecording.value)
                            _buildIconButton1(
                              const IconData(0xe661, fontFamily: 'IconFont'),
                                  () {
                                controller.isShowMore.value = false;
                                controller.isRecording.value = false;   // 切换到键盘模式
                                controller.focusNode.requestFocus();    // 弹出键盘
                              },
                            )
                          else
                            _buildIconButton1(
                              const IconData(0xe7e2, fontFamily: 'IconFont'),
                                  () {
                                controller.isShowMore.value = false;
                                controller.isRecording.value = true;    // 切换到语音模式
                              },
                            ),

                          const SizedBox(width: 10),

                          //输入框/语音按钮
                          if (controller.isRecording.value)
                            Expanded(
                              child: CustomVoiceRecordButton(
                                  onFinish: controller.onSendVoiceMsg // 完成语音发送回调
                              ),
                            )
                          else
                            Expanded(
                              child: CustomTextField(
                                controller: controller.msgContentController,
                                maxLines: 3,
                                minLines: 1,
                                hintTextColor: theme.primaryColor,
                                hintText: '请输入消息',
                                vertical: 8,
                                focusNode: controller.focusNode,
                                fillColor: Colors.white.withValues(alpha: 0.9),
                                onTap: () {
                                  controller.isShowMore.value = false;
                                  controller.scrollBottom();
                                },
                                onChanged: (value) {
                                  controller.isSend.value =
                                      value.trim().isNotEmpty;
                                },
                              ),
                            ),

                          const SizedBox(width: 5),

                          //附件按钮（不在语音输入按钮展示时出现）
                          if (!controller.isRecording.value)
                            _buildIconButton1(
                              const IconData(0xe632, fontFamily: 'IconFont'),
                                  () {},
                            ),

                          const SizedBox(width: 10),

                          //动态按钮（表情/发送）
                          if (controller.isSend.value)
                          // 有输入内容 → 显示发送按钮
                            CustomButton(
                              text: '发送',
                              onTap: controller.sendTextMsg, //发送消息
                              width: 60,
                              textSize: 14,
                              height: 34,
                            )
                          else
                          // 无输入内容 → 显示表情按钮
                            _buildIconButton1(
                              const IconData(0xe636, fontFamily: 'IconFont'),
                                  () {
                                FocusScope.of(context).unfocus();          // 收起键盘
                                // 切换更多面板显示状态
                                //todo 刚打开的列表会因为滚到最底层关闭
                                controller.isShowMore.value = !controller.isShowMore.value;
                                if (controller.isShowMore.value) {
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    controller.scrollBottom();
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                      //展示“更多”菜单
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: controller.isShowMore.value ? 240 : 0,
                        child: controller.isShowMore.value
                            ? _buildMoreOperation()
                            : Container(),
                      ),
                    ],
                  ),
                ),
            )
          ],
        ),
      ),
    );
  }

  //“更多”操作面板
  Widget _buildMoreOperation() {
    return Container(
      width: MediaQuery.of(Get.context!).size.width, //屏幕宽度
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (controller.chatInfo['type'] == 'user')
            _buildIconButton2(
              '语音通话',
              const IconData(0xe969, fontFamily: 'IconFont'),
                  () => controller.onInviteVideoChat(true),
            ),
          if (controller.chatInfo['type'] == 'user')
            _buildIconButton2(
              '视频通话',
              const IconData(0xe9f5, fontFamily: 'IconFont'),
                  () => controller.onInviteVideoChat(false),
            ),
          _buildIconButton2(
            '图片',
            const IconData(0xe9f4, fontFamily: 'IconFont'),
                () => {},
          ),
          _buildIconButton2(
            '文件',
            const IconData(0xeac4, fontFamily: 'IconFont'),
                () => {},
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton1(iconData, onTap) {
    return CustomIconButton(
      onTap: onTap,
      icon: iconData,
      width: 36,
      height: 36,
      iconSize: 26,
      iconColor: Colors.black,
      color: Colors.transparent,
    );
  }


  Widget _buildIconButton2(text, iconData, onTap) {
    return CustomIconButton(
      onTap: onTap,
      icon: iconData,
      width: 50,
      height: 50,
      radius: 15,
      iconSize: 26,
      text: text,
      color: Colors.white.withValues(alpha: 0.9),
      iconColor: const Color(0xFF1F1F1F),
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
