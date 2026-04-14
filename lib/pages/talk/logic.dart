import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/friend_api.dart';
import '../../api/talk_api.dart';
import '../../api/user_api.dart';
import '../../components/CustomDialog/index.dart';
import '../../components/custom_flutter_toast/index.dart';
import '../../utils/getx_config/GlobalData.dart';

class TalkLogic extends GetxController {
  final _talkApi = TalkApi();
  final _userApi = UserApi();
  String currentUserId = '';
  String targetUserId = '';
  String title = '说说';

  final List<dynamic> talkList = [];  // 说说列表数据
  int index = 0;                       // 分页索引
  bool hasMore = true;                  // 是否还有更多数据
  bool isLoading = false;               // 是否正在加载
  final ScrollController scrollController = ScrollController(); // 滚动控制器

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() async {
    if (Get.arguments != null) {
      targetUserId = Get.arguments['userId'] ?? '';
      title = Get.arguments['title'] ?? '说说';
    }
    refreshData(); //加载数据
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

    ////targetId为空时看自己和有权限的好友说说
    _talkApi.list(index, 10,targetUserId).then((res) { // 每页10条
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

  //删除说说
  void onDeleteTalk(talkId) {
    _talkApi.delete(talkId).then((res) {
      if (res['code'] == 0) {
        for (var talk in talkList) {
          if (talk['talkId'] == talkId) {
            talkList.remove(talk);
            update([const Key("talk")]);
            return;
          }
        }
      }
    });
  }

  //点击删除时的弹窗
  void handlerDeleteTalkTip(BuildContext context, String talkId) {
    CustomDialog.showTipDialog(
      context,
      text: '确认删除该条说说?',
      onOk: () => onDeleteTalk(talkId),
      onCancel: () {},
    );
  }

  // 获取图片URL
  Future<String> onGetImg(String fileName, String userId) async {
    dynamic res = await _userApi.getImg(fileName, userId);
    if (res['code'] == 0) {
      return res['data'];  // 返回图片URL
    }
    return '';  // 失败返回空字符串
  }

  //打开对方详情
  void handlerUserTapped(String toId) {
    final currentUserId = Get.find<GlobalData>().currentUserId;
    if (toId != currentUserId) {
      FriendApi().isFriend(toId).then((res) {
        if (res['code'] == 0) {
          if (res['data']) {
            //双方是好友
            Get.toNamed('/friend_info', arguments: {'friendId': toId});
          } else {
            //双方不是好友
            _userApi.getInfoById(toId).then((userRes) {
              if (userRes['code'] == 0) {
                Get.toNamed('/search_info', arguments: {
                  'friendInfo': userRes['data'],
                  'isFriend': false,
                });
              } else {
                CustomFlutterToast.showErrorToast(userRes['msg'] ?? "获取用户信息失败");
              }
            });
          }
        } else {
          CustomFlutterToast.showErrorToast(res['msg'] ?? "打开详情失败");
        }
      });
    }
  }
}
