import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../api/friend_api.dart';

class UserSelectLogic extends GetxController {
  final _friendApi = FriendApi();
  late List<dynamic> userList = [];      // 当前显示的用户列表
  late List<dynamic> allUserList = [];   // 所有用户列表（备份）
  late List<dynamic> selectedUsers = []; // 已选中的用户列表
  late List<dynamic> onlyUsers = []; //用来标识禁止操作的用户

  @override
  void onInit() {
    super.onInit();
    // 从路由参数获取已选中的用户列表
    selectedUsers = Get.arguments['selectedUsers'] ?? [];
    onlyUsers = Get.arguments['onlyUsers'] ?? [];
    update([const Key('user_select')]);
    loadUsers();
  }

  //加载用户列表
  void loadUsers() async {
    _friendApi.listFlat().then((res) {
      if (res['code'] == 0) {
        userList = res['data'];           // 设置当前列表
        allUserList = res['data'];        // 备份全部列表
        update([const Key('user_select')]);
      }
    });
  }

  //处理用户选择 (handlerSelectUser)
  void handlerSelectUser(user) {
    // 检查用户是否已被选中
    if (selectedUsers
        .any((selected) => selected['friendId'] == user['friendId'])) {
      // 已选中 → 移除
      selectedUsers
          .removeWhere((selected) => selected['friendId'] == user['friendId']);
    } else {
      // 未选中 → 添加
      selectedUsers.add(user);
    }
    update([const Key('user_select')]);
  }

  //处理搜索 (handlerSearchUser)
  void handlerSearchUser(String keyword) {
    if (keyword.isEmpty || keyword == '') {
      // 搜索关键词为空 → 显示全部
      userList = allUserList;
    } else {
      userList = allUserList
          .where((user) =>
            (user['name']?.contains(keyword) ?? false) ||      // 昵称匹配
            (user['remark']?.contains(keyword) ?? false))      // 备注名匹配
          .toList();
    }
    update([const Key('user_select')]);
  }

  //确认选择 (handlerConfirmSelection)
  void handlerConfirmSelection() {
    Get.back(result: selectedUsers);  // 关闭页面，返回选中的用户列表
  }
}
