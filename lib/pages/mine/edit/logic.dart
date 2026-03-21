import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getx;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' show MultipartFile, FormData;

import '../../../api/user_api.dart';
import '../../../utils/cropPicture.dart';
import '../logic.dart';

//个人资料编辑页面逻辑
class EditMineLogic extends getx.GetxController {

  //上个页面控制器(用于返回上一个页面)
  final MineLogic _mineLogic = getx.Get.find<MineLogic>();

  //当页面返回时，销毁控制器
  @override
  void onClose() {
    super.onClose();
    nameController.dispose();
    signatureController.dispose();
    birthdayController.dispose();
    //以及返回上一页时更新页面
    _mineLogic.init();
  }

  //初始化
  @override
  void onInit() {
    super.onInit();
    _loadUserFromServer();
  }

  //用户API
  final _useApi = UserApi();

  //用户名输入框控制器
  final TextEditingController nameController = TextEditingController();

  //签名输入框控制器
  final TextEditingController signatureController = TextEditingController();

  //生日显示用（只读）
  final TextEditingController birthdayController = TextEditingController();

  //当前用户信息
  Map<String, dynamic> currentUserInfo = {};

  //是否处于编辑状态
  bool _isEdit = false;
  bool get isEdit => _isEdit;
  set isEdit(bool value) {
    _isEdit = value;
    update([const Key("edit_mine")]);
  }

  //用户名输入长度
  int _nameTextLength = 0;
  int get nameTextLength => _nameTextLength;
  set nameTextLength(int value) {
    _nameTextLength = value;
    update([const Key("edit_mine")]);
  }

  //用户账号输入长度
  void onNameTextChanged(String value) {
    nameTextLength = value.length;
    if (nameTextLength >= 30) nameTextLength = 30;
  }

  //个性签名输入长度
  int _signatureTextLength = 0;
  int get signatureTextLength => _signatureTextLength;
  set signatureTextLength(int value) {
    _signatureTextLength = value;
    update([const Key("edit_mine")]);
  }

  //个性签名输入长度
  void onSignatureTextChanged(String value) {
    signatureTextLength = value.length;
    if (signatureTextLength >= 100) signatureTextLength = 100;
  }

  //性别（先给默认值，避免异步拉取用户信息前访问 late 字段崩溃）
  String _sex = '男';
  String get sex => _sex;
  set sex(String value) {
    _sex = value;
    update([const Key("edit_mine")]);
  }


