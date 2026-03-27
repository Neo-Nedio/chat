import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/app_bar_title/index.dart';
import '../../components/custom_button/index.dart';
import '../../components/custom_icon_button/index.dart';
import '../../components/custom_portrait/index.dart';
import '../../components/custom_text_field/index.dart';
import '../../components/custom_voice_record_buttom/index.dart';
import '../../utils/String.dart';
import '../../utils/emoji.dart';
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
    //于检测键盘是否收起
    final keyboardHeight = MediaQuery.of(Get.context!).viewInsets.bottom;
    //等待 UI 渲染完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //键盘高度（>0 表示键盘弹出）
      if (keyboardHeight > 0) {
          controller.scrollBottom();
        }
    });
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
      //整个区域响应点击，同时事件会穿透到下层(让键盘收起同时，其他组件也能响应)
      behavior: HitTestBehavior.translucent,
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
                onTap: () {
                  controller.panelType.value = 'none';
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
                              ...controller.msgList.map(
                                    (msg) => GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  // 捕获点击事件并传递
                                  onTap: () {
                                    controller.panelType.value = 'none';
                                  },
                                  child: ChatMessage(
                                    msg: msg,
                                    chatInfo: controller.chatInfo,
                                    member: controller.members[msg['fromId']],
                                  ),
                                ),
                              ),
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
                                controller.panelType.value = 'none';
                                controller.isRecording.value = false;   // 切换到键盘模式
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  controller.focusNode.requestFocus(); //弹出键盘
                                });
                              },
                            )
                          else
                            _buildIconButton1(
                              const IconData(0xe7e2, fontFamily: 'IconFont'),
                                  () {
                                controller.panelType.value = 'none';
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
                              child: Obx(
                                    () => CustomTextField(
                                  controller: controller.msgContentController,
                                  maxLines: 3,
                                  minLines: 1,
                                  readOnly: controller.isReadOnly.value, //是否只读
                                  hintTextColor: theme.primaryColor,
                                  hintText: '请输入消息',
                                  vertical: 8,
                                  focusNode: controller.focusNode,
                                  fillColor: Colors.white.withValues(alpha: 0.9),
                                  onTap: () {
                                    controller.isReadOnly.value = false;      // 退出只读模式
                                    controller.panelType.value = 'keyboard';  // 切换到键盘模式
                                  },
                                  onChanged: (value) {
                                    controller.isSend.value =
                                        value.trim().isNotEmpty; // 控制发送按钮
                                  },
                                ),
                              ),
                            ),

                          const SizedBox(width: 5),

                          //表情按钮（不在语音输入按钮展示时出现）
                          if (!controller.isRecording.value)
                            _buildIconButton1(
                              const IconData(0xe632, fontFamily: 'IconFont'),
                                  () {
                                    controller.isReadOnly.value = true;
                                    controller.panelType.value = 'emoji';
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      controller.focusNode.requestFocus(); //获得焦点
                                    });
                                  },
                            ),

                          const SizedBox(width: 10),

                          //动态按钮（附件/发送）
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
                                 controller.focusNode.unfocus(); //失去焦点
                                  controller.panelType.value = 'more';
                              },
                            ),
                        ],
                      ),
                      //展示“更多”菜单
                      Obx(() => _buildPanelContainer(controller.panelType.value)),
                    ],
                  ),
                ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPanelContainer(type) {
    controller.scrollBottom();  // 先滚动到底部
    switch (type) {
      case 'emoji':
        return _buildEmoji(); // 表情面板
      case 'more':
        return _buildMoreOperation(); // 更多面板（语音/视频通话等）
      case 'none':
        FocusScope.of(Get.context!).unfocus();  // 收起键盘
        return const SizedBox.shrink();         // 空容器
      case 'keyboard':
        return const SizedBox.shrink(); // 空容器
      default:
        return const SizedBox.shrink();
    }
  }

  //表情选择面板
  Widget _buildEmoji() {
    return Container(
      height: 240,
      width: MediaQuery.of(Get.context!).size.width,  // 占满屏幕宽度
      padding: const EdgeInsets.all(10),               // 内边距
      margin: const EdgeInsets.only(top: 10),          // 上边距
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),  // 淡灰色分割线
            width: 1.0,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,  // 居中对齐
          spacing: 10,                       // 水平间距
          runSpacing: 10,                    // 垂直间距
          children: Emoji.emojis
              .map(
                (emoji) => GestureDetector(
              onTap: () {
                // 1. 获取当前输入框的文本
                final text = controller.msgContentController.text;
                // 2. 获取当前光标位置
                final selection = controller.msgContentController.selection;
                // 光标失焦后可能为 -1，这里兜底到文本末尾，避免 replaceRange 异常
                final start = (selection.start >= 0 && selection.start <= text.length)
                    ? selection.start
                    : text.length;
                final end = (selection.end >= start && selection.end <= text.length)
                    ? selection.end
                    : start;
                // 3. 替换文本（在光标位置插入表情）
/*                不同光标状态
                状态	selection.start	selection.end	含义
                光标在位置2	2	2	没有选中文本
                选中位置2-4	2	4	选中了2个字符*/
                final newText = text.replaceRange(
                  start,  // 开始位置
                  end,    // 结束位置
                  emoji,            // 插入的内容
                );
                // 4. 更新输入框
                controller.msgContentController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(
                    offset: start + emoji.length,  // 新光标位置
                  ),
                );
                //点击表情代表有了内容，可以发送
                controller.isSend.value = true;
              },
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }

  //“更多”操作面板
  Widget _buildMoreOperation() {
    return Container(
      height: 240,
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
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        children: [
          _buildIconButton2(
            '图片',
            const IconData(0xe9f4, fontFamily: 'IconFont'),
                () => controller.cropChatBackgroundPicture(null),
          ),
          _buildIconButton2(
            '拍照',
            const IconData(0xe9f3, fontFamily: 'IconFont'),
                () => controller.cropChatBackgroundPicture(ImageSource.camera),
          ),
          _buildIconButton2(
            '文件',
            const IconData(0xeac4, fontFamily: 'IconFont'),
                () => controller.selectFile(),
          ),
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
