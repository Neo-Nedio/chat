// lib/services/user_service.dart
import 'package:dio/dio.dart';

import 'Http.dart';

class FriendApi {
  final Dio _dio = Http().dio;

  static final FriendApi _instance = FriendApi._internal();

  FriendApi._internal();

  factory FriendApi() {
    return _instance;
  }

  //好友列表（按分组等）
  Future<Map<String, dynamic>> list() async {
    final response = await _dio.get('/v1/api/friend/list');
    return response.data;
  }

  //获取扁平好友列表(不分组)
  Future<Map<String, dynamic>> listFlat() async {
    final response = await _dio.get('/v1/api/friend/list/flat');
    return response.data;
  }

  //搜索好友
  Future<Map<String, dynamic>> search(String friendInfo) async {
    final response = await _dio.post(
      '/v1/api/friend/search',
      data: {'searchInfo': friendInfo},
    );
    return response.data;
  }

  //扫码添加好友(废弃)
  Future<Map<String, dynamic>> addFriendByQr(String qrCode) async {
    final response = await _dio.post(
      '/v1/api/friend/add/qr',
      data: {'qrCode': qrCode},
    );
    return response.data;
  }

  //获取好友详情
  Future<Map<String, dynamic>> details(String friendId) async {
    final response = await _dio.get(
      '/v1/api/friend/details/$friendId',
    );
    return response.data;
  }

  //设置好友备注
  Future<Map<String, dynamic>> setRemark(String friendId, String remark) async {
    final response = await _dio.post(
      '/v1/api/friend/set/remark',
      data: {
        'friendId': friendId,
        'remark': remark,
      },
    );
    return response.data;
  }

  //设置好友分组
  Future<Map<String, dynamic>> setGroup(String friendId, String groupId) async {
    final response = await _dio.post(
      '/v1/api/friend/set/group',
      data: {
        'friendId': friendId,
        'groupId': groupId,
      },
    );
    return response.data;
  }

  //特别关心
  Future<Map<String, dynamic>> careFor(String friendId) async {
    final response = await _dio.post(
      '/v1/api/friend/carefor',
      data: {
        'friendId': friendId,
      },
    );
    return response.data;
  }

  //取消特别关心
  Future<Map<String, dynamic>> unCareFor(String friendId) async {
    final response = await _dio.post(
      '/v1/api/friend/uncarefor',
      data: {
        'friendId': friendId,
      },
    );
    return response.data;
  }

  //删除好友
  Future<Map<String, dynamic>> delete(String friendId) async {
    final response = await _dio.post(
      '/v1/api/friend/delete',
      data: {
        'friendId': friendId,
      },
    );
    return response.data;
  }

  //同意好友申请（按通知 ID）
  Future<Map<String, dynamic>> agree(String notifyId, String fromId) async {
    final response = await _dio.post(
      '/v1/api/friend/agree/id',
      data: {
        'notifyId': notifyId,
        'fromId': fromId,
      },
    );
    return response.data;
  }

  //拒绝好友申请
  Future<Map<String, dynamic>> reject(String fromId) async {
    final response = await _dio.post(
      '/v1/api/friend/reject',
      data: {
        'fromId': fromId,
      },
    );
    return response.data;
  }

  //查看是否为好友
  Future<Map<String, dynamic>> isFriend(String friendId) async {
    final response = await _dio.get(
      '/v1/api/friend/is/friend',
      queryParameters: {'targetId': friendId},
    );
    return response.data;
  }
}
