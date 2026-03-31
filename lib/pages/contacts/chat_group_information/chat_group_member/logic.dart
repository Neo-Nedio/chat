import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../api/chat_group_api.dart';
import '../../../../api/chat_group_member.dart';
import '../../../../api/notify_api.dart';
import '../../../../components/CustomDialog/index.dart';
import '../../../../components/custom_flutter_toast/index.dart';
import '../../../../utils/getx_config/GlobalData.dart';

class ChatGroupMemberLogic extends GetxController {
  final _chatGroupMemberApi = ChatGroupMemberApi();
  final _chatGroupApi = ChatGroupApi();
  final _notifyApi = NotifyApi();
  late Map<String, dynamic> members = {};      // 成员原始数据（Map结构）
  late List<dynamic> memberList = [];          // 当前显示的成员列表
  late List<dynamic> allMemberList = [];       // 所有成员列表（备份）

  late String chatGroupId;                     // 群聊ID
  late bool isOwner = false;                   // 是否是群主
  late dynamic chatGroupDetails = {};          // 群聊详情

  @override
  void onInit() async {
    super.onInit();
    chatGroupId = Get.arguments['chatGroupId'];           // 获取群ID
    isOwner = Get.arguments['isOwner'] ?? false;          // 是否是群主
    chatGroupDetails = Get.arguments['chatGroupDetails'] ?? {};  // 群详情

    await onGetMembers();                                  // 获取成员列表（加载完成后再处理自动跳转）

    //判断是否点击添加好友
    final addFriends = Get.arguments['addFriends'] ?? false;
    if (addFriends) {
      onInviteFriend();
    }
  }

  // 获取成员列表
  Future<void> onGetMembers() async {
    await _chatGroupMemberApi.list(chatGroupId).then((res) {
      if (res['code'] == 0) {
        members = res['data'];                           // 原始数据（Map）
        allMemberList = members.values.toList();         // 备份所有成员
        memberList = members.values.toList();            // 当前显示列表
        update([const Key('chat_group_member')]);
      }
    });
  }

  //踢出成员
  void onKickMember(context, String userId) {
    CustomDialog.showTipDialog(context, text: "确定要将此用户踢出群组?",
    onOk: () {
      _chatGroupApi.kickChatGroup(chatGroupId, userId).then((res) {
        if (res['code'] == 0) {
          CustomFlutterToast.showSuccessToast("用户已被踢出群组~");
          onGetMembers();
        }
      });
    },
    onCancel: () {});
  }

  //搜索成员
  void handlerSearchUser(String keyword) {
    if (keyword.isEmpty || keyword == '') {
      memberList = allMemberList; // 清空搜索，显示全部
    } else {
      memberList = allMemberList
          .where((user) =>
              (user['name']?.contains(keyword) ?? false) ||      // 昵称匹配
              (user['remark']?.contains(keyword) ?? false) ||    // 备注匹配
              (user['groupName']?.contains(keyword) ?? false))   // 群昵称匹配
          .toList();
    }
    update([const Key('chat_group_member')]);
  }

  //邀请好友
  void onInviteFriend() async {
    var result = await Get.toNamed('/user_select',
        arguments: {'onlyUsers': members.keys.toList()}); // 已在群内的成员不可选

    if (result != null && result.length > 0) {
      List<dynamic> ids = result.map((item) => item['friendId']).toList();

      _chatGroupApi.inviteMember(chatGroupId, ids).then((res) {
        if (res['code'] == 0) {
          CustomFlutterToast.showSuccessToast("邀请成功~");
          onGetMembers();
        }
      });
    }
  }

  //添加好友
  void onAddFriend(context, String userId) {
    CustomDialog.showTipDialog(context, text: "确定添加该用户为好友?",
      onOk: () {
      _notifyApi
          .friendApply(userId, '我是 [ ${chatGroupDetails['name']} ] 群成员')
          .then((res) {
        if (res['code'] == 0) {
          CustomFlutterToast.showSuccessToast("好友申请已发送~");
          onGetMembers();
        }
      });
    },
      onCancel: () {});
  }

  // 转让群组
  void onTransferGroup(context, String userId) {
    CustomDialog.showTipDialog(context, text: "确定将此群组转让给该用户?",
      onOk: () {
      _chatGroupApi.transferChatGroup(chatGroupId, userId).then((res) {
        if (res['code'] == 0) {
          CustomFlutterToast.showSuccessToast("转让成功~");
          Get.back();
        }
      });
    },
     onCancel: () {});
  }

  //打开好友详情
  void handlerFriendTapped(dynamic friendId) {
    final currentUserId = Get.find<GlobalData>().currentUserId;
    if(friendId != currentUserId){
      Get.toNamed('/friend_info', arguments: {'friendId': friendId});
    }
  }
}
