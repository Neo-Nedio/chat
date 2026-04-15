import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/custom_button/index.dart';
import '../../utils/getx_config/GlobalData.dart';
import '../../utils/getx_config/GlobalThemeConfig.dart';
import '../../utils/notification.dart';
import '../../utils/permission_handler.dart';
import '../../utils/web_socket.dart';

class NavigationLogic extends GetxController {
  late RxInt currentIndex = 0.obs;
  final _wsManager = WebSocketUtil();
  StreamSubscription? _subscription;

  GlobalData get globalData => GetInstance().find<GlobalData>();

  Future<void> initThemeData() async {
    //Get.parameters（URL 参数）
    String sex = Get.parameters['sex'] ?? "男"; // 获取路由参数
    final theme = Get.find<GlobalThemeConfig>(); // 获取主题配置实例
    theme.changeThemeMode(sex == "女" ? 'pink' : 'blue'); // 根据性别设置主题
  }

  @override
  void onInit() {
    super.onInit();

    //立即执行
    (() async {
      await globalData.init(); //  初始化全局数据
      await NotificationUtil.initialize();           // 1. 初始化通知服务
      await NotificationUtil.createNotificationChannel(); // 2. 创建通知渠道
      await PermissionHandler.permissionRequest();   // 3. 请求通知权限
      await connectWebSocket(); //建立 WebSocket 连接
      eventListen(); //进行监听
    })();

    //加载主题
    // Widget 树构建和渲染完成后的下一个微任务中执行代码
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initThemeData();
    });
  }

  // 监听消息(收到任何消息，立马刷新)
  void eventListen() {
    _subscription = _wsManager.eventStream.listen((event) {
      if (event['type'] == 'on-force-logout') { //强制下线
        _showDisableDialog();
        return;
      }
      globalData.onGetUserUnreadInfo();
      //如果是视频通话，立马移向通话界面
      if (event['type'] == 'on-receive-video') {
        var data = event['content'];
        if (data['type'] == "invite") {
          Get.toNamed('/video_chat', arguments: {
            'userId': data['fromId'],
            'isSender': false,
            'isOnlyAudio': data['isOnlyAudio'],
          });
        }
      }
    });
  }

  //强制下线对话框
  void _showDisableDialog() {
    final theme = Get.find<GlobalThemeConfig>();
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '提示',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '您的账号已被管理员禁用，请联系管理员处理',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: '确定',
                  onTap: () {
                    Navigator.of(context).pop(); //把对话框弹出
                    _handleForceLogout(); //转向登录页
                  },
                  width: 120,
                  height: 34,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //强制退出，转向登录页
  Future<void> _handleForceLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseIp = prefs.getString('baseIp')?.trim() ?? '';
    await prefs.clear();
    prefs.setString("baseIp", baseIp);
    _wsManager.forceClose();
    Get.offAndToNamed('/login');
  }

  Future<void> connectWebSocket() async {
    // 建立 WebSocket 连接
    _wsManager.connect();
  }

  final List<String> selectedIcons = [
    'chat',
    'user',
    'talk',
    'mine',
  ];

  final List<String> unselectedIcons = [
    'assets/images/chat-empty.png',
    'assets/images/user-empty.png',
    'assets/images/talk-empty.png',
    'assets/images/mine-empty.png',
  ];

  final List<String> name = [
    '消息',
    '通讯',
    '说说',
    '我的',
  ];

  @override
  void onClose() {
    super.onClose();
    _wsManager.dispose();
  }
}
