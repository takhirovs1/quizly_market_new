import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logbook/logbook.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constant/firebase_options.g.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

InitializationSettings initializationSettings = const InitializationSettings(
  android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  iOS: DarwinInitializationSettings(),
);

@immutable
sealed class NotificationService {
  const NotificationService._();

  static Future<bool> checkNotificationPermission() async {
    final permission = await Permission.notification.status;
    return permission.isGranted || permission.isLimited;
  }

  static Future<bool?> initialize() async {
    final permission = await Permission.notification.request();

    if (permission.isDenied || permission.isPermanentlyDenied) {
      return false;
    }

    await setupFlutterNotifications();
    await foregroundNotification();
    backgroundNotification();
    await terminateNotification();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    try {
      await FirebaseMessaging.instance.getAPNSToken().then((token) => l.i('APNS TOKEN: $token'));
      await FirebaseMessaging.instance.getToken().then((token) => l.i('FCM TOKEN: $token'));
    } on Object catch (e, s) {
      l.s(e, s);
    }

    return permission.isGranted;
  }

  static Future<void> setupFlutterNotifications() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(criticalAlert: true, announcement: true, provisional: true);
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void showFlutterNotification(RemoteMessage message) {
    if (message.data.isNotEmpty && !kIsWeb) {
      flutterLocalNotificationsPlugin
          .show(
            id: message.hashCode,
            title: message.data['title'] as String?,
            body: message.data['body'] as String?,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                styleInformation: BigTextStyleInformation(
                  (message.data['body'] as String?) ?? '',
                  contentTitle: message.data['title'] as String?,
                ),
                icon: '@mipmap/ic_launcher',
                priority: Priority.high,
                importance: Importance.high,
                visibility: NotificationVisibility.public,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: 'default',
              ),
            ),
            payload: message.data['route'] as String?,
          )
          .ignore();
    }
  }

  static Future<void> foregroundNotification() async {
    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    /// When tapped
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        l.i('foreground notification tapped');
        l.i('$response');
      },
    );
  }

  static void backgroundNotification() => FirebaseMessaging.onMessageOpenedApp.listen(showFlutterNotification);

  static Future<void> terminateNotification() async {
    final remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage == null) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } else {
      showFlutterNotification(remoteMessage);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.setupFlutterNotifications();

  NotificationService.showFlutterNotification(message);
}
