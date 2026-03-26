import 'package:chat_mobile/api/friend_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/user_api.dart';
import '../../components/custom_flutter_toast/index.dart';
import '../../utils/getx_config/config.dart';
import '../navigation/logic.dart';

class AddFriendLogic extends Logic {
  final _userApi = UserApi();
  final _friendApi = FriendApi();

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

  //判断是否为好友
  Future<bool> _isFriend(dynamic friend) async{
    final isFriend = await _friendApi.isFriend(friend['id']);
    if (isFriend['code'] == 0 && isFriend['data']) {
        return true;
    }else{
      return false;
    }
  }
  // 进入好友详情页
  Future<void> toFriendDetail(dynamic friend) async {
    //判断是否为好友
    bool isFriend = await _isFriend(friend);

    Get.toNamed("/search_info", arguments: {
      'friendInfo': friend,
      'isFriend' :  isFriend
    });
  }


  // 申请加好友
  Future<void> goApplyFriend(dynamic friend) async {
    //判断是否为好友
    bool isFriend = await _isFriend(friend);

    if(isFriend){
      CustomFlutterToast.showErrorToast("他已经是你的好友了");
    }else{
      Get.toNamed('/friend_request', arguments: {
        'friendInfo': friend,
      });
    }
  }


  @override
  void onClose() {
    super.onClose();
    _navigationLogic.initData();
  }
}
