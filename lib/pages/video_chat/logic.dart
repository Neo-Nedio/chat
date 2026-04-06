import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:get/get.dart';

import '../../api/chat_list_api.dart';
import '../../api/msg_api.dart';
import '../../api/video_api.dart';
import '../../components/CustomDialog/index.dart';
import '../../components/custom_flutter_toast/index.dart';
import '../../utils/web_socket.dart';

/*
呼叫方 (A)                   信令服务器                    接听方 (B)
        │                              │                              │
        │  1. InviteVo (邀请)           │                              │
        │ ─────────────────────────────→│  1. InviteVo (转发邀请)       │
        │                              │ ─────────────────────────────→│
        │                              │                              │
        │                              │  2. AcceptVo (接受)           │
        │ ←─────────────────────────────│ ←─────────────────────────────│
        │                              │                              │
        │  3. OfferVo (SDP提议)         │                              │
        │ ─────────────────────────────→│  3. OfferVo (转发SDP)         │
        │                              │ ─────────────────────────────→│
        │                              │                              │
        │                              │  4. AnswerVo (SDP应答)        │
        │ ←─────────────────────────────│ ←─────────────────────────────│
        │                              │                              │
        │  5. CandidateVo (ICE候选)     │                              │
        │ ←─────────────────────────────│ ←─────────────────────────────│
        │                              │                              │
        │  6. 建立 P2P 连接              │                              │
        │ ←───────────────────────────→│                              │*/
class VideoChatLogic extends GetxController {
  final _chatListApi = ChatListApi();
  final _wsManager = WebSocketUtil();
  final _videoApi = VideoApi();
  final _msgApi = MsgApi();

  // 渲染器
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();   // 本地画面（自己）
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();  // 远程画面（对方）

  // WebRTC 核心
  late RTCPeerConnection peerConnection;   // 点对点连接
  late MediaStream webcamStream;           // 本地摄像头/麦克风流

  // 通话状态
  late String userId;          // 通话对象 ID
  late bool isOnlyAudio;       // 是否仅音频通话
  late bool isSender;          // 是否是发起方
  bool toUserIsReady = false;  // 被呼叫方是否已准备就绪

  // UI 状态
  late dynamic userInfo = {};  // 对方用户信息（头像、昵称等）
  Timer? timer;                // 计时器
  RxInt time = 0.obs;          // 通话时长

  RxBool isVideoEnabled = true.obs;   // 视频是否开启
  RxBool isAudioEnabled = true.obs;   // 音频是否开启
  late Rx<Offset> smallWindowOffset;       // 小窗口位置（用于拖拽）
  RxBool isRemoteFullScreen = false.obs;  // 是否远程画面全屏

  StreamSubscription? _subscription;




  @override
  void onInit() async {
    super.onInit();
    // 1. 获取路由参数
    userId = Get.arguments['userId'];
    isOnlyAudio = Get.arguments['isOnlyAudio'];
    isSender = Get.arguments['isSender'];
    smallWindowOffset = Offset(Get.size.width - 116, 16).obs;

    //获取对话详情
    await onGetChatDetail();

    //  初始化渲染器
    await initializeRenderers();

    //  创建 WebRTC 连接
    await initRTCPeerConnection();

    //  获取本地摄像头/麦克风流
    await videoCall();

    //  监听 WebSocket 视频事件
    videoEvent();
  }

  //获取对话详情
  Future<void> onGetChatDetail() async {
    try {
      final res = await _chatListApi.detail(userId, 'user');
      if (res['code'] == 0) {
        userInfo = res['data'];
        update([const Key('video_chat')]);
      }
    } catch (_) {}
  }

  //初始化渲染器(画面)
  Future<void> initializeRenderers() async {
    await localRenderer.initialize();   // 创建本地渲染纹理
    await remoteRenderer.initialize();  // 创建远程渲染纹理
  }

  //初始化 PeerConnection
  Future<void> initRTCPeerConnection() async {
    // ICE服务器配置（用于NAT穿透）
    //用于在复杂的网络环境中（NAT、防火墙）找到两个端点的最佳通信路径
    final Map<String, dynamic> iceServer = {
      'iceServers': [
        //内网测试不填写
        /*{'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:numb.viagenie.ca',
          'username': 'webrtc@live.com',
          'credential': 'muazkh',
        },*/
      ],
    };

    // 创建连接
    peerConnection = await createPeerConnection(iceServer);
    // 设置 ICE 候选者事件处理
    //当发现ICE候选时触发（例如发现本地IP、公网IP、中继地址等）
    peerConnection.onIceCandidate = handleICECandidateEvent;
    // 设置 ICE 连接状态更改事件处理
    //ICE连接状态变化：new, checking, connected, completed, failed, disconnected, closed
    peerConnection.onIceConnectionState = handleICEConnectionStateChangeEvent;
    // 设置 Track 事件处理
    //当收到对方发送的媒体流时触发
    peerConnection.onTrack = handleTrackEvent;
  }

