import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/talk_api.dart';
import '../../../api/talk_comment_api.dart';
import '../../../api/talk_like_api.dart';
import '../../../components/custom_flutter_toast/index.dart';
import '../logic.dart';

class TalkDetailsLogic extends GetxController {
  final _talkApi = TalkApi();
  final _talkLikeApi = TalkLikeApi();
  final _talkCommentApi = TalkCommentApi();

  late String talkId = '';

  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();

  late dynamic talkDetails = {
    'userId': '',
    'name': '',
    'portrait': '',
    'remark': '',
    'talkId': '',
    'content': {},
    'latestComment': [],
    'time': '',
    'likeNum': 0,
    'commentNum': 0,
  };

  String currentUserId = '';
  List<dynamic> talkLikeList = [];
  List<dynamic> talkCommentList = [];
  late bool isLiked = false;

  //说说页逻辑
  final TalkLogic _talkLogic = Get.find<TalkLogic>();

  @override
  void onInit() {
    super.onInit();
    //用户id
    SharedPreferences.getInstance().then((prefs) {
      currentUserId = prefs.getString('userId') ?? '';
    });
    //说说id
    talkId = Get.arguments['talkId'];
    _onGetTalkDetails();
    _onGetTalkLikeList();
    _onGetTalkCommentList();
  }

  //获取说说详情
  void _onGetTalkDetails() {
    _talkApi.details(talkId).then((res) {
      if (res['code'] == 0) {
        talkDetails = res['data'];
        update([const Key('talk_details')]);
      }
    });
  }

  //获取说说点赞数，并判断用户是否点赞
  void _onGetTalkLikeList() {
    _talkLikeApi.list(talkId).then((res) {
      if (res['code'] == 0) {
        talkLikeList = res['data'];
        for (var item in talkLikeList) {
          if (item['userId'] == currentUserId) {
            isLiked = true;
            break;
          }
        }
        //检查点赞是否一致，不一致则更新
        if (talkLikeList.length != talkDetails['likeNum']) {
          _talkLogic.updateTalkLikeOrCommentCount(
              'likeNum', talkLikeList.length, talkId);
        }
        update([const Key('talk_details')]);
      }
    });
  }

  //获取说说评论数量
  void _onGetTalkCommentList() {
    _talkCommentApi.list(talkId).then((res) {
      if (res['code'] == 0) {
        talkCommentList = res['data'];
        //检查评论数是否一致，不一致则更新
        if (talkCommentList.length != talkDetails['commentNum']) {
          _talkLogic.updateTalkLikeOrCommentCount(
              'commentNum', talkCommentList.length, talkId);
        }
        update([const Key('talk_details')]);
      }
    });
  }

  //给说说点赞或取消
  void onCreateOrDeleteTalkLike() async {
    if (isLiked) {
      await _talkLikeApi.delete(talkId);
    } else {
      await _talkLikeApi.create(talkId);
    }
    isLiked = !isLiked;
    update([const Key('talk_details')]);
    _onGetTalkLikeList();
  }

  //删除说说评论
  void onDeleteTalkComment(talkCommentId) {
    _talkCommentApi.delete(talkId, talkCommentId).then((res) {
      if (res['code'] == 0) {
        CustomFlutterToast.showSuccessToast('评论删除成功~');
        _onGetTalkCommentList();
        update([const Key('talk_details')]);
      }
    });
  }

  //给说说评论
  void onCreateTalkComment() {
    if (commentController.text == '') {
      return;
    }
    _talkCommentApi.create(talkId, commentController.text).then((res) {
      if (res['code'] == 0) {
        commentController.text = '';
        CustomFlutterToast.showSuccessToast('评论成功~');
        _onGetTalkCommentList();
        update([const Key('talk_details')]);
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    commentController.dispose();
    commentFocusNode.dispose();
  }
}
