import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/user_api.dart';

final _userApi = UserApi();

//本地通知工具类，用于在系统通知栏显示各种类型的通知消息。
class NotificationUtil {
  //通知插件
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 初始化通知服务
  static Future<void> initialize() async {
    // Android设置（通知图标）
    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS设置请求权限）
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,   // 请求提醒权限
          requestBadgePermission: true,   // 请求角标权限
          requestSoundPermission: true,   // 请求声音权限
    );

    // 合并设置
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitialize,
      iOS: initializationSettingsIOS,
    );

    // 初始化插件
    await _notificationsPlugin.initialize(
      initializationSettings,
      // 处理通知点击事件
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 处理通知点击
        print('通知点击: ${response.payload}');
      },
    );

    // 对于 Android 13 及以上版本，请求通知权限
    if (Platform.isAndroid) {
      final platformVersion = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.getNotificationChannels();
      if (platformVersion != null) {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
    }
  }

  // 创建通知渠道（Android）
  static Future<void> createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',        // 渠道ID
      'High Importance Notifications',  // 渠道名称
      description: 'This channel is used for important notifications.',
      importance: Importance.high,      // 重要性（决定通知行为）
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);//创建通知渠道
  }

  // 显示普通通知
/*
  ┌─────────────────────────────────────────────────────────────────────────┐
  │                        通知栏                                           │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │   🔔 你的App                                                            │
  │   ──────────────────────────────────────────────────────────────────── │
  │   张三                                                                  │
  │   张三: 你好，在吗？                                                    │
  │   10:30                                                                │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘*/
  static Future<void> showNotification({
    required int id,          // 通知ID（用于更新或取消）
    required String title,    // 通知标题
    required String body,     // 通知内容
    String? payload,          // 附加数据（点击时获取）
  }) async {
    // Android 通知详情
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    // iOS 通知详情
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,   // 显示提醒
      presentBadge: true,   // 显示角标
      presentSound: true,   // 播放声音
    );

    //合并通知详情
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    //发出通知
    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // 显示带进度的通知
/*
  ┌─────────────────────────────────────────────────────────────────────────┐
  │   🔔 你的App                                                            │
  │   ──────────────────────────────────────────────────────────────────── │
  │   文件下载                                                              │
  │   正在下载文件... 45%                                                   │
  │   ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░ 45%                                             │
  │   10:30                                                                │
  └─────────────────────────────────────────────────────────────────────────┘*/
  static Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'progress_channel',
      'Progress Notifications',
      channelDescription: 'Notifications with progress bar',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
    );
  }

  // 显示带图片的通知
/*
  ┌─────────────────────────────────────────────────────────────────────────┐
  │   🔔 你的App                                                            │
  │   ──────────────────────────────────────────────────────────────────── │
  │   张三发了一张图片                                                       │
  │   ┌─────────────────────────────────────────────────────────────────┐   │
  │   │                                                                 │   │
  │   │                         🖼️ 图片                                │   │
  │   │                                                                 │   │
  │   └─────────────────────────────────────────────────────────────────┘   │
  │   10:30                                                                │
  └─────────────────────────────────────────────────────────────────────────┘*/
  static Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String imagePath,
  }) async {
    final bigPicture = await _getStyleInformation(imagePath);

    final androidDetails = AndroidNotificationDetails(
      'big_picture_channel',
      'Big Picture Notifications',
      channelDescription: 'Notifications with big picture',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPicture,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
    );
  }

  // 获取大图样式信息
  static Future<BigPictureStyleInformation> _getStyleInformation(
      String imagePath) async {
    return BigPictureStyleInformation(
      //获取图片
      ByteArrayAndroidBitmap.fromBase64String(
          await _userApi.getNetworkImage(imagePath)),
      contentTitle: '', //大图内部的标题文字
      htmlFormatContentTitle: true, //	标题是否支持 HTML 格式
      summaryText: '', //大图内部的摘要/副标题文字
      htmlFormatSummaryText: true, //	摘要是否支持 HTML 格式
    );
  }

  // 取消指定ID的通知
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // 取消所有通知
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
