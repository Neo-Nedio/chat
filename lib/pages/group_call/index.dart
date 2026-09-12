import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import '../../components/custom_portrait/index.dart';
import '../../utils/getx_config/GlobalData.dart';
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
          automaticallyImplyLeading: false,
          title: Text(controller.groupName),   // 群名
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: '群成员',
              icon: const Icon(Icons.person_outline),
              onPressed: () => _showMembersDrawer(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Obx(() => controller.hasVideoStream
              ? _buildVideoRoom(context)
              : Column(
                  children: [
                    Expanded(child: _buildRoom(context)), // 主体区
                    _buildControls(context), // 底部控制栏
                  ],
                )),
        ),
      ),
    );
  }

  void _showMembersDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: '关闭群成员',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: MediaQuery.of(context).size.width * .9,
              color: Colors.black.withValues(alpha: 0.82),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Obx(
                        () => Center(
                          child: Text(
                            '通话成员 (${controller.activeMembers.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        final activeMembers = controller.activeMembers;
                        if (activeMembers.isEmpty) {
                          return const Center(
                            child: Text(
                              '暂无通话成员',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: activeMembers.length,
                          itemBuilder: (_, index) {
                            final member = activeMembers[index];
                            return SizedBox(
                              height: 72,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: CustomPortrait(
                                        size: 48,
                                        portrait: member['portrait']
                                                ?.toString() ??
                                            '',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        member['name']?.toString() ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: offset, child: child);
      },
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

      final activeMembers = controller.activeMembers;
      final visibleMembers = activeMembers.take(8).toList();
      return Stack(
        children: [
          Center(
            child: Wrap(
              spacing: 24,
              runSpacing: 32,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: visibleMembers.map(_audioMemberItem).toList(),
            ),
          ),
          if (activeMembers.length > 8)
            Positioned(
              right: 20,
              bottom: 20,
              child: IconButton(
                tooltip: '更多通话成员',
                onPressed: () => _showMembersDrawer(context),
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .16),
                  minimumSize: const Size(48, 48),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _audioMemberItem(Map<String, dynamic> member) => SizedBox(
        width: 96,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPortrait(
              size: 72,
              portrait: member['portrait']?.toString() ?? '',
            ),
            const SizedBox(height: 8),
            Text(
              member['name']?.toString() ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      );

  // 构建视频通话页面
  Widget _buildVideoRoom(BuildContext context) {
    return Obx(() {
      // 加载中 → 转圈
      if (controller.loading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      // 只取前 2 个视频成员
      final videoMembers = _videoMembers().take(2).toList();
      return Stack(
        fit: StackFit.expand,        // 子组件铺满
        children: [
          // 主体：竖向排列的视频格子（最多 2 个，各占一半）
          Column(
            children: videoMembers
                .map((member) => Expanded(child: _videoMemberTile(member)))
                .toList(),
          ),
          // 底部：控制栏（麦克风/摄像头/挂断）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildControls(context),
          ),
        ],
      );
    });
  }

  // 收集"要展示视频的成员"列表
  List<Map<String, dynamic>> _videoMembers() {
    final currentUserId = Get.find<GlobalData>().currentUserId.toString();
    // 用一个 Set 去重：自己（如果摄像头开着）+ 所有参与者
    final ids = <String>{
      if (controller.cameraEnabled.value) currentUserId,
      ...controller.participants,
    };
    return ids.map((id) {
      // 找到这个人的视频轨道
      final video = _videoTrackFor(id, currentUserId);
      // 找到这个人的资料（昵称、头像）
      final member = controller.activeMembers.firstWhere(
            (item) => item['id']?.toString() == id,
        orElse: () => {'id': id, 'name': id, 'portrait': ''},
      );
      return {
        ...member,
        'video': video,      // 把视频轨道塞进去
      };
    }).where((member) => member['video'] is VideoTrack).toList();
  }

  // 拿某个人的视频轨道
  VideoTrack? _videoTrackFor(String id, String currentUserId) {
    // 自己 → 从 localParticipant 拿
    if (id == currentUserId) {
      return controller.room?.localParticipant?.videoTrackPublications
          .map((publication) => publication.track)
          .whereType<VideoTrack>()
          .firstOrNull;
    }
    // 别人 → 从 remoteParticipants 拿
    return controller.room?.remoteParticipants[id]?.videoTrackPublications
        .map((publication) => publication.track)
        .whereType<VideoTrack>()
        .firstOrNull;
  }

  // 单个视频格子
  Widget _videoMemberTile(Map<String, dynamic> member) {
    final video = member['video'];
    return Container(
      color: Colors.black,       // 黑底
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.expand,
        children: [
      if (video is VideoTrack)
        SizedBox.expand(
          child: VideoTrackRenderer(
            video,
            fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        ),
          // 左下角显示昵称
          Positioned(
            left: 16,
            bottom: 24,
            child: Text(
              member['name']?.toString() ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
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
            backgroundColor: Colors.red,
            onPressed: () => _confirmLeave(context),
            child: const Icon(Icons.call_end, color: Colors.white),
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
