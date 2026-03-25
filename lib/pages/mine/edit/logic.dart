import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_pickers/time_picker/model/date_type.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getx;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' show MultipartFile, FormData;

import '../../../api/user_api.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../../../utils/cropPicture.dart';
import '../../../utils/getx_config/GlobalThemeConfig.dart';
import '../logic.dart';

//个人资料编辑页面逻辑
class EditMineLogic extends getx.GetxController {

  //上个页面控制器(用于返回上一个页面)
  final MineLogic _mineLogic = getx.Get.find<MineLogic>();

  final GlobalThemeConfig _theme = getx.GetInstance().find<GlobalThemeConfig>();

  //记录最初主题颜色
  late final String _originThemeMode;
  bool _isThemeCommitted = false;//修改的主题是否提交

  //当页面返回时，销毁控制器
  @override
  void onClose() {
    //未提交时回退原主题
    if (!_isThemeCommitted) {
      _theme.changeThemeMode(_originThemeMode);
    }
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
    _originThemeMode = _theme.themeMode;
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
      CustomFlutterToast.showSuccessToast('头像修改成功');
      //保存头像并更新
      currentUserInfo['portrait'] = result['data'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('portrait', currentUserInfo['portrait']);
      update([const Key("edit_mine")]);
    } else {
      // 失败：显示错误提示
      CustomFlutterToast.showErrorToast(result['msg']);
    }
  }

  //点击头像按钮弹出底部选择框
  void selectPortrait() {
    if (!isEdit) return;
    getx.Get.toNamed('/image_viewer_update', arguments: {
      'imageUrl': currentUserInfo['portrait'],
      'onConfirm': _uploadPicture
    });
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
  //changeTheme代表是否需要在中过程中改变主题
  void setSexValue(String value, {bool changeTheme = true}) {
    sex = value;
    if (changeTheme) {
      _theme.changeThemeMode(sex == "女" ? "pink" : "blue");
    }
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
    final iniDate = PDuration.parse(birthday);//// 解析初始日期

    Pickers.showDatePicker(
      context,
      maxDate: PDuration.parse(DateTime.now()),      // 最大日期（今天）
      minDate: PDuration.parse(DateTime(1900, 1, 1)), // 最小日期（1900-01-01）
      // 样式配置
      pickerStyle: PickerStyle(
        commitButton: Container(//确定按钮样式
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 12, right: 22),
          child: Text('确定',
              style: TextStyle(color: _theme.primaryColor, fontSize: 16.0)),
        ),
        headDecoration: BoxDecoration( //头部背景色（根据性别变化）
          color:
          sex == "女" ? const Color(0xFFfcebff) : const Color(0xFFe6f2ff),
        ),
        backgroundColor: //头部背景色（根据性别变化）
        sex == "女" ? const Color(0xFFfcebff) : const Color(0xFFe6f2ff),
      ),

      selectDate: iniDate, // 默认选中的日期

      // 滑动时回调
      onChanged: (res) {
        birthday = DateTime(
          res.getSingle(DateType.Year),   // 获取年份
          res.getSingle(DateType.Month),  // 获取月份
          res.getSingle(DateType.Day),    // 获取日期
        );
        birthdayController.text = DateFormat('yyyy-MM-dd').format(birthday);
      },
      // 确认时回调
      onConfirm: (res) {
        birthday = DateTime(
          res.getSingle(DateType.Year),   // 获取年份
          res.getSingle(DateType.Month),  // 获取月份
          res.getSingle(DateType.Day),    // 获取日期
        );
        birthdayController.text =
            DateFormat('yyyy-MM-dd').format(birthday); // 格式化日期
      },
    );
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
      String name = nameController.text;
      String signature = signatureController.text;
      String birthday = this.birthday.toString();
      String portrait = currentUserInfo['portrait'];

      //调用 API 保存
      final updateResult = await _useApi.update(
          name: name,
          sex: sex,
          birthday: birthday,
          signature: signature,
          portrait: portrait);

      //处理保存结果
      if (updateResult['code'] == 0) {
        // 显示成功提示
        CustomFlutterToast.showSuccessToast('资料修改成功~');

        // 保存到本地缓存
        await prefs.setString('username', name);
        await prefs.setString('portrait', portrait);
        await prefs.setString('sex', sex);
        await prefs.setString('birthday', birthday);
        await prefs.setString('signature', signature);
        // 更新当前数据
        currentUserInfo['portrait'] = portrait;
        // 退出编辑模式
        isEdit = false;

        // 性别变更后主题应立即切换：GlobalThemeConfig 无 GetBuilder 订阅，需顺带刷新主界面
        //否则只有在导航栏点击其他页面时，才会触发刷新
        _theme.changeThemeMode(
            sex == '女' ? 'pink' : 'blue');
        //确认提交了新主题
        _isThemeCommitted = true;
        //刷新导航页面
        _mineLogic.init();
      } else {
        //保存失败
        CustomFlutterToast.showErrorToast(updateResult['msg']);
      }
    } catch (e, st) {
      //异常处理
      CustomFlutterToast.showErrorToast('保存失败，请检查网络');
    }
  }

  //初始化加载数据
  Future<void> _loadUserFromServer() async {
    try {
      //优先使用本地缓存，如果本地没有则用服务端数据
      final userInfo = await _useApi.info();
      final prefs = await SharedPreferences.getInstance();
      currentUserInfo['name'] =
          prefs.getString('username') ?? userInfo['data']['name'];
      currentUserInfo['portrait'] =
          prefs.getString('portrait') ?? userInfo['data']['portrait'];
      nameController.text = currentUserInfo['name'];
      nameTextLength = nameController.text.length;
      sex = prefs.getString('sex') ?? userInfo['data']['sex'];
      setSexValue(sex, changeTheme: false);
      currentUserInfo['sex'] = sex;
      birthday = DateTime.parse(userInfo['data']['birthday']).toLocal();
      birthdayController.text =
          DateFormat('yyyy-MM-dd').format(birthday); // 格式化日期
      currentUserInfo['birthday'] = birthday;
      signatureController.text =
          prefs.getString('signature') ?? userInfo['data']['signature'];
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
