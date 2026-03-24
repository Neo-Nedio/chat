import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'date.dart';
import 'notification.dart';

//todo WebSocket 是一种全双工通信协议，允许客户端和服务器之间建立持久连接，双方可以随时发送消息
/*
┌─────────────────────────────────────────────────────────────────────────┐
│                         WebSocketUtil (单例)                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      状态管理                                    │   │
│  │  _channel        : WebSocket通道                                │   │
│  │  _isConnected    : 是否已连接                                    │   │
│  │  _token          : 认证令牌                                      │   │
│  │  _reconnectCount : 重连次数                                      │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      定时器                                      │   │
│  │  _heartbeatTimer : 心跳定时器（每9.9秒发一次心跳）                │   │
│  │  _reconnectTimer : 重连定时器（断开后5秒重连）                    │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      事件总线                                    │   │
│  │  _eventController : 消息分发器                                   │   │
│  │  eventStream      : 外部监听入口                                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘*/
/*
┌─────────────────────────────────────────────────────────────────────────┐
│                      WebSocketChannel                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────────────────┐              ┌─────────────────────┐         │
│   │        sink         │              │       stream        │         │
│   │   (发送端/输入端)    │              │   (接收端/输出端)    │         │
│   ├─────────────────────┤              ├─────────────────────┤         │
│   │  用来向服务器发送    │              │  用来接收服务器消息   │         │
│   │  消息的入口         │              │  的出口              │         │
│   └─────────────────────┘              └─────────────────────┘         │
│            │                                    ▲                      │
│            │                                    │                      │
│            ▼                                    │                      │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                     WebSocket 连接                              │  │
│   │                                                                 │  │
│   │    send() ──────────────────────────────────────► 服务器        │  │
│   │    (通过 sink 发送)                              (接收)         │  │
│   │                                                                 │  │
│   │    receive() ◄────────────────────────────────── 服务器推送     │  │
│   │    (通过 stream 接收)                            (发送)         │  │
│   │                                                                 │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘*/
class WebSocketUtil {
  //单例模式
  static WebSocketUtil? _instance;
  factory WebSocketUtil() {
    _instance ??= WebSocketUtil._internal();
    return _instance!;
  }
  WebSocketUtil._internal();

  // 事件总线，用于消息分发
  static final _eventController =
  StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _lockReconnect = false;
  bool _isConnected = false;
  String? _token;
  final int _reconnectCountMax = 200;
  int _reconnectCount = 0;


  //连接建立
  Future<void> connect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-token');
    if (token == null) return;
    if (_isConnected || _channel != null) return; // 已连接则跳过
    _isConnected = true;

    try {
      print('WebSocket connecting...');
      //// WebSocket 服务器地址
      String wsIp = 'ws://127.0.0.1:9100';

      //// 创建 WebSocket 连接，URL 中带上 token 用于认证
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsIp/ws?x-token=$token'),
      );

      // 监听 WebSocket 事件
      _channel!.stream.listen(
        _handleMessage,  // 收到消息时调用
        onDone: _handleClose,   // 连接关闭时调用
        onError: _handleError,  // 出错时调用
        cancelOnError: true,
      );

      _clearTimer();        // 清理之前的定时器
      _startHeartbeat();    // 启动心跳
    } catch (e) {
      // 连接失败，触发关闭处理
    }
  }

  //消息处理
  void _handleMessage(dynamic message) {
    // 空消息检查
    if (message == null) {
      _handleClose();
      return;
    }

    //// 解析 JSON
    Map<String, dynamic> wsContent;
    try {
      wsContent = jsonDecode(message);
    } catch (e) {
      _handleClose();
      return;
    }

    // 验证消息格式
    if (wsContent.containsKey('type')) {
      // 检查认证失败情况
      if (wsContent['data'] != null && wsContent['data']['code'] == -1) {
        _handleClose();  // token 无效，断开连接
      } else {
        // 根据消息类型分发
        switch (wsContent['type']) {
          case 'msg':     // 聊天消息
            sendNotification(wsContent['content']);
            _eventController.add({
              'type': 'on-receive-msg',
              'content': wsContent['content']
            });
            break;
          case 'notify':  // 系统通知
            _eventController.add(
                {'type': 'on-receive-notify',
                 'content': wsContent['content']});
            break;
          case 'video':   // 视频通话
          // 处理视频消息
            break;
        }
      }
    } else {
      _handleClose();  // 格式错误，断开连接
    }
  }

  //消息发送 (send),是给服务器发信息
  void send(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);// 通过 WebSocket 发送给服务器
    }
  }

  //心跳机制 (startHeartbeat)
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();  // 取消旧定时器
    _heartbeatTimer = Timer.periodic(
      const Duration(milliseconds: 9900),  // 每 9.9 秒执行一次
          (_) => send('heart'),                // 发送心跳消息
    );
  }

  //断线重连 (handleClose + reconnect)
  void _handleClose() {
    _clearHeartbeat();      // 停止心跳
    if (_channel != null) {
      _channel!.sink.close();  // 关闭通道
      _channel = null;
    }
    _isConnected = false;   // 标记为未连接
    _reconnect();           // 尝试重连
  }

  void _reconnect() {
    if (_lockReconnect) return;  // 防止重复重连
    _lockReconnect = true;

    _reconnectTimer?.cancel();

    // 检查重连次数
    if (_reconnectCount >= _reconnectCountMax) {
      _reconnectCount = 0;
      return;  // 超过最大次数，停止重连
    }

    // 5秒后尝试重连
    _reconnectTimer = Timer(
      const Duration(seconds: 5),
          () {
        connect();      // 重新连接
        _reconnectCount++;     // 重连次数+1
        _lockReconnect = false;
      },
    );
  }

  void _handleError(dynamic error) {
    _handleClose();
  }

  ///关闭处理
  void _clearHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _clearTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void dispose() {
    _clearHeartbeat();
    _clearTimer();
    _channel?.sink.close();
    _eventController.close();
    _instance = null;
  }

  void sendNotification(dynamic msg) {
    // 获取消息内容
    dynamic msgContent = msg['msgContent'];
    try {
      //根据消息类型生成通知文本
      String contentStr = '';
      switch (msgContent['type']) {
        case "text":
          contentStr = msgContent['content'];
          break;
        case "file":
          var content = jsonDecode(msgContent['content']);
          contentStr = '[文件] ${content['name']}';
          break;
        case "img":
          contentStr = '[图片]';
          break;
        case "retraction":
          contentStr = '[消息被撤回]';
          break;
        case "voice":
          var content = jsonDecode(msgContent['content']);
          contentStr = '[语音] ${content['time']}';
          break;
        case "call":
          var content = jsonDecode(msgContent['content']);
          contentStr =
          '[通话] ${content['time'] > 0 ? DateUtil.formatTimingTime(content['time']) : "未接通"}';
          break;
        case "system":
          contentStr = '[系统消息]';
          break;
        case "quit":
          contentStr = '[系统消息]';
          break;
      }
      //显示通知
      NotificationUtil.showNotification(
        id: 0,
        title: msgContent['formUserName'],  // 发送者昵称
        body: '${msgContent['formUserName']}: $contentStr',  // 通知内容
      );
    } catch (e) {}
  }
}
