import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/talk_api.dart';
import '../../api/user_api.dart';

class TalkLogic extends GetxController {
  final _talkApi = TalkApi();
  final _userApi = UserApi();
  String currentUserId = '';

  final List<dynamic> talkList = [];  // 说说列表数据
  int index = 0;                       // 分页索引
  bool hasMore = true;                  // 是否还有更多数据
  bool isLoading = false;               // 是否正在加载
  final ScrollController scrollController = ScrollController(); // 滚动控制器

  void init() async {
    onTalkList();           // 首次加载数据
    scrollController.addListener(scrollListener); // 添加滚动监听
    //获取当前用户id
    SharedPreferences.getInstance().then((prefs) {
      currentUserId = prefs.getString('userId') ?? '';
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  //监听器
  void scrollListener() {
    // 当滚动到底部时
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      onTalkList();  // 加载更多数据
    }
  }

  void onTalkList() {
    if (!hasMore || isLoading) return;  // 没有更多或正在加载时返回

    isLoading = true;  // 显示加载状态
    update([const Key("talk")]);

    _talkApi.list(index, 10).then((res) { // 每页10条
      if (res['code'] == 0) {
        final List<dynamic> newTalks = res['data'];

        if (newTalks.isEmpty) {
          hasMore = false; // 没有更多数据
        } else {
          talkList.addAll(newTalks); // 追加新数据
          index += newTalks.length; // 更新索引
        }
        isLoading = false;
        update([const Key("talk")]);
      } else {
        isLoading = false;
        update([const Key("talk")]);
      }
    }).catchError((_) {
      isLoading = false; // 错误处理
      update([const Key("talk")]);
    });
  }

  //下拉刷新
  Future<void> refreshData() async {
    talkList.clear();  // 清空列表
    index = 0;         // 重置索引
    hasMore = true;    // 重置更多标志
    update([const Key("talk")]);
    onTalkList(); // 重新加载
  }

  //更新评论或点赞数量
  void updateTalkLikeOrCommentCount(String key, int num, String talkId) {
    for (var talk in talkList) {
      if (talk['talkId'] == talkId) {
        talk[key] = num;
        update([const Key("talk")]);
        return;
      }
    }
  }

  // 获取图片URL
  Future<String> onGetImg(String fileName, String userId) async {
    dynamic res = await _userApi.getImg(fileName, userId);
    if (res['code'] == 0) {
      return res['data'];  // 返回图片URL
    }
    return '';  // 失败返回空字符串
  }
}
