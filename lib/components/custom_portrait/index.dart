import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

//自定义头像组件
class CustomPortrait extends StatelessWidget {
  final double size;
  final String url;
  final double radius;
  final VoidCallback? onTap;

  const CustomPortrait({
    super.key,
    this.size = 50,
    required this.url,
    this.radius = 25,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.asset(
            'assets/images/default-portrait.jpeg',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap, //回调函数
      child: ClipRRect(
        // 圆角头像
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          // 缓存网络图片
          imageUrl: url, // 头像URL
          width: size,
          height: size,
          fit: BoxFit.cover, // 图片铺满整个区域
          // 图片加载时的占位组件
          placeholder: (context, url) => Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: const Center(
              // 居中显示
              child: CircularProgressIndicator(
                // 圆形进度条
                color: Color(0xffffffff), // 白色
                strokeWidth: 2, // 线条粗细2
              ),
            ),
          ),
          // 图片加载失败时的占位组件
          errorWidget: (context, url, error) => Container(
            width: size,
            height: size,
            color: Colors.grey[300], // 灰色背景
            child: Image.asset('assets/images/default-portrait.jpeg'),
          ),
        ),
      ),
    );
  }
}
