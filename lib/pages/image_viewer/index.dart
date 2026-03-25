import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../utils/getx_config/config.dart';
import './logic.dart';

//展示多组图片，下方有小红点代表位置
class ImageViewerPage extends CustomWidget<ImageViewerLogic> {
  ImageViewerPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,  // 内容延伸到 AppBar 下方（让图片可以延伸到状态栏区域，实现全屏效果）
      extendBody: true,              // 内容延伸到底部导航栏下方(让图片可以延伸到底部安全区域)
      //AnnotatedRegion - 状态栏样式
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light, // 状态栏图标为浅色（白色
        child: Stack(
          children: [
            // 底层：图片查看器
            GestureDetector(
              onLongPress: () => _showSaveDialog(context),  // 长按触发
              //图片查看器
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(), // 滚动效果
                itemCount: controller.imageUrls.length, // 图片数量
                pageController: controller.pageController,     // 页面控制器
                onPageChanged: controller.onPageChanged,       // 切换回调

                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(controller.imageUrls[index]),  // 网络图片
                    initialScale: PhotoViewComputedScale.contained,           // 初始缩放
                    minScale: PhotoViewComputedScale.contained * 0.8,         // 最小缩放
                    maxScale: PhotoViewComputedScale.covered * 2,             // 最大缩放
                    heroAttributes: PhotoViewHeroAttributes( //用于 Hero 动画，图片从缩略图放大到全屏时的过渡效果。
                        tag: controller.imageUrls[index]),  // Hero 动画标签
                  );
                },
                //加载中
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    color: theme.primaryColor,
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
            // 上层：底部指示器
            Obx(() => Positioned(
                  bottom: 20,   // 距离底部 20 像素
                  left: 0,      // 占满整个宽度
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.imageUrls.length, // 根据图片数量生成圆点
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,   // 圆形
                          color: controller.currentIndex.value == index
                              ? Colors.white        // 当前图片：白色圆点
                              : Colors.white.withValues(alpha: 0.5),  // 其他：半透明
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  //保存弹窗
  void _showSaveDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('保存图片'),
              onTap: () {
                Navigator.pop(context);
                controller.saveImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('取消'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
