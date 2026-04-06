import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../components/custom_animated_dots_text/index.dart';
import '../../components/custom_icon_button/index.dart';
import '../../components/custom_portrait/index.dart';
import '../../utils/String.dart';
import '../../utils/date.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';

class VideoChatPage extends CustomWidget<VideoChatLogic> {
  VideoChatPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
/*
    ┌─────────────────────────────────────────────┐
    │  第1层：背景头像图片（全屏）                    │
    │  ┌─────────────────────────────────────────┐│
    │  │  第2层：高斯模糊 + 半透明黑色叠加          ││
    │  │  ┌─────────────────────────────────────┐││
    │  │  │  第3层：主体内容                      │││
    │  │  │  - 音频模式：头像 + 昵称 + 状态文字    │││
    │  │  │  - 视频模式：全屏视频 + 小窗口         │││
    │  │  └─────────────────────────────────────┘││
    │  └─────────────────────────────────────────┘│
    │                                              │
    │  ┌──────────────────────────────────────────┐│
    │  │  第4层：底部按钮（麦克风/挂断/摄像头）      ││
    │  └──────────────────────────────────────────┘│
    └─────────────────────────────────────────────┘*/
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // 设置状态栏样式
      child: PopScope( //返回拦截
/*    用户点击返回键
      ↓
      canPop = false → 拦截默认返回
      ↓
      调用 onPopInvokedWithResult
      ↓
      didPop = false（因为实际没有执行返回）
      ↓
      显示挂断确认对话框
      ↓
      用户确认后 → 手动执行返回*/
        canPop: false, // 禁止直接返回
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.showExitConfirmDialog(context);  // 显示确认对话框
        },
        child: Scaffold(
          body: Stack(
            children: [
              // 第1层：背景头像图片
              StringUtil.isNotNullOrEmpty(
                      controller.userInfo['portrait'] ?? '')
                  ? Image.network(
                      controller.userInfo['portrait'] ?? '',
                      fit: BoxFit.cover, // 覆盖模式，保持比例裁剪
                      height: double.infinity,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.black), // 加载失败显示黑色
                    )
                  : Container(color: Colors.black),  // 无头像显示黑色
              // 第2层：高斯模糊层
              BackdropFilter( //会对其后面的所有内容应用滤镜
                //sigma 模糊程度（越大越模糊）
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), //模糊滤镜
                child: Container( //半透明黑色容器
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              // 第3层：主体内容（头像+文字 或 视频画面）
              Positioned.fill( // 填满 Stack 的所有空间
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, //垂直居中
                  children: [
                    // 条件1：音频模式 或 等待接听
                    if (!controller.toUserIsReady ||
                        (controller.isOnlyAudio && controller.toUserIsReady))
                      buildAudioContent(),
                    // 条件2：视频模式且已接通
                    if (controller.toUserIsReady && !controller.isOnlyAudio)
                      buildVideoContent(),
                  ],
                ),
              ),
              // 第4层：底部操作按钮
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: buildActionButtons(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// 构建音频页面的内容
  Widget buildAudioContent() {
    return Column(
      children: [
        // 1. 对方头像（圆形，直径100）
        CustomPortrait(
          url: controller.userInfo['portrait'] ?? '',
          size: 100,
        ),
        const SizedBox(height: 16),

        // 2. 对方昵称（优先显示备注名）
        Text(
          StringUtil.isNullOrEmpty(controller.userInfo['remark'])
              ? controller.userInfo['name'] ?? ''
              : controller.userInfo['remark'] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 10),

        // 3. 动态状态文字
        if (controller.toUserIsReady && controller.isOnlyAudio)
          const CustomAnimatedDotsText(text: '正在语音通话中'),

        if (!controller.toUserIsReady)
          CustomAnimatedDotsText(
              text: controller.isSender ? '等待对方接听' : "对方请求通话"
          ),

        const SizedBox(height: 60),
      ],
    );
  }

// 构建视频页面的内容
  Widget buildVideoContent() {
    return Expanded(
      child: Stack(
        children: [
          // ========== 全屏视频画面 ==========
          Obx(
                () => RTCVideoView(
              controller.isRemoteFullScreen.value // 是否远程画面全屏
                  ? controller.localRenderer   // 全屏显示自己
                  : controller.remoteRenderer, // 全屏显示对方
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover, // 填充模式
              mirror: true,  // 镜像翻转  让本地画面像照镜子一样（抬手时屏幕里的手也是抬同一侧）
            ),
          ),

          // ========== 可拖拽小窗口 ==========
          Obx(() {
            return Positioned(
              left: controller.smallWindowOffset.value.dx,
              top: controller.smallWindowOffset.value.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  // details.delta: 本次拖拽的偏移量
                  // 例如：向右拖10像素 → Offset(10, 0)
                  controller.updateSmallWindowPosition(details.delta);
                },
                onTap: () {
                  // 点击切换全屏/小窗内容
                  controller.isRemoteFullScreen.value =
                  !controller.isRemoteFullScreen.value;
                },
                child: SizedBox( //限制大小作为小窗
                  width: 100,
                  height: 150,
                  child: RTCVideoView(
                    controller.isRemoteFullScreen.value // 是否远程画面全屏
                        ? controller.remoteRenderer  // 全屏模式：小窗显示对方
                        : controller.localRenderer,  // 非全屏：小窗显示自己
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover, // 填充模式
                    mirror: true,  // 镜像翻转  让本地画面像照镜子一样（抬手时屏幕里的手也是抬同一侧）
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

// 构建操作按钮
  Widget buildActionButtons() {
    return Column(
      children: [
        // 通话时长显示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Obx(() => Text(
                DateUtil.formatTimingTime(controller.time.value),
                style: const TextStyle(color: Colors.white),
              )),
        ),

        const SizedBox(height: 20),

        // 按钮行
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 麦克风按钮
            Obx(
              () => CustomIconButton(
                icon: controller.isAudioEnabled.value
                    ? const IconData(0xe654, fontFamily: 'IconFont')  // 麦克风开
                    : const IconData(0xe653, fontFamily: 'IconFont'), // 麦克风关
                onTap: controller.toggleAudio,
                color: Colors.black.withValues(alpha: 0.2),
                iconColor: Colors.white,
                iconSize: 22,
                width: 40,
                height: 40,
                radius: 40,
              ),
            ),

            const SizedBox(width: 20),

            // 挂断按钮
            CustomIconButton(
              icon: const IconData(0xe640, fontFamily: 'IconFont'),
              onTap: controller.onHangup,
              color: theme.errorColor,
              iconColor: Colors.white,
              width: 50,
              height: 50,
              radius: 18,
            ),

            // 接听按钮（条件显示）
            if (!controller.isSender && !controller.toUserIsReady)
              const SizedBox(width: 30),
            if (!controller.isSender && !controller.toUserIsReady)
              CustomIconButton(
                icon: const IconData(0xe641, fontFamily: 'IconFont'),
                onTap: controller.onAccept,
                color: Get.theme.primaryColor,
                iconColor: Colors.white,
                width: 50,
                height: 50,
                radius: 18,
              ),

            const SizedBox(width: 20),

            // 摄像头按钮（条件显示）
            if (!controller.isOnlyAudio)
              Obx(
                () => CustomIconButton(
                  icon: controller.isVideoEnabled.value
                      ? const IconData(0xeca6, fontFamily: 'IconFont')  // 视频开
                      : const IconData(0xeca5, fontFamily: 'IconFont'), // 视频关
                  onTap: controller.toggleVideo,
                  color: Colors.black.withValues(alpha: 0.2),
                  iconColor: Colors.white,
                  iconSize: 22,
                  width: 40,
                  height: 40,
                  radius: 40,
                ),
              )
            else
              const SizedBox(width: 40),
          ],
        )
      ],
    );
  }
}
