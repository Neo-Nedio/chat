import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart'
    show Get, GetInstance, GetNavigation, GetxController;
import 'package:get/get_rx/get_rx.dart';
import 'package:image_picker/image_picker.dart';

import '../../../api/talk_api.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../logic.dart';

class TalkCreateLogic extends GetxController {
  final _talkApi = TalkApi();                              // API接口
  final contentController = TextEditingController();      // 内容输入框
  final selectedImages = <File>[].obs;                    // 选中的图片（响应式）
  late List<dynamic> selectedUsers = [];                  // 选中的用户（权限设置）

  //父级页面
  TalkLogic get talkLogic => GetInstance().find<TalkLogic>();

  //选择图片 (pickImages)
  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    //XFile 是 image_picker 库中定义的一个类，代表一个跨平台的文件引用。
    final List<XFile>? images = await picker.pickMultiImage(); // 多选图片

    if (images != null) {
      for (var image in images) {
        selectedImages.add(File(image.path));
      }
    }
  }

  //删除图片 (removeImage)
  void removeImage(int index) {
    selectedImages.removeAt(index); // 从列表中移除
  }

  //上传单张图片 (onUploadImg)
  Future<void> onUploadImg(String talkId, File img) async {
    Map<String, dynamic> map = {};
    // 创建文件上传表单
    final file = await MultipartFile.fromFile(img.path,
        filename: img.path.split('/').last);  // 获取文件名

    map['talkId'] = talkId;
    map['name'] = img.path.split('/').last;   // 文件名
    map['size'] = img.lengthSync();            // 文件大小
    map["file"] = file;                        // 文件内容

    FormData formData = FormData.fromMap(map);
    await _talkApi.uploadImg(formData);        // 上传到服务器
  }


  //创建说说 (onCreateTalk)
  void onCreateTalk() {
    if (contentController.text.isEmpty) {
      CustomFlutterToast.showSuccessToast('内容不能为空~');
      return;
    }

    //获取可见用户ID列表
    List permission = selectedUsers.map((user) => user['friendId']).toList();

    //创建说说
    _talkApi.create(contentController.text, permission).then((res) async {
      if (res['code'] == 0) {
        CustomFlutterToast.showSuccessToast('发表成功~');
        Get.back();// 返回上一页
        //上传所有图片
        for (var img in selectedImages) {
          await onUploadImg(res['data']['id'], img);
        }
        //刷新说说列表
        talkLogic.refreshData();
      }
    });
  }

  //跳转用户选择
  Future<void> handlerToUserSelect() async {
    // 跳转到用户选择页面，传入已选中的用户
    var result = await Get.toNamed('/user_select',
        arguments: {'selectedUsers': selectedUsers});
    // 接收返回结果
    if (result != null) {
      selectedUsers = result;  // 更新选中的用户
    }
    update([const Key('talk_create')]);
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}
