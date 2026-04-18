import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/notify_api.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../../../utils/getx_config/config.dart';

class FriendRequestLogic extends Logic {
  final _notifyApi = NotifyApi();

  final TextEditingController applyFriendController = TextEditingController();

  dynamic get _friendInfo => arguments['friendInfo'];

  //好友头像
  String _friendPortrait = '';
  String get friendPortrait => _friendPortrait;
  set friendPortrait(String value) {
    _friendPortrait = value;
    update([const Key('friend_request')]);
  }

  //好友昵称
  String _friendName = '';
  String get friendName => _friendName;
  set friendName(String value) {
    _friendName = value;
    update([const Key('friend_request')]);
  }

  //申请信息文本长度
  int _applyFriendLength = 0;
  int get applyFriendLength => _applyFriendLength;
  set applyFriendLength(int value) {
    _applyFriendLength = value;
    update([const Key('friend_request')]);
  }

  void initData() {
    friendPortrait = _friendInfo['portrait'];
    friendName = _friendInfo['name'];
  }

  //申请信息文本长度改变
  void applyFriendTextChanged(String value) {
    applyFriendLength = value.length;
    if (applyFriendLength >= 100) applyFriendLength = 100;
  }

  //好友请求
  void applyFriend() async {
    final result = await _notifyApi.friendApply(
      _friendInfo['id'],
      applyFriendController.text,
    );
    if (result['code'] == 0) {
      CustomFlutterToast.showSuccessToast("申请成功，等待对方验证~");
      Future.delayed(const Duration(milliseconds: 500), () => Get.back());
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
