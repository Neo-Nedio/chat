import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver2_fixed/image_gallery_saver2_fixed.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../../components/custom_flutter_toast/index.dart';

class ImageViewerLogic extends GetxController {
  late final PageController pageController;     // 页面控制器，控制左右滑动
  late final List<String> imageUrls;            // 图片URL列表
  final RxInt currentIndex = 0.obs;             // 当前显示的图片索引（响应式）

  @override
  void onInit() {
    // 从路由参数获取图片列表
    imageUrls = Get.arguments['imageUrls'];
    // 从路由参数获取当前要显示第几张
    currentIndex.value = Get.arguments['currentIndex'];
    // 创建 PageController，初始页面为当前索引
    pageController = PageController(initialPage: currentIndex.value);
    super.onInit();
  }

  //页面切换回调
  void onPageChanged(int index) {
    currentIndex.value = index;
    update();
  }

  //保存图片
  Future<void> saveImage() async {
    try {
      //检查权限
      // 兼容 Android 13+ 权限
      if (await Permission.photos.isGranted) {
        // Android 13+ 已有权限
      } else if (await Permission.storage.isGranted) {
        // Android 12 及以下已有权限
      } else {
        // 请求权限
        if (await Permission.photos.request().isGranted ||
            await Permission.storage.request().isGranted) {
          // 权限获取成功
        } else {
          CustomFlutterToast.showErrorToast("需要存储权限才能保存图片");
          return;
        }
      }

      // 下载图片
      final response = await http.get(Uri.parse(imageUrls[currentIndex.value]));
      final bytes = response.bodyBytes;

      // 保存到相册
      final result = await ImageGallerySaver.saveImage(
          bytes,
          quality: 100, // 图片质量 100%
          name: "image_${DateTime.now().millisecondsSinceEpoch}"); // 文件名：image_时间戳

      if (result != null && result['isSuccess'] == true) {
        CustomFlutterToast.showSuccessToast("保存成功");
      } else {
        CustomFlutterToast.showErrorToast("保存失败");
      }
    } catch (e) {
      // 失败用错误 Toast
      CustomFlutterToast.showErrorToast("保存失败~");
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
