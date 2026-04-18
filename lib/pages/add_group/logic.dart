import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/chat_group_api.dart';
import '../../utils/getx_config/config.dart';

class AddGroupLogic extends Logic {
  final _chatGroupApi = ChatGroupApi();

  //搜索结果
  late List<dynamic> searchList = [];

  //搜索
  void onSearchGroup(String search) {
    if (search.trim() == '') {
      searchList = [];
      update([const Key("add_group")]);
      return;
    }
    _chatGroupApi.searchGroup(search).then((res) {
      if (res['code'] == 0) {
        searchList = res['data'] ?? [];
        update([const Key("add_group")]);
      }
    });
  }

  //跳转到群详情页
  void toGroupDetail(dynamic group) {
    Get.toNamed('/chat_group_info', arguments: {
      'chatGroupId': group['id'].toString(),
    });
  }
}
