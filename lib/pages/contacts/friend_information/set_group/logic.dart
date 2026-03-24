import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../api/friend_api.dart';
import '../../../../api/group_api.dart';
import '../../../../components/custom_flutter_toast/index.dart';
import '../logic.dart';

class SetGroupLogic extends GetxController {
  final _groupApi = GroupApi();
  final _friendApi = FriendApi();

  late List<dynamic> groupList = [];
  late String selectedGroup; //所选分组名字
  late String friendId;

  //好友信息页
  final FriendInformationLogic _friendInformationLogic =
      GetInstance().find<FriendInformationLogic>();
  //文本控制器
  final TextEditingController groupController = TextEditingController();

  @override
  void onInit() {
    selectedGroup = Get.arguments['groupName'];
    friendId = Get.arguments['friendId'];
    super.onInit();
    onGetGroupList();
  }

  //获取分组列表
  void onGetGroupList() {
    _groupApi.list().then((res) {
      if (res['code'] == 0) {
        groupList = res['data'];
        update([const Key('set_group')]);
      }
    });
  }

  //设置好友分组
  void onSetGroup(group) {
    if (group['name'] == selectedGroup) {
      return;
    }

    _friendApi.setGroup(friendId, group['value']).then((res) {
      if (res['code'] == 0) {
        selectedGroup = group['label']; //更新所选分组名字
        update([const Key('set_group')]);
        _friendInformationLogic.getFriendInfo(); //更新好友信息
      }
    });
  }

  //创建分组
  void onAddGroup(context) {
    if (groupController.text.isEmpty) {
      return;
    }
    _groupApi.create(groupController.text).then((res) {
      if (res['code'] == 0) {
        onGetGroupList(); //更新分组列表
        groupController.text = '';
        CustomFlutterToast.showSuccessToast('添加成功~');
        Navigator.of(context).pop();
        update([const Key('set_group')]);
      } else {
        CustomFlutterToast.showErrorToast(res['msg']);
      }
    });
  }
}
