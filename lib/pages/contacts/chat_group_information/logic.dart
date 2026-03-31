import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' show Get, GetNavigation, GetxController, Inst;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' show MultipartFile, FormData;

import '../../../api/chat_group_api.dart';
import '../../../api/chat_group_member.dart';
import '../../../components/CustomDialog/index.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../../../utils/getx_config/GlobalData.dart';

class ChatGroupInformationLogic extends GetxController {
  final _chatGroupApi = ChatGroupApi();
  final _chatGroupMemberApi = ChatGroupMemberApi();

  late bool isOwner = false; // 当前用户是否是群主

  //群聊详情
  late dynamic chatGroupDetails = {
    'id': '',
    'userId': '',
    'ownerUserId': '',
    'portrait': '',
    'name': '',
    'notice': {},
    'memberNum': '',
    'groupName': '',
    'groupRemark': '',
  };
  // 群成员列表
  late List<dynamic> chatGroupMembers = [];
  // 从路由参数获取的群聊 ID
  final String chatGroupId = Get.arguments['chatGroupId'];

  @override
  void onInit() {
    () async {
      await onGetGroupChatDetails();                    // 1. 获取群详情
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');          // 获取当前用户 ID
      if (userId == chatGroupDetails['ownerUserId']) {   // 判断是否为群主
        isOwner = true;
      }
    }();
    onGetGroupChatMembers();   // 2. 获取成员列表
    super.onInit();
  }

  //获取群聊详情
  Future<void> onGetGroupChatDetails() async {
    await _chatGroupApi.details(chatGroupId).then((res) {
      if (res['code'] == 0) {
        chatGroupDetails = res['data'];
        update([const Key('chat_group_info')]);
      }
    });
  }

  //获取群成员列表
  void onGetGroupChatMembers() async {
    //只获取十个
    _chatGroupMemberApi.listPage(chatGroupId).then((res) {
      if (res['code'] == 0) {
        chatGroupMembers = res['data'];
        update([const Key('chat_group_info')]);
      }
    });
  }

  //更新群头像
  Future<void> _onUpdateChatGroupPortrait(File picture) async {
    Map<String, dynamic> map = {};
    final file = await MultipartFile.fromFile(picture.path,
        filename: picture.path.split('/').last);
    map['type'] = 'image/jpeg';
    map['name'] = picture.path.split('/').last;
    map['size'] = picture.lengthSync();
    map["file"] = file;
    map['groupId'] = chatGroupId;
    FormData formData = FormData.fromMap(map);
    final result = await _chatGroupApi.upload(formData);
    if (result['code'] == 0) {
      CustomFlutterToast.showSuccessToast('头像修改成功');
      chatGroupDetails['portrait'] = result['data'];
      update([const Key("chat_group_info")]);
    } else {
      CustomFlutterToast.showErrorToast(result['msg']);
    }
  }

  //选择头像
  void selectPortrait() {
    Get.toNamed('/image_viewer_update', arguments: {
      'imageUrl': chatGroupDetails['portrait'],
      'onConfirm': _onUpdateChatGroupPortrait,
      'isUpdate': isOwner //不是群主时不可编辑
    });
  }

  //设置群名
  void setGroupName() async {
    var result = await Get.toNamed('/set_group_name', arguments: {
      'chatGroupId': chatGroupId,
      'name': chatGroupDetails['name']
    });
    if (result != null) {
      chatGroupDetails['name'] = result;
      update([const Key("chat_group_info")]);
    }
  }

  //设置群备注
  void setGroupRemark() async {
    var result = await Get.toNamed('/set_group_remark', arguments: {
      'chatGroupId': chatGroupId,
      'remark': chatGroupDetails['groupRemark'] ?? ''
    });
    if (result != null) {
      chatGroupDetails['groupRemark'] = result;
      update([const Key("chat_group_info")]);
    }
  }

  //设置群昵称
  void setGroupNickname() async {
    var result = await Get.toNamed('/set_group_nickname', arguments: {
      'chatGroupId': chatGroupId,
      'name': chatGroupDetails['groupName'] ?? ''
    });
    if (result != null) {
      chatGroupDetails['groupName'] = result;
      update([const Key("chat_group_info")]);
    }
  }

  //群通知
  void chatGroupNotice() async {
    await Get.toNamed('/chat_group_notice', arguments: {
      'chatGroupId': chatGroupId,
      'isOwner': isOwner,
    });
    if (isOwner) {
      onGetGroupChatDetails();
    }
  }

  //转向群成员页面 （根据参数判断是否进入好友选择）
  void chatGroupMember(bool addFriends) async {
    await Get.toNamed('/chat_group_member', arguments: {
      'chatGroupId': chatGroupId,
      'isOwner': isOwner,
      'chatGroupDetails': chatGroupDetails,
      'addFriends' : addFriends
    });
    //回来时刷新数据
    onGetGroupChatMembers();
    onGetGroupChatDetails();
  }

  //打开好友详情
  void handlerFriendTapped(dynamic friendId) {
    final currentUserId = Get.find<GlobalData>().currentUserId;
    if(friendId != currentUserId){
      Get.toNamed('/friend_info', arguments: {'friendId': friendId});
    }
  }

  //退出群聊
  void onQuitGroup(context) async {
    CustomDialog.showTipDialog(context, text: "确定退出该群聊?", onOk: () {
      _chatGroupApi.quitChatGroup(chatGroupId).then((res) {
        if (res['code'] == 0) {
          CustomFlutterToast.showSuccessToast('退出群聊成功~');
          Get.back(result: true);
        }
      });
    }, onCancel: () {});
  }

  //解散群聊
  void onDissolveGroup(context) async {
    CustomDialog.showTipDialog(context, text: "确定解散该群聊?", onOk: () {
      _chatGroupApi.dissolveChatGroup(chatGroupId).then((res) {
        if (res['code'] == 0) {
          CustomFlutterToast.showSuccessToast('解散群聊成功~');
          Get.back(result: true);
        }
      });
    }, onCancel: () {});
  }
}
