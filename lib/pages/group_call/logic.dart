import 'dart:async';

import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter/foundation.dart';

import '../../api/group_call_api.dart';
import '../../components/custom_flutter_toast/index.dart';
import '../../utils/getx_config/GlobalData.dart';
import '../../utils/web_socket.dart';

// 群通话页面逻辑：负责连 LiveKit、发布媒体、同步成员、处理挂断
class GroupCallLogic extends GetxController {
  final api = GroupCallApi();

  // 房间里的成员 ID（实际在线）
  final participants = <String>[].obs;

  // 从群聊页传入的完整群成员，用于通话页成员抽屉
  final members = <Map<String, dynamic>>[].obs;

  // 只展示当前实际参与群通话的成员
  List<Map<String, dynamic>> get activeMembers {
    final activeIds = participants.toSet();
    activeIds.add(Get.find<GlobalData>().currentUserId.toString());
    return members
        .where((member) => activeIds.contains(member['id']?.toString()))
        .toList();
  }

  // 页面加载中
  final loading = true.obs;

  // 是否已连上 LiveKit
  final connected = false.obs;

  // 麦克风 / 摄像头开关状态
  final microphoneEnabled = true.obs;
  final cameraEnabled = false.obs;

  // 是否正在重连
  final reconnecting = false.obs;

  // 从路由参数拿到的通话信息
  late String sessionId;
  late String groupId;
  late String callType;
  late String groupName;
  late bool isSender;

  Room? room; // LiveKit 房间实例
  CancelListenFunc? _roomSubscription; // 房间事件订阅
  StreamSubscription? _wsSubscription; // WebSocket 信令订阅

  bool get isVideo => callType == 'video';

  @override
  void onInit() {
    super.onInit();

    // 读取路由参数
    final args = Get.arguments as Map? ?? {};
    sessionId = args['sessionId'].toString();
    groupId = args['groupId'].toString();
    callType = args['callType'] == 'video' ? 'video' : 'audio';
    groupName = args['groupName']?.toString() ?? '群通话';
    isSender = args['isSender'] == true;
    _readMembers(args['members']);
    Get.find<GlobalData>().isInCall.value = true;

    // 订阅 WebSocket 信令
    _wsSubscription = WebSocketUtil().eventStream.listen(_onWsEvent);

    // 开始连接
    _connect();
  }

  void _readMembers(dynamic source) {
    if (source is! Map) return;
    final result = <Map<String, dynamic>>[];
    source.forEach((key, value) {
      if (value is! Map) return;
      final member = Map<String, dynamic>.from(value);
      final id = key.toString();
      final groupName = member['groupName']?.toString().trim() ?? '';
      final remark = member['remark']?.toString().trim() ?? '';
      final name = member['name']?.toString().trim() ??
          member['username']?.toString().trim() ?? id;
      result.add({
        'id': id,
        'name': groupName.isNotEmpty
            ? groupName
            : remark.isNotEmpty
                ? remark
                : name,
        'portrait': member['portrait'] ?? member['avatar'] ?? '',
      });
    });
    members.assignAll(result);
  }

  // 收到 WebSocket 信令
  void _onWsEvent(Map<String, dynamic> event) {
    if (event['type'] != 'on-receive-call') return;
    final data = event['content'];

    // 只要当前房间收到 hangup，就断开
    if (data?['sessionId']?.toString() == sessionId &&
        data?['action'] == 'hangup') {
      _disconnectFromRemote();
    }
  }

  // 被远端挂断：断开房间、清状态、关页面
  Future<void> _disconnectFromRemote() async {
    final currentRoom = room;
    room = null;
    _roomSubscription?.call();
    await currentRoom?.disconnect();
    Get.find<GlobalData>().isInCall.value = false;
    Get.back();
    CustomFlutterToast.showErrorToast('通话已结束');
  }

