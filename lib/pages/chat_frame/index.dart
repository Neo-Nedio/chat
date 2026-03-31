import 'package:chat_bottom_container/panel_container.dart';
import 'package:chat_bottom_container/typedef.dart';
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

//面板的枚举
enum PanelType {
  none,     // 无面板
  keyboard, // 键盘（由系统提供）
  emoji,    // 表情面板（自定义）
  tool,     // 更多工具面板（自定义）
}

class ChatFramePage extends CustomWidget<ChatFrameLogic>
    with WidgetsBindingObserver {  // ← 监听系统变化（如键盘）
  ChatFramePage({super.key});

  @override
  void init(BuildContext context) {
    super.init(context);
    WidgetsBinding.instance.addObserver(this); // 添加监听器
  }

  @override
  //	系统指标变化时触发（键盘、状态栏等）
  void didChangeMetrics() {
    super.didChangeMetrics();
    //于检测键盘是否收起
    final keyboardHeight = MediaQuery.of(Get.context!).viewInsets.bottom;
    //键盘高度（>0 表示键盘弹出）
    if (keyboardHeight > 0) {
      //等待0.3秒
      Future.delayed(const Duration(milliseconds: 300), () {
        //等待 UI 渲染完成后执行
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 1. 检查滚动控制器是否已经绑定到具体的 ListView
          if (controller.scrollController.hasClients) {
            // 2. 滚动到指定位置
            controller.scrollController.animateTo(
              // 最大滚动距离（底部）+ 500px
              controller.scrollController.position.maxScrollExtent + 500,
              duration: const Duration(milliseconds: 300),  // 动画时长 300ms
              curve: Curves.fastOutSlowIn,                  // 缓动曲线：快出慢进
            );
          }
        });
      });
    }
  }

  //面板控制器
  final panelController = ChatBottomPanelContainerController<PanelType>();


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
        hidePanel(); //收起面板
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, //当键盘弹出时，页面是否自动调整大小以避免键盘遮挡输入框。
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
                  hidePanel();
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
                                key: ValueKey(msg['id']),
                                reEdit: () => controller.reEditMsg(msg), //重新编写
                                onTapMsg: () => controller.onTapMsg(msg), //点击通话消息记录
                                onTapCopy: (data) =>
                                //复制到剪切板
                                Clipboard.setData(ClipboardData(
                                    text: msg['msgContent']['content'])),
                                onTapRetract: (data) =>
                                    controller.retractMsg(data, msg), //撤回
                                msg: msg, //消息
                                chatPortrait: controller.chatInfo['portrait'], //头像
                                chatInfo: controller.chatInfo, //聊天详情
                                member: controller.members[msg['fromId']], //成员
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
                                controller.isRecording.value = true;    // 切换到语音模式
                                hidePanel();
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
                                        controller.isReadOnly.value = false;
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          panelController.updatePanelType( //切换到键盘
                                              ChatBottomPanelType.keyboard);
                                        });
                                        Future.delayed(
                                            const Duration(milliseconds: 500), () {
                                          controller.scrollBottom(); //滚动到底部
                                        });
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
                                controller.isReadOnly.value = true; // 设置只读模式（防止键盘弹起）
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  panelController.updatePanelType(
                                      ChatBottomPanelType.other,      // 切换到"其他面板"模式
                                      data: PanelType.emoji,          // 指定显示表情面板
                                      forceHandleFocus:               // 请求焦点
                                      ChatBottomHandleFocus.requestFocus);
                                });
                                // 滚动到底部
                                Future.delayed(const Duration(milliseconds: 200),
                                        () {
                                      controller.scrollBottom();
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
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  panelController.updatePanelType(
                                      ChatBottomPanelType.other,
                                      data: PanelType.tool);  // 显示工具面板
                                  Future.delayed(
                                      const Duration(milliseconds: 200), () {
                                    controller.scrollBottom(); //滚到底部
                                  });
                                });
                              },
                            ),
                        ],
                      ),
                      //展示“更多”菜单
                      _buildPanelContainer(),
                    ],
                  ),
                ),
            )
          ],
        ),
      ),
    );
  }

  //底部面板
  Widget _buildPanelContainer() {
    return ChatBottomPanelContainer<PanelType>(
      controller: panelController,           // 绑定控制器
      inputFocusNode: controller.focusNode,   // 绑定输入框焦点
      otherPanelWidget: (type) {              // 根据类型构建自定义面板
        if (type == null) return const SizedBox.shrink();
        switch (type) {
          case PanelType.emoji:
            return _buildEmoji();
          case PanelType.tool:
            return _buildMoreOperation();
          default:
            return const SizedBox.shrink();
        }
      },
      panelBgColor: Colors.transparent,       // 面板背景透明
      changeKeyboardPanelHeight: (height) => height, // 键盘高度回调
    );
  }

  //收起所有底部面板
  void hidePanel() {
    // 1. 如果输入框当前有焦点（键盘弹起）
    if (controller.focusNode.hasFocus) {
      controller.focusNode.unfocus();  // 收起键盘
    }

    // 2. 退出只读模式
    controller.isReadOnly.value = false;

    // 3. 关闭所有面板
    panelController.updatePanelType(ChatBottomPanelType.none);
  }

  //表情选择面板
  Widget _buildEmoji() {
    double height = 300;
    final keyboardHeight = panelController.keyboardHeight;
    if (keyboardHeight != 0) {
      height = keyboardHeight;
    }
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
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
            ),
          ),
        ],
      ),
    );
  }

  //“更多”操作面板
  Widget _buildMoreOperation() {
    double height = 300;
    final keyboardHeight = panelController.keyboardHeight; //键盘高度
    if (keyboardHeight != 0) {
      height = keyboardHeight; // 如果键盘弹起，用键盘高度代替
    }
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              //height: height,
              width: MediaQuery.of(Get.context!).size.width,
              padding: const EdgeInsets.all(10),
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
                        () => controller
                        .cropChatBackgroundPicture(ImageSource.camera),
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
            ),
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

  @override
  void close(BuildContext context) {
    super.close(context);
    WidgetsBinding.instance.removeObserver(this);  // 移除监听器
  }
}
