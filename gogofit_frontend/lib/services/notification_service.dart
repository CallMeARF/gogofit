// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService({required this.flutterLocalNotificationsPlugin});

  Future<void> init() async {
    // 'ic_stat_logoo' merujuk ke ikon yang baru Anda tambahkan di folder drawable
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          'ic_stat_logoo',
        ); // <<< UBAH KE NAMA IKON BARU

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          onDidReceiveLocalNotification: (id, title, body, payload) async {
            debugPrint('iOS foreground notification: $title, $body, $payload');
          },
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) {
        debugPrint('Notification tapped: ${notificationResponse.payload}');
      },
    );
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          icon: 'ic_stat_logoo', // <<< UBAH KE NAMA IKON BARU
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

final NotificationService notificationService = NotificationService(
  flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
);
