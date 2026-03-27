import 'package:dio/dio.dart';

import 'Http.dart';

class VideoApi {
  final Dio _dio = Http().dio;

  static final VideoApi _instance = VideoApi._internal();

  VideoApi._internal();

  factory VideoApi() {
    return _instance;
  }

  ///todo WebRTC 视频通话的核心信令交换方法，用于建立 P2P 连接。
/* Offer	呼叫方发起连接请求	SDP 描述（媒体能力、网络信息）
   Answer	被叫方回应连接请求	SDP 描述（媒体能力、网络信息）
   Candidate	交换网络候选地址	IP 地址、端口、协议等*/
  //发送 offer
  Future<Map<String, dynamic>> offer(String userId, dynamic desc) async {
    final response = await _dio.post('/v1/api/video/offer', data: {
      'userId': userId,
      'desc': desc, // SDP Offer 对象
    });
    return response.data;
  }

  //发送 answer
  Future<Map<String, dynamic>> answer(String userId, dynamic desc) async {
    final response = await _dio.post(
      '/v1/api/video/answer',
      data: {'userId': userId, 'desc': desc},  // SDP Answer 对象
    );
    return response.data;
  }

  //发送 candidate
  Future<Map<String, dynamic>> candidate(
      String userId, dynamic candidate) async {
    final response = await _dio.post(
      '/v1/api/video/candidate',
      data: {'userId': userId, 'candidate': candidate}, // ICE Candidate
    );
    return response.data;
  }

  ///电话
  //挂断
  Future<Map<String, dynamic>> hangup(String userId) async {
    final response = await _dio.post(
      '/v1/api/video/hangup',
      data: {'userId': userId},
    );
    return response.data;
  }

  //邀请
  Future<Map<String, dynamic>> invite(String userId, bool isOnlyAudio) async {
    final response = await _dio.post(
      '/v1/api/video/invite',
      data: {'userId': userId, 'isOnlyAudio': isOnlyAudio}, //true = 语音通话，false = 视频通话
    );
    return response.data;
  }

  //接受
  Future<Map<String, dynamic>> accept(String userId) async {
    final response = await _dio.post(
      '/v1/api/video/accept',
      data: {'userId': userId},
    );
    return response.data;
  }
}
