import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'getx_config/GlobalThemeConfig.dart';

//定义回调函数类型
typedef UploadPictureCallback = Future<void> Function(File picture);

// 图片剪切
Future cropPicture(
    ImageSource? type,           // 图片来源：相机/图库
    UploadPictureCallback uploadPicture,  // 裁剪完成后的回调
        {isVariable = false}        // 是否可自由调整比例
    )  async {

  //主题配置
  final GlobalThemeConfig theme = GetInstance().find<GlobalThemeConfig>();

  //图片选择器
  final ImagePicker picker = ImagePicker();
  //图片路径
  final XFile? pickedFile =
  await picker.pickImage(source: type ?? ImageSource.gallery); // 如果 type 为 null，默认从图库选择

  //没有图片，直接返回
  if (pickedFile == null) return;

  try {
    // 根据平台创建对应的比例预设列表
    final List<CropAspectRatioPreset> aspectRatios = [
      isVariable
          ? CropAspectRatioPreset.original //自由比例裁剪
          : CropAspectRatioPreset.square, //固定正方形裁剪
    ];

    //裁剪图片
    CroppedFile? croppedFile;

    if (Platform.isAndroid) {
      // Android 平台配置
      croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '剪切',                    // 顶部标题栏文字
            toolbarColor: theme.primaryColor,        // 标题栏背景色（主题色）
            toolbarWidgetColor: Colors.white,        // 标题栏文字颜色
            backgroundColor: Colors.black,           // 整体背景色
            activeControlsWidgetColor: theme.primaryColor, // 控件激活颜色（边框、按钮）
            initAspectRatio: CropAspectRatioPreset.original, // 初始裁剪比例
            lockAspectRatio: !isVariable,            // 是否锁定比例
            dimmedLayerColor: Colors.black54,        // 未选区遮罩颜色
            aspectRatioPresets: aspectRatios,        // 可选的比例列表
          ),
        ],
      );
    } else if (Platform.isIOS) {
      // iOS 平台配置
      croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          IOSUiSettings(
            title: '剪切',                          // 标题
            aspectRatioLockEnabled: !isVariable,   // 是否锁定比例
            resetAspectRatioEnabled: isVariable,   // 是否显示重置比例按钮
            aspectRatioPickerButtonHidden: !isVariable, // 是否隐藏比例选择按钮
            aspectRatioPresets: aspectRatios,      // 可选的比例列表
          ),
        ],
      );
    } else {
      // 其他平台（如Web、MacOS等）的配置
      croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          // Android 风格配置
          AndroidUiSettings(
            toolbarTitle: '剪切',
            toolbarColor: theme.primaryColor,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: theme.primaryColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: !isVariable,
            aspectRatioPresets: aspectRatios,
          ),
          // iOS 风格配置
          IOSUiSettings(
            title: '剪切',
            aspectRatioPresets: aspectRatios,
          ),
        ],
      );
    }

    //裁剪完成后上传
    if (croppedFile != null) {
      File file = File(croppedFile.path);
      await uploadPicture(file);//调用传入的 uploadPicture 回调函数，传入裁剪后的图片文件
    }
  } catch (e) {
    print('裁剪图片时出错: $e');
    Get.snackbar('错误', '图片裁剪失败');
  }
}
