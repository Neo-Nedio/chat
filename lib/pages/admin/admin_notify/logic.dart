import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:dio/dio.dart' show MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';

import '../../../api/notify_api.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../../../utils/cropPicture.dart';

class AdminNotifyLogic extends GetxController {
  final _notifyApi = NotifyApi();

  final titleController = TextEditingController();
  final textController = TextEditingController();

  File? selectedImage;  //选择的图片
  bool isSubmitting = false;

  @override
  void onClose() {
    titleController.dispose();
    textController.dispose();
    super.onClose();
  }

  //展示图片选择选项
  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('相册'),
              onTap: () {
                Navigator.pop(ctx);
                cropPicture(null, _onImageSelected, isVariable: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(ctx);
                cropPicture(ImageSource.camera, _onImageSelected, isVariable: true);
              },
            ),
          ],
        );
      },
    );
  }

  //选择好图片好把图片赋值给selectedImage，用于展示
  Future<void> _onImageSelected(File file) async {
    selectedImage = file;
    update([const Key('admin_notify')]);
  }

  //发布通知
  Future<void> onSubmit() async {
    final title = titleController.text.trim();
    final text = textController.text.trim();

    if (title.isEmpty) {
      CustomFlutterToast.showErrorToast('标题不能为空~');
      return;
    }
    if (selectedImage == null) {
      CustomFlutterToast.showErrorToast('请选择图片~');
      return;
    }
    if (text.isEmpty) {
      CustomFlutterToast.showErrorToast('内容不能为空~');
      return;
    }

    isSubmitting = true;
    update([const Key('admin_notify')]);

    try {
      final file = await MultipartFile.fromFile(
        selectedImage!.path,
        filename: selectedImage!.path.split('/').last,
      );

      final formData = FormData.fromMap({
        'file': file,
        'title': title,
        'text': text,
      });

      final result = await _notifyApi.createNotify(formData);

      if (result['code'] == 0) {
        CustomFlutterToast.showSuccessToast('通知发布成功~');
        Get.back();
      } else {
        CustomFlutterToast.showErrorToast(result['msg'] ?? '发布失败~');
      }
    } catch (e) {
      CustomFlutterToast.showErrorToast('发布失败，请检查网络~');
    } finally {
      isSubmitting = false;
      update([const Key('admin_notify')]);
    }
  }
}
