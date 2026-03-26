import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../api/friend_api.dart';
import '../../../../api/group_api.dart';
import '../../../../components/custom_flutter_toast/index.dart';
import '../../../../utils/getx_config/config.dart';
import '../logic.dart';
import 'index.dart';

class SetGroupLogic extends Logic<SetGroupPage> {
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
    //如果group['name'] == selectedGroup则是没有选择新的分组
    //group['value'] == '0' friendId == '0' 代表不是好友详情页进入，不设置好友分组
    if (group['name'] == selectedGroup ||
        group['value'] == '0' ||
        friendId == '0') {
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

  //创建或更新分组名字
  void onADDorUpdateGroup(context, dynamic group) {
    if (groupController.text.isEmpty) {
      return;
    }
    //有group，代表创建更新
    if (group != null) {
      _groupApi.update(group['value'], groupController.text).then((res){
        if (res['code'] == 0) {
          onGetGroupList();
          groupController.text = '';
          CustomFlutterToast.showSuccessToast('修改成功~');
          Navigator.of(context).pop();
          update([const Key('set_group')]);
        } else {
          CustomFlutterToast.showErrorToast(res['msg']);
        }
      });
    } else {
      //没有group，代表创建分组
      _groupApi.create(groupController.text).then((res) {
        if (res['code'] == 0) {
          onGetGroupList();
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

  //用来打开更新分组弹窗
  void onUpdateGroupPress(BuildContext context,dynamic group){
    //默认分组，直接返回
    if (group['value'] == '0') {
      Get.back();
      return;
    }
    Get.back();
    widget?.showAddAndUpdateGroupDialog(
      context,
      group: group,
      title: '修改分组',
      hintText: group['label'],
    );
  }

  //删除分组
  void onDeleteGroup(dynamic group) async {
    //不允许删默认分组
    if (group['value'] == '0') {
      CustomFlutterToast.showErrorToast("操作有误");
      Get.back();
      return;
    }
    var res = await _groupApi.delete(group['value']);
    if (res['code'] == 0) {
      Get.back();
      CustomFlutterToast.showSuccessToast("删除成功~");
      onGetGroupList();
    } else {
      Get.back();
      CustomFlutterToast.showErrorToast("网络错误");
    }
  }
}
