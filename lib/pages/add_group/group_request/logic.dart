import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/notify_api.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../../../utils/getx_config/config.dart';

class GroupRequestLogic extends Logic {
  final _notifyApi = NotifyApi();

  final TextEditingController applyGroupController = TextEditingController();

  // 群信息（id / name / portrait）
  dynamic get _groupInfo => arguments['groupInfo'];

  //群头像
  String _groupPortrait = '';
  String get groupPortrait => _groupPortrait;
  set groupPortrait(String value) {
    _groupPortrait = value;
    update([const Key('group_request')]);
  }

  //群名称
  String _groupName = '';
  String get groupName => _groupName;
  set groupName(String value) {
    _groupName = value;
    update([const Key('group_request')]);
  }

  //申请信息文本长度
  int _applyGroupLength = 0;
  int get applyGroupLength => _applyGroupLength;
  set applyGroupLength(int value) {
    _applyGroupLength = value;
    update([const Key('group_request')]);
  }

  void initData() {
    groupPortrait = (_groupInfo['portrait'] ?? '').toString();
    groupName = (_groupInfo['name'] ?? '').toString();
  }

  //申请信息文本长度改变
  void applyGroupTextChanged(String value) {
    applyGroupLength = value.length;
    if (applyGroupLength >= 100) applyGroupLength = 100;
  }

  //群聊申请
  void applyGroup() async {
    final result = await _notifyApi.groupApply(
      _groupInfo['id'].toString(),
      applyGroupController.text,
    );
    if (result['code'] == 0) {
      CustomFlutterToast.showSuccessToast("申请成功，等待群主验证~");
      Future.delayed(const Duration(milliseconds: 2300), () => Get.back());
    } else {
      CustomFlutterToast.showErrorToast(result['msg']);
    }
  }

  @override
  void onInit() {
    super.onInit();
    initData();
  }
}
