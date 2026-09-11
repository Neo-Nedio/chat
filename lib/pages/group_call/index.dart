import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../utils/getx_config/config.dart';
import 'logic.dart';

// 群通话页面（全屏）
class GroupCallPage extends CustomWidget<GroupCallLogic> {
  GroupCallPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    // 拦截返回，防止误退通话
    return PopScope(
      canPop: false, // 不允许直接返回
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave(context);   // 弹确认框
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF101622),   // 深色背景
        appBar: AppBar(
          title: Text(controller.groupName),   // 群名
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildRoom(context)),   // 主体区
              _buildControls(context),                // 底部控制栏
            ],
          ),
        ),
      ),
    );
  }

  // 主体区：加载态 / 通话信息 / 成员 / 视频
  Widget _buildRoom(BuildContext context) {
    return Obx(() {
      // 还在连接中 → 转圈
      if (controller.loading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 顶部圆形图标（视频/群）
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: .18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller.isVideo ? Icons.videocam : Icons.group,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // 状态文字：重连中 / 人数
          Text(
            controller.reconnecting.value
                ? '正在重新连接…'
                : '${controller.participants.length + 1} 人通话中',   // +1 补自己
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 24),

          // 成员列表（Chip）
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: controller.participants
                .map((id) => _participantChip(id))
                .toList(),
          ),

          // 视频通话才显示视频区
          if (controller.isVideo) ...[
            const SizedBox(height: 24),
            _remoteVideoTiles(),
          ],
        ],
      );
    });
  }

  // 单个成员 Chip（显示的是 userId）
  Widget _participantChip(String id) => Chip(
    avatar: const Icon(Icons.person, size: 16),
    label: Text(id, maxLines: 1, overflow: TextOverflow.ellipsis),
    backgroundColor: Colors.white.withValues(alpha: .92),
  );

  // 远程视频：横向滚动小窗
  Widget _remoteVideoTiles() {
    final remote = controller.room?.remoteParticipants.values.toList() ?? [];
    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: remote.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          // 取这个人的第一路视频
          final video = remote[i].videoTrackPublications
              .map((p) => p.track)
              .whereType<VideoTrack>()
              .firstOrNull;
          return Container(
            width: 130,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: video == null
                ? Center(
              // 没视频就显示 userId
              child: Text(
                remote[i].identity,
                style: const TextStyle(color: Colors.white),
              ),
            )
                : VideoTrackRenderer(video),   // 渲染视频
          );
        },
      ),
    );
  }

  // 底部控制栏：麦克风 / 摄像头 / 挂断
  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 麦克风开关
          _action(
            Icons.mic,
            Icons.mic_off,
            controller.microphoneEnabled,
            controller.toggleMicrophone,
          ),

          // 视频通话才有摄像头开关
          if (controller.isVideo) ...[
            const SizedBox(width: 16),
            _action(
              Icons.videocam,
              Icons.videocam_off,
              controller.cameraEnabled,
              controller.toggleCamera,
            ),
          ],

          const SizedBox(width: 16),

          // 挂断按钮
          FloatingActionButton(
            heroTag: 'group-call-hangup',
            backgroundColor: Colors.redAccent,
            onPressed: () => _confirmLeave(context),
            child: const Icon(Icons.call_end),
          ),
        ],
      ),
    );
  }

  // 通用开关按钮（图标随状态切换）
  Widget _action(
      IconData icon,
      IconData disabledIcon,
      RxBool enabled,
      VoidCallback onPressed,
      ) => Obx(
        () => IconButton(
      onPressed: onPressed,
      icon: Icon(enabled.value ? icon : disabledIcon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: .16),
        minimumSize: const Size(52, 52),
      ),
    ),
  );

  // 离开二次确认
  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('离开群通话？'),
        content: const Text('你可以稍后从群聊中重新加入。'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.leave();
            },
            child: const Text('离开'),
          ),
        ],
      ),
    );
  }
}