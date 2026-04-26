import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_loading.dart';

//单张图片展示组件，支持网络图片加载、缓存、点击查看大图。
class CustomImage extends StatelessWidget {
  final String url;

  const CustomImage({super.key, required this.url});

  void onOpenImage() {
    Get.toNamed('/image_viewer_update', arguments: {
      'imageUrl': url,
      'isUpdate': false,  //只读模式，不显示更换按钮
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenImage, // 点击查看大图
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        child: CachedNetworkImage(
          width: double.infinity,  // 宽度占满父容器
          imageUrl: url,
          // 加载中
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: Center(
              child: appLoadingInkDrop(
                color: const Color(0xffffffff),
                size: 28,
              ),
            ),
          ),
          // 加载失败
          errorWidget: (context, url, error) =>
              Image.asset('assets/images/empty-image.png'),
        ),
      ),
    );
  }
}