  //ICE Candidate 回调处理
  Future<void> handleICECandidateEvent(RTCIceCandidate candidate) async {
    // 当本地发现新的ICE候选时，通过信令服务器发送给对方
    // 注意：candidate 可能为 null，表示收集完成
    if (candidate != null) {
      await _videoApi.candidate(userId, {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    }
  }

  //ICE 连接状态变化
  void handleICEConnectionStateChangeEvent(RTCIceConnectionState? state) {
    // state 可能的值：
    // RTCIceConnectionState.RTCIceConnectionStateNew - 新建
    // RTCIceConnectionState.RTCIceConnectionStateChecking - 正在检查候选
    // RTCIceConnectionState.RTCIceConnectionStateConnected - 已连接
    // RTCIceConnectionState.RTCIceConnectionStateCompleted - 完成
    // RTCIceConnectionState.RTCIceConnectionStateFailed - 失败
    // RTCIceConnectionState.RTCIceConnectionStateDisconnected - 断开
    // RTCIceConnectionState.RTCIceConnectionStateClosed - 已关闭

    toUserIsReady = true;  // 标记连接成功，对方已准备就绪

    // 停止之前的计时器（防止重复）
    handlerDestroyTime();

    // 启动通话计时器，每秒增加1秒
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      time.value = time.value + 1;
    });
  }

  //收到远程媒体流
  void handleTrackEvent(RTCTrackEvent event) {
    // event.streams[0] 是对方发送的MediaStream
    // 包含对方的音视频轨道
    remoteRenderer.srcObject = event.streams[0];

    // 刷新UI，显示对方画面
    update([const Key('video_chat')]);
  }

  Future<void> videoCall() async {
    try {
      // getUserMedia: 请求用户授权访问摄像头和麦克风
      webcamStream = await webrtc.navigator.mediaDevices.getUserMedia({
        'audio': true,           // 请求麦克风权限
        'video': !isOnlyAudio,  // 视频通话时请求摄像头，音频通话时不请求
      });

      // 将本地流设置到渲染器，显示本地预览画面
      localRenderer.srcObject = webcamStream;

      // 如果是音频通话，禁用视频轨道
      if (isOnlyAudio) {
        webcamStream.getVideoTracks().forEach((track) {
          track.enabled = false; // 禁用视频轨道，摄像头不会亮
        });
      }

      // 将本地流的所有轨道（音频轨和视频轨）添加到PeerConnection
      // 这样WebRTC就会开始将这些媒体数据编码并发送给对方
      webcamStream.getTracks().forEach((track) {
        peerConnection.addTrack(track, webcamStream);
      });
    } catch (e) {
      print('Error in videoCall: $e');
    }
  }

  //WebSocket 事件处理
  void videoEvent() {
    _subscription = _wsManager.eventStream.listen((event) {
      if (event['type'] == 'on-receive-video') {
        var data = event['content'];
        // 根据消息类型分发处理
        switch (data['type']) {
          case 'accept':    // 对方接受了通话请求（仅发起方收到）
            onOffer();                // 发起方开始创建Offer
            break;
          case 'offer':     // 收到SDP Offer（对方发起通话）
            handleVideoOfferMsg(data);
            break;

          case 'answer':    // 收到SDP Answer（对方应答）
            handleVideoAnswerMsg(data);
            break;

          case 'candidate': // 收到ICE Candidate（网络候选地址）
            handleNewICECandidateMsg(data);
            break;

          case 'hangup':    // 对方挂断
            handlerDestroyTime();      // 停止计时器
            CustomFlutterToast.showErrorToast('对方已挂断~');
            Get.back();               // 关闭当前页面
            break;

        }
      }
    });
  }

  //处理offer（接收方收到通话请求）
  Future<void> handleVideoOfferMsg(data) async {
    // ========== 第一步：解析远程描述 ==========
    // SDP (Session Description Protocol): 会话描述协议
    // 包含媒体能力信息：编解码器、IP地址、端口、媒体格式等
    final RTCSessionDescription desc = RTCSessionDescription(
      data['desc']['sdp'],    // SDP文本内容
      data['desc']['type'],   // 类型: 'offer' 或 'answer'
    );

    // ========== 第二步：设置远程描述 ==========
    // 告诉WebRTC引擎对方的能力
    await peerConnection.setRemoteDescription(desc);

    // ========== 第三步：创建本地Answer ==========
    // 根据对方的能力，生成匹配的应答
    RTCSessionDescription localDesc = await peerConnection.createAnswer();

    // ========== 第四步：设置本地描述 ==========
    // 告诉WebRTC引擎我方的应答内容
    await peerConnection.setLocalDescription(localDesc);

    // ========== 第五步：通过信令服务器发送Answer ==========
    // 将Answer发送给对方，完成SDP交换
    _videoApi.answer(userId, {
      'sdp': localDesc.sdp,
      'type': localDesc.type
    });
  }

