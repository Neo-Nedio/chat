import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../api/chat_group_notice_api.dart';
import '../../../../components/CustomDialog/index.dart';
import '../../../../components/custom_flutter_toast/index.dart';

class ChatGroupNoticeLogic extends GetxController {
  final _chatGroupNoticeApi = ChatGroupNoticeApi();
  late String chatGroupId;                           // 群聊ID
  late List<dynamic> chatGroupNoticeList = [];       // 公告列表
  late bool isOwner = false;                         // 是否是群主

  @override
  void onInit() {
    super.onInit();
    chatGroupId = Get.arguments['chatGroupId'];    // 从路由获取群ID
    isOwner = Get.arguments['isOwner'] ?? false;   // 获取是否是群主
    onGetChatGroupNoticeList();                    // 获取公告列表
  }

  // 获取公告列表
  void onGetChatGroupNoticeList() {
    _chatGroupNoticeApi.list(chatGroupId).then((res) {
      if (res['code'] == 0) {
        chatGroupNoticeList = res['data'];
        update([const Key('chat_group_notice')]);
      }
    });
  }

  //删除公告
  void onDelChatGroupNotice(context, String id) {
    CustomDialog.showTipDialog(
      context,
      text: '确定删除该条公告?',
      onOk: () {
        _chatGroupNoticeApi.delete(chatGroupId, id).then((res) {
          if (res['code'] == 0) {
            CustomFlutterToast.showSuccessToast('删除成功~');
            onGetChatGroupNoticeList();
          }
        });
      },
      onCancel: () {},
    );
  }

  //编辑公告
  void handlerEditNotice(String id, String content) async {
    var result = await Get.toNamed('/add_chat_group_notice', arguments: {
      'chatGroupId': chatGroupId,
      'chatGroupNoticeId': id,
      'content': content,
    });
    //result为编辑页面返回的bool值
    if (result != null && result) {
      onGetChatGroupNoticeList();
    }
  }

  // 添加公告
  void handlerAddNotice() async {
    var result = await Get.toNamed('/add_chat_group_notice', arguments: {
      'chatGroupId': chatGroupId,
    });
    //result为编辑页面返回的bool值
    if (result != null && result) {
      onGetChatGroupNoticeList();
    }
  }
}
