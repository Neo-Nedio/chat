import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import '../../../components/custom_text_field/index.dart';
import '../../../components/custom_update_live_cover/index.dart';
import '../../../utils/getx_config/config.dart';
import 'logic.dart';

class LiveStartPage extends CustomWidget<LiveStartLogic> {
  LiveStartPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,                            // 黑底，视频预览页常用
      body: Stack(
        fit: StackFit.expand,                                   // 子项铺满全屏
        children: [
          // 预览轨道：有轨道就渲染视频，没有就显示关闭图标占位
          Obx(() => controller.previewTrack.value != null
              ? SizedBox.expand(
            child: VideoTrackRenderer(
              controller.previewTrack.value!,
              fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          )
              : const ColoredBox(
            color: Color(0xFF151515),
            child: Center(
              child: Icon(Icons.videocam_off, color: Colors.white54, size: 48),
            ),
          )),
          const ColoredBox(color: Color.fromRGBO(0, 0, 0, 0.18)),  // 全局半透明遮罩，让白字更清晰
          SafeArea(                                               // 避开刘海/状态栏
            child: Column(
              children: [
                _buildTopBar(),                                   // 返回按钮
                const SizedBox(height: 8),
                _buildRoomInfo(context),                          // 直播间信息卡片
              ],
            ),
          ),
          // 底部操作区：切换源 + 开启直播按钮
          Obx(() => Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,  // 两个按钮等高
              children: [
                _buildSourceSwitch(),
                const SizedBox(width: 8),
                Expanded(child: _buildStartButton()),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // 顶部返回栏，高度对齐 AppBar
  Widget _buildTopBar() => SizedBox(
    height: kToolbarHeight,
    child: Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: Colors.white,
        tooltip: '返回',
      ),
    ),
  );

  // 直播间信息卡片：封面 + 标题
  Widget _buildRoomInfo(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.68),             // 半透明黑底
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        _buildCover(context),
        const SizedBox(width: 12),
        Expanded(child: _buildTitleArea(context)),
      ],
    ),
  );

  // 封面区：点击时由组件解析 URL，再进入图片更换页
  Widget _buildCover(BuildContext context) => Obx(() => SizedBox(
    width: 96,
    height: 96,
    child: CustomUpdateLiveCover(
      background: controller.background,
      portrait: controller.portrait,
      size: 96,
      radius: 12,
      onTap: controller.pickCover,
    ),
  ));

  // 标题区：标题为空显示占位文案，右侧编辑按钮弹底部弹窗
  Widget _buildTitleArea(BuildContext context) => Row(
    children: [
      Expanded(
        child: Obx(() => Text(
          controller.room['title']?.toString().trim().isNotEmpty == true
              ? controller.room['title'].toString()
              : '这个人太懒，还没有给直播间起标题',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        )),
      ),
      IconButton(
        onPressed: () => _showTitleSheet(context),
        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
        tooltip: '编辑标题',
      ),
    ],
  );

  // 切换源按钮：图标和文字随 isScreenSharing 变化
  Widget _buildSourceSwitch() => GestureDetector(
    onTap: controller.switchSource,
    child: Container(
      width: 108,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Icon(
          controller.isScreenSharing.value
              ? Icons.videocam_rounded      // 当前投屏 → 可切回摄像头
              : Icons.screen_share_rounded, // 当前摄像头 → 可切投屏
          color: Colors.white,
          size: 25,
        ),
      ),
    ),
  );

  // 开启直播按钮（目前只有 UI，没绑 onTap）
  // todo 开启直播和打开直播间 还没做
  Widget _buildStartButton() => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFFF82B5),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.videocam_rounded, color: Colors.white, size: 30),
        SizedBox(width: 8),
        Text(
          '开启直播',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  // 标题设置底部弹窗：自动聚焦输入框，随键盘上推
  void _showTitleSheet(BuildContext context) {
    // 每次打开弹窗都同步一次标题，避免上次编辑残留
    controller.titleController.text = controller.room['title']?.toString() ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,                                 // 允许弹窗随内容/键盘变高
      backgroundColor: Colors.transparent,                      // 透明背景，圆角由内部 Container 控制
      builder: (sheetContext) {
        // 弹窗渲染完再请求焦点，否则 FocusNode 还没挂载，聚焦无效
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (sheetContext.mounted) {
            FocusScope.of(sheetContext).requestFocus(controller.titleFocusNode);
          }
        });
        return Padding(
          // 用 viewInsets.bottom 让弹窗随键盘上推，不被键盘遮挡
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),  // 顶部圆角
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,               // 只占内容高度
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题栏：左标题 + 右关闭按钮
                      Row(
                        children: [
                          const Text('标题设置', style: TextStyle(
                            color: Color(0xFF243247), fontSize: 18, fontWeight: FontWeight.w600,
                          )),
                          const Spacer(),
                          IconButton(
                            onPressed: Get.back,
                            icon: const Icon(Icons.close_rounded),
                            color: const Color(0xFF718096),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 输入框 + 保存按钮
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: CustomTextField(
                            controller: controller.titleController,
                            focusNode: controller.titleFocusNode,
                            hintText: '请输入直播间标题',
                            inputLimit: 25,                       // 最多 25 字
                            fillColor: const Color(0xFFF1F5FA),
                          )),
                          const SizedBox(width: 8),
                          // 保存按钮：保存中禁用并变灰，防止重复提交
                          Obx(() => GestureDetector(
                            onTap: controller.isSavingTitle.value ? null : controller.saveTitle,
                            child: Container(
                              height: 48,
                              width: 58,
                              decoration: BoxDecoration(
                                color: controller.isSavingTitle.value
                                    ? const Color(0xFFB9C2D0)
                                    : theme.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text('保存', style: TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