  // 连接 LiveKit 房间
  Future<void> _connect() async {
    try {
      // 拿 token 和 host
      final tokenResult = await api.token(sessionId);
      final hostResult = await api.host();
      if (tokenResult['code'] != 0 || hostResult['code'] != 0) {
        throw Exception('token');
      }

      final token = tokenResult['data']?.toString();
      final host = hostResult['data']?.toString();
      if (token == null || host == null || token.isEmpty || host.isEmpty) {
        throw Exception('connection data');
      }

      // 创建房间并连接
      room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
        /*   adaptiveStream: true	自适应流：根据观看方（你）的屏幕大小/网络，自动让发布方发合适清晰度的流。比如你把某人缩小成小窗，对方就不发高清，省带宽
            dynacast: true	动态推送：如果你没在看某人的视频（比如他摄像头关了、或你把他静音了），LiveKit 会让发布方停止推那路流，省带宽*/
      );
      _roomSubscription = room!.events.listen(_onRoomEvent); //订阅房间事件
      await room!.connect(host, token);

      // 发布本地媒体
      await room!.localParticipant!.setMicrophoneEnabled(true); //打开麦克风
      if (isVideo) {
        await room!.localParticipant!.setCameraEnabled(true); //视频时才打开摄像头
      }

      connected.value = true;
      loading.value = false;

      // LiveKit 连接成功后以 SDK 房间成员为准
      _syncParticipants();
    } catch (e, s) {
      debugPrint('[群通话] 连接异常: $e');
      debugPrint('[群通话] 连接堆栈: $s');
      // 连接失败：清状态、提示、关页面
      loading.value = false;
      Get.find<GlobalData>().isInCall.value = false;
      CustomFlutterToast.showErrorToast('加入群通话失败，请稍后重试');
      Get.back();
    }
  }

  // 处理 LiveKit 房间事件
  void _onRoomEvent(RoomEvent event) {
    // 成员进出 / 轨道变化 / 重连成功 → 重新同步成员
    if (event is ParticipantConnectedEvent ||
        event is ParticipantDisconnectedEvent ||
        event is TrackSubscribedEvent ||
        event is TrackUnsubscribedEvent ||
        event is RoomReconnectedEvent) {
      _syncParticipants();
    }

    // 重连状态
    if (event is RoomReconnectingEvent) reconnecting.value = true;
    if (event is RoomReconnectedEvent) reconnecting.value = false;

    // 房间断开
    if (event is RoomDisconnectedEvent) {
      connected.value = false;
      Get.back();
    }
  }

  // 从 LiveKit 同步在线成员
  void _syncParticipants() {
    final ids =
        room?.remoteParticipants.values
            .map((participant) => participant.identity)
            .toList() ??
        <String>[];
    _setParticipants(ids);
  }

  // 更新成员列表（去重）
  void _setParticipants(Iterable<String> ids) {
    //把传进来的成员 ID 去重后，整个替换掉当前的成员列表
    participants.assignAll(ids.toSet());
  }

  // 开关麦克风
  Future<void> toggleMicrophone() async {
    final value = !microphoneEnabled.value;
    await room?.localParticipant?.setMicrophoneEnabled(value);
    microphoneEnabled.value = value;
  }

  // 开关摄像头（仅视频通话）
  Future<void> toggleCamera() async {
    if (!isVideo) return;
    final value = !cameraEnabled.value;
    await room?.localParticipant?.setCameraEnabled(value);
    cameraEnabled.value = value;
  }

  // 主动离开
  Future<void> leave() async {
    final currentRoom = room;
    room = null;
    _roomSubscription?.call();
    await currentRoom?.disconnect();
    Get.find<GlobalData>().isInCall.value = false;
    Get.back();
  }

  @override
  void onClose() {
    _roomSubscription?.call();
    _wsSubscription?.cancel();
    room?.disconnect();
    Get.find<GlobalData>().isInCall.value = false;
    super.onClose();
  }
}
