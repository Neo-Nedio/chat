import 'package:dio/dio.dart';

import 'Http.dart';

class TalkCommentApi {
  final Dio _dio = Http().dio;

  static final TalkCommentApi _instance = TalkCommentApi._internal();

  TalkCommentApi._internal();

  factory TalkCommentApi() {
    return _instance;
  }

  //创建说说
  Future<Map<String, dynamic>> create(String talkId, String comment) async {
    final response = await _dio.post('/v1/api/talk-comment/create',
        data: {'talkId': talkId, 'comment': comment});
    return response.data;
  }

  //评论列表
  Future<Map<String, dynamic>> list(String talkId) async {
    final response =
    await _dio.post('/v1/api/talk-comment/list', data: {'talkId': talkId});
    return response.data;
  }

  //删除评论
  Future<Map<String, dynamic>> delete(
      String talkId, String talkCommentId) async {
    final response = await _dio.post('/v1/api/talk-comment/delete',
        data: {'talkId': talkId, 'talkCommentId': talkCommentId});
    return response.data;
  }
}
