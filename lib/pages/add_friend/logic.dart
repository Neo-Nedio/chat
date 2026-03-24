import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/user_api.dart';
import '../../utils/getx_config/config.dart';
import '../navigation/logic.dart';

class AddFriendLogic extends Logic {
  final _userApi = UserApi();

  //导航栏逻辑
  final NavigationLogic _navigationLogic = Get.find<NavigationLogic>();

  //搜索结果
  late List<dynamic> searchList = [];

  //搜索
  void onSearchFriend(String friendInfo) {
    if (friendInfo.trim() == '') {
      searchList = [];
      update([const Key("add_friend")]);
      return;
    }
    _userApi.search(friendInfo).then((res) {
      if (res['code'] == 0) {
        searchList = res['data'];
        update([const Key("add_friend")]);
      }
    });
  }

  // 进入好友详情页
  void toFriendDetail(dynamic friend) =>
      Get.toNamed("/search_info", arguments: {"friend": friend});

  // 申请加好友
  void goApplyFriend(dynamic friend) =>
      Get.toNamed('/friend_request', arguments: {'friendInfo': friend});

  @override
  void onClose() {
    super.onClose();
    _navigationLogic.initData();
  }
}
