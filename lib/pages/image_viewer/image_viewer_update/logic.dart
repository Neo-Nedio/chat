import 'dart:io';

import 'package:get/get.dart';
import 'package:image_gallery_saver2_fixed/image_gallery_saver2_fixed.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../../../components/custom_flutter_toast/index.dart';
import '../../../utils/cropPicture.dart';

class ImageViewerUpdateLogic extends GetxController {
  late RxString imageUrl = ''.obs;      // 当前图片URL（响应式）
  late RxString text = ''.obs;          // 按钮文字（响应式）
  late UploadPictureCallback onConfirm; // 更换图片后的回调函数
  late RxBool isUpdate = true.obs; //控制是否显示更换图片按钮

  @override
  void onInit() {
    imageUrl.value = Get.arguments['imageUrl'] ?? '';
    text.value = Get.arguments['text'] ?? '更改头像';
    onConfirm = Get.arguments['onConfirm'] ?? (File file) async {};
    isUpdate.value = Get.arguments['isUpdate'] ?? true;
    super.onInit();
  }

  //裁剪图片并上传
  Future cropChatBackgroundPicture(ImageSource? type) async =>
      cropPicture(type, onUpdate);

  //保存图片
  Future<void> saveImage() async {
    try {
      // 检查权限
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
      final response = await http.get(Uri.parse(imageUrl.value));
      final bytes = response.bodyBytes;
      // 保存到相册
      final result = await ImageGallerySaver.saveImage(bytes,
          quality: 100, name: "image_${DateTime.now().millisecondsSinceEpoch}");
      CustomFlutterToast.showSuccessToast("保存成功${result['filePath']}");
    } catch (e) {
      CustomFlutterToast.showErrorToast("保存失败");
    }
  }

  //图片更新回调
  Future<void> onUpdate(File file) async {
    onConfirm(file);  // 调用外部传入的回调，上传新图片
    Get.back();       // 返回上一页
  }
}
