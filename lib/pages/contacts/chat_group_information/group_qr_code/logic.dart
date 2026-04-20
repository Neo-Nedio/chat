import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../api/chat_group_api.dart';
import '../../../../api/qr_api.dart';

class GroupQRCodeLogic extends GetxController {
  final _qrApi = QrApi();
  final _chatGroupApi = ChatGroupApi();

  //群聊id
  late final String chatGroupId = Get.arguments['chatGroupId'].toString();

  //群聊详情（头像、名称、群号等）
  late dynamic groupInfo = Get.arguments['groupInfo'] ?? {};

  //二维码内容
  String qrCode = '';

  @override
  void onInit() {
    super.onInit();
    //如果调用方没有传 groupInfo，再去拉一遍详情
    if (groupInfo.isEmpty) {
      _onGetGroupDetails();
    }
    onQrCode();
  }

  //获取群详情（兜底）
  void _onGetGroupDetails() {
    _chatGroupApi.details(chatGroupId).then((res) {
      if (res['code'] == 0) {
        groupInfo = res['data'];
        update([const Key("group_qr_code")]);
      }
    });
  }

  //获取二维码内容
  void onQrCode() {
    _qrApi.code('group', groupId: chatGroupId).then((res) {
      if (res['code'] == 0) {
        qrCode = res['data'];
        update([const Key("group_qr_code")]);
      }
    });
  }
}