  //上传头像（需与 cropPicture 的 UploadPictureCallback 一致：Future<void> Function(File)）
  Future<void> _uploadPicture(File picture) async {
    // 1. 构建 FormData
    Map<String, dynamic> map = {};
    final file = await MultipartFile.fromFile(picture.path,
        filename: picture.path.split('/').last);
    map['type'] = 'image/jpeg';
    map['name'] = picture.path.split('/').last;
    map['size'] = picture.lengthSync();
    map["file"] = file;
    FormData formData = FormData.fromMap(map);

    // 2. 调用上传 API
    final result = await _useApi.upload(formData);

    // 3. 处理结果
    if (result['code'] == 0) {
      Fluttertoast.showToast(
          msg: "头像修改成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color(0xFF4C9BFF),
          textColor: Colors.white,
          fontSize: 16.0);
      //保存头像并更新
      currentUserInfo['portrait'] = result['data'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('portrait', currentUserInfo['portrait']);
      update([const Key("edit_mine")]);
    } else {
      // 失败：显示错误提示
      Fluttertoast.showToast(
          msg: result['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  //裁剪图片并上传
  Future<void> _cropChatBackgroundPicture(ImageSource? type) async {
    await cropPicture(type, _uploadPicture);
  }

  //点击头像按钮弹出底部选择框
  void selectPortrait(BuildContext context) {
    if (!isEdit) {
      isEdit = true; // 自动进入编辑模式
    }
    // 弹出底部选择框
    getx.Get.bottomSheet(
      Container( // 选择框内容
      decoration: const BoxDecoration(
        color: Colors.white60, // 半透明白色背景
      ),
      child: Wrap( // Wrap 让内容自适应高度
        children: [
          ListTile(
            leading: const Icon(Icons.photo),  // 左侧图标
            title: const Text("图库"),          // 标题文字
            onTap: () {
              getx.Get.back();  // 先关闭底部弹窗
              _cropChatBackgroundPicture(null);//null 表示从图库选择图片
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),  // 相机图标
            title: const Text("拍照"),               // 标题文字
            onTap: () {
              getx.Get.back();  // 先关闭底部弹窗
              _cropChatBackgroundPicture(ImageSource.camera);//拍照
            },
          )
        ],
      ),
    ));
  }

  ///男性选中：蓝色背景 + 白色文字
  //男性按钮背景色
  Color _maleColorActive = const Color(0xFFe0e0e0);
  Color get maleColorActive => _maleColorActive;
  set maleColorActive(Color value) {
    _maleColorActive = value;
    update([const Key("edit_mine")]);
  }
  //男性按钮文字色
  Color _maleTextColorActive = const Color(0xFF727275);
  Color get maleTextColorActive => _maleTextColorActive;
  set maleTextColorActive(Color value) {
    _maleTextColorActive = value;
    update([const Key("edit_mine")]);
  }

  ///女性选中：粉色背景 + 白色文字
  //女性按钮背景色
  Color _femaleColorActive = const Color(0xFFe0e0e0);
  Color get femaleColorActive => _femaleColorActive;
  set femaleColorActive(Color value) {
    _femaleColorActive = value;
    update([const Key("edit_mine")]);
  }
  //女性按钮文字色
  Color _femaleTextColorActive = const Color(0xFF727275);
  Color get femaleTextColorActive => _femaleTextColorActive;
  set femaleTextColorActive(Color value) {
    _femaleTextColorActive = value;
    update([const Key("edit_mine")]);
  }

  //设置性别值
  void setSexValue(String value) {
    sex = value;
    ///男性选中：蓝色背景 + 白色文字
    if (value == "男") {
      maleColorActive = const Color(0xFF4C9BFF);
      maleTextColorActive = Colors.white;
      femaleColorActive = const Color(0xFFe0e0e0);
      femaleTextColorActive = const Color(0xFF727275);
    } else {
      ///女性选中：粉色背景 + 白色文字
      maleColorActive = const Color(0xFFe0e0e0);
      maleTextColorActive = const Color(0xFF727275);
      femaleColorActive = const Color(0xFFffa0cf);
      femaleTextColorActive = Colors.white;
    }
  }

  //设置性别（与生日一致：未编辑时先进入编辑态）
  void setSex(String value) {
    if (!isEdit) {
      isEdit = true;
    }
    setSexValue(value);
  }


  //生日(默认 2000-01-01，避免 null 错误)
  DateTime _birthday = DateTime(2000, 1, 1);
  DateTime get birthday => _birthday;
  set birthday(DateTime value) {
    _birthday = value;
    update([const Key("edit_mine")]);
  }

  //选择生日（未点「编辑资料」时先自动进入编辑态，否则用户会感觉「点日历没反应」）
  Future<void> selectDate(BuildContext context) async {
    if (!isEdit) {
      isEdit = true;
    }
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != birthday) {
      birthday = pickedDate;
      birthdayController.text = DateFormat('yyyy-MM-dd').format(birthday);
    }
  }

  //点击保存按钮进行网络请求
  Future<void> onPressed() async {
    if (!isEdit) {
      isEdit = true;  // 第一次点击：进入编辑模式
      return;         // 直接返回，不执行保存
    }
    // 第二次点击：执行保存逻辑
    try {
      //数据准备
      final prefs = await SharedPreferences.getInstance();
      final name = nameController.text.trim();
      final signature = signatureController.text;
      // 本地展示与 SharedPreferences 仍用 yyyy-MM-dd
      final birthdayStr = DateFormat('yyyy-MM-dd').format(birthday);
      // 服务端 Jackson 对字符串日期解析失败时，用毫秒时间戳（JSON 数字）最稳妥
      final birthdayMillis = DateTime.utc(birthday.year, birthday.month, birthday.day)
          .millisecondsSinceEpoch;
      final portrait = (currentUserInfo['portrait'] ?? '').toString();

      //调用 API 保存
      final updateResult = await _useApi.update(
        name: name,
        sex: sex,
        birthdayMillis: birthdayMillis,  // 服务端用时间戳，避免日期格式问题
        signature: signature,
        portrait: portrait,
      );

      //处理保存结果
      if (updateResult['code'] == 0) {
        // 显示成功提示
        Fluttertoast.showToast(
            msg: "资料修改成功",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: const Color(0xFF4C9BFF),
            textColor: Colors.white,
            fontSize: 16.0);

        // 保存到本地缓存
        await prefs.setString('username', name);
        await prefs.setString('portrait', portrait);
        await prefs.setString('sex', sex);
        await prefs.setString('birthday', birthdayStr);
        await prefs.setString('signature', signature);
        // 更新当前数据
        currentUserInfo['portrait'] = portrait;
        // 退出编辑模式
        isEdit = false;

      } else {
        //保存失败
        Fluttertoast.showToast(
            msg: updateResult['msg']?.toString() ?? '保存失败',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e, st) {
      //异常处理
      debugPrint('EditMine save error: $e\n$st');
      Fluttertoast.showToast(
          msg: '保存失败，请检查网络',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  //初始化加载数据
  Future<void> _loadUserFromServer() async {
    try {
      //优先使用本地缓存，如果本地没有则用服务端数据
      final userInfo = await _useApi.info();
      final prefs = await SharedPreferences.getInstance();
      final data = userInfo['data'] as Map<String, dynamic>? ?? {};
      currentUserInfo['name'] =
          prefs.getString('username') ?? data['name']?.toString() ?? '';
      currentUserInfo['portrait'] =
          prefs.getString('portrait') ?? data['portrait']?.toString() ?? '';
      nameController.text = currentUserInfo['name']?.toString() ?? '';
      nameTextLength = nameController.text.length;
      final sexStr = prefs.getString('sex') ?? data['sex']?.toString() ?? '男';

      // // 设置性别并更新 UI 样式
      setSexValue(sexStr);
      currentUserInfo['sex'] = sex;

      // 加载生日（带异常处理）
      try {
        final raw = data['birthday']?.toString();
        if (raw != null && raw.isNotEmpty) {
          birthday = DateTime.parse(raw).toLocal();
        }
      } catch (_) {
        birthday = DateTime(2000, 1, 1);
      } // 解析失败时用默认值
      birthdayController.text = DateFormat('yyyy-MM-dd').format(birthday);
      currentUserInfo['birthday'] = birthday;
      //加载签名
      signatureController.text =
          prefs.getString('signature') ?? data['signature']?.toString() ?? '';
      signatureTextLength = signatureController.text.length;
      update([const Key("edit_mine")]);
    } catch (e, st) {
      debugPrint('EditMine load error: $e\n$st');
      Fluttertoast.showToast(
          msg: '加载资料失败',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

}