  //处理 Answer（发起方收到应答）
  Future<void> handleVideoAnswerMsg(data) async {
    try {
      // 解析对方返回的Answer
      final RTCSessionDescription remoteDesc = RTCSessionDescription(
        data['desc']['sdp'],
        data['desc']['type'],
      );
      // 设置远程描述
      // 至此，双方完成了SDP交换，知道了彼此的媒体能力
      await peerConnection.setRemoteDescription(remoteDesc);
    } catch (e) {
      print('Error in handleVideoAnswerMsg: $e');
    }
  }

  //处理 ICE Candidate
  Future<void> handleNewICECandidateMsg(data) async {
    try {
      // ICE Candidate 包含：IP地址、端口、协议类型、优先级等
      final RTCIceCandidate candidate = RTCIceCandidate(
        data['candidate']['candidate'],    // ICE候选字符串
        data['candidate']['sdpMid'],       // 媒体标识（如 "video" 或 "audio"）
        data['candidate']['sdpMLineIndex'], // 媒体行索引
      );

      // 将候选地址添加到PeerConnection
      // WebRTC会尝试所有候选，找到可以建立连接的最佳路径
      await peerConnection.addCandidate(candidate);
    } catch (e) {
      print('Error in handleNewICECandidateMsg: $e');
    }
  }


  //创建 Offer（发起方）
  Future<void> onOffer() async {
    try {
      // 创建SDP Offer
      // 包含本地所有媒体能力（支持的编解码器、分辨率、码率等）
      RTCSessionDescription offer = await peerConnection.createOffer();

      // 设置本地描述
      // WebRTC引擎开始收集ICE Candidate
      await peerConnection.setLocalDescription(offer);

      // 通过信令服务器发送Offer给对方
      await _videoApi.offer(userId, {
        'sdp': offer.sdp,
        'type': offer.type
      });
    } catch (e) {
      print('Error in onOffer: $e');
    }
  }

  void onAccept() async {
    _videoApi.accept(userId).then((res) {
      if (res['code'] == 0) {
        toUserIsReady = true;
      }
    });
  }

  //挂断通话
  void onHangup() async {
    // ========== 第一步：构建通话记录消息 ==========
    Map<String, dynamic> msg = {
      'toUserId': userId,
      'msgContent': {
        'type': 'call',                    // 消息类型：通话记录
        'content': jsonEncode({
          'type': isOnlyAudio ? "audio" : "video",  // 通话类型
          'time': time.value                         // 通话时长（秒）
        }),
      }
    };
    // ========== 第二步：发送通话记录到聊天列表 ==========
    // 这样聊天界面会显示一条"视频通话 02:30"的记录
    _msgApi.send(msg).then((res) {
      if (res['code'] == 0) {
        // 将消息添加到本地消息流，实时更新聊天界面
        WebSocketUtil.eventController
            .add({'type': 'on-receive-msg', 'content': res['data']});
      }
    }).whenComplete(() {
      // ========== 第三步：通知对方挂断 ==========
      _videoApi.hangup(userId).then((res) {
        Get.back();  // 关闭通话页面，返回上一页
      });
    });
  }

  // 开关视频
  void toggleVideo() {
    isVideoEnabled.value = !isVideoEnabled.value;

    // 遍历所有视频轨道，启用/禁用
    // 禁用时：对方看到黑屏
    // 启用时：对方恢复正常画面
    webcamStream.getVideoTracks().forEach((track) {
      track.enabled = isVideoEnabled.value;
    });
  }

// 开关麦克风
  void toggleAudio() {
    isAudioEnabled.value = !isAudioEnabled.value;

    // 遍历所有音频轨道，启用/禁用
    // 禁用时：对方听不到声音
    webcamStream.getAudioTracks().forEach((track) {
      track.enabled = isAudioEnabled.value;
    });
  }

  //挂断确认对话框
  void showExitConfirmDialog(context) {
    CustomDialog.showTipDialog(context, text: "确定将结束本次通话，是否继续?", onOk: () {
      onHangup();
      Get.back(); //关闭对话框（因为对话框也是一个页面）
    }, onCancel: () {});
  }

  //小窗口拖拽边界限制
  void updateSmallWindowPosition(Offset delta) {
    final screenSize = Get.size; // 获取屏幕尺寸

    // 计算新的位置 （当前坐标 + 拖拽偏移量）
    double newX = smallWindowOffset.value.dx + delta.dx;
    double newY = smallWindowOffset.value.dy + delta.dy;

    // 确保小窗口不会超出屏幕边界
    newX = newX.clamp(0, screenSize.width - 100); // 100是小窗口的宽度
    newY = newY.clamp(0, screenSize.height - 150); // 150是小窗口的高度

    // 更新位置
    smallWindowOffset.value = Offset(newX, newY);
  }

  //停止之前的计时器
  void handlerDestroyTime() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
      timer = null;
    }
  }

  @override
  void onClose() {
    super.onClose();
    _subscription?.cancel();
    localRenderer.dispose();
    remoteRenderer.dispose();
    webcamStream.dispose();
    peerConnection.close();
  }
}
