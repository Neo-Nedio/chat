import 'package:flutter/material.dart';

import '../custom_live_background/index.dart';
import '../custom_portrait/index.dart';

// 可编辑的直播间封面组件。背景、头像、默认图各自独立处理。
class CustomUpdateLiveCover extends StatelessWidget {
  final String background;
  final String portrait;
  final double size;
  final double radius;
  // 点击时传递已经解析好的图片 URL。
  final void Function(String imageUrl) onTap;

  const CustomUpdateLiveCover({
    super.key,
    required this.background,
    required this.portrait,
    this.size = 96,
    this.radius = 12,
    required this.onTap,
  });

  void _handleTap() {
    Future(() async {
      var imageUrl = '';
      try {
        if (background.trim().isNotEmpty) {
          imageUrl = await resolveLiveBackgroundUrl(background);
        } else if (portrait.trim().isNotEmpty) {
          imageUrl = await resolvePortraitUrl(portrait);
        }
      } catch (_) {
        // 解析失败时传空 URL，由图片选择页显示默认空状态。
      }
      onTap(imageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: [
            _buildImage(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.55),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: const Text(
                  '更换封面',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (background.trim().isNotEmpty) {
      return CustomLiveBackground(
        background: background,
        width: size,
        height: size,
      );
    }
    if (portrait.trim().isNotEmpty) {
      return CustomPortrait(
        portrait: portrait,
        size: size,
        radius: radius,
      );
    }
    return Image.asset(
      'assets/images/default-portrait.jpeg',
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}
