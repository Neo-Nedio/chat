import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_loading.dart';
import '../../utils/getx_config/config.dart';
import 'logic.dart';

class LivePage extends CustomWidget<LiveLogic> {
  LivePage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),   // 浅冷灰蓝背景
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF), // 与页面同色
        elevation: 0,                              // 去掉阴影
        leading: IconButton(                       // 返回按钮
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFF243247),
          tooltip: '返回',
        ),
        title: const Text('直播间', style: TextStyle(
          color: Color(0xFF243247), fontSize: 18, fontWeight: FontWeight.w600,
        )),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Obx(() {                               // 监听响应式状态
            if (controller.isLoading.value) {          // 加载中
              return Center(child: appLoadingInkDrop(color: theme.primaryColor, size: 32));
            }
            if (controller.rooms.isEmpty) {            // 空列表
              return const Center(child: Text('当前没有直播间', style: TextStyle(
                color: Color(0xFF8A96A8), fontSize: 15,
              )));
            }

            // 按奇偶下标把房间分到左右两列
            final left = <Map<String, dynamic>>[];
            final right = <Map<String, dynamic>>[];
            for (var i = 0; i < controller.rooms.length; i++) {
              (i.isEven ? left : right).add(controller.rooms[i]);
            }
            return RefreshIndicator(                   // 下拉刷新
              color: theme.primaryColor,
              onRefresh: controller.loadRooms,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),  // 内容不足也能下拉
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,  // 两列顶部对齐
                  children: [
                    Expanded(child: _buildColumn(left)),          // 左列
                    const SizedBox(width: 8),                     // 列间距
                    Expanded(child: _buildColumn(right)),         // 右列
                  ],
                ),
              ),
            );
          }),
          Positioned(
            right: 20,
            bottom: 24,
            child: GestureDetector(
              onTap: () => Get.toNamed('/live/start'),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.videocam, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 把一列房间渲染成纵向列表，每个卡片底部留 16 间距
  Widget _buildColumn(List<Map<String, dynamic>> rooms) => Column(
    children: rooms.map((room) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _LiveRoomCard(room: room),
    )).toList(),
  );
}

class _LiveRoomCard extends StatelessWidget {
  final Map<String, dynamic> room;

  const _LiveRoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    // 取字段并做空值兜底
    final background = room['background']?.toString().trim() ?? '';
    final portrait = room['portrait']?.toString().trim() ?? '';
    final imageUrl = background.isNotEmpty ? background : portrait;  // 优先用 background
    final title = room['title']?.toString().trim() ?? '';
    final count = room['participantCount'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(                                 // 圆角裁剪
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              CachedNetworkImage(                  // 封面图
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth,              // 宽度撑满，高度按比例
                placeholder: (context, url) => AspectRatio(   // 加载中占位
                  aspectRatio: 1,
                  child: Container(
                    color: const Color(0xFFE8EEF7),
                    alignment: Alignment.center,
                    child: appLoadingInkDrop(color: Colors.white, size: 24),
                  ),
                ),
                errorWidget: (context, url, error) => _fallbackImage(portrait),  // 失败兜底
              ),
              Container(                           // 左下角观看人数标签
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.58),  // 半透明黑底
                  borderRadius: BorderRadius.circular(20),       // 胶囊形
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.visibility_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(                                      // 直播间标题
          title.isEmpty ? '未命名直播间' : title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF243247), fontSize: 14, height: 1.35, fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 封面加载失败时的兜底：portrait 也为空直接本地默认图，否则再试 portrait
  Widget _fallbackImage(String portrait) {
    if (portrait.isEmpty) {
      return Image.asset(
        'assets/images/default-portrait.jpeg',
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: portrait,
      width: double.infinity,
      fit: BoxFit.fitWidth,
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/default-portrait.jpeg',
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
