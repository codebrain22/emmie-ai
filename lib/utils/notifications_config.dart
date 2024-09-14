import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/emmie_providers.dart';
import '../providers/firebase_providers.dart';
import '../views/chat_screen.dart';

class NotificationsConfiguration {
  /// Checks if permission has already been granted or denied.
  static void checkNotificationPermission({required WidgetRef ref}) async {
    FirebaseMessaging messaging = ref.read(firebaseMessagingProvider);
    NotificationSettings settings = await messaging.getNotificationSettings();

    // Check permission to display notifications.
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('NotificationsConfiguration.checkNotificationPermission: Notifications are enabled');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) {
        print('NotificationsConfiguration.checkNotificationPermission: Notifications are disabled');
      }
    } else {
      _requestPermission(messaging: messaging);
    }
  }

  /// Requests permission to send notifications
  static void _requestPermission({required FirebaseMessaging messaging}) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Check if the user has granted permission to display notifications
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('NotificationsConfiguration._requestPermission: User has granted permission to display notifications');
      }
    } else {
      if (kDebugMode) {
        print('NotificationsConfiguration._requestPermission: User has denied permission to display notifications');
      }
    }
  }

  /// Get user device token.
  static void getUserFcmToken(WidgetRef ref) async {
    FirebaseMessaging messaging = ref.read(firebaseMessagingProvider);
    final fcmToken = ref.read(fcmTokenStateProvider.notifier);

    // Listen to token refresh events.
    messaging.onTokenRefresh.listen((token) {
      // Update user device token;
      ref.read(authControllerStateNotifierProvider.notifier).updateDeviceToken(token: token);
      fcmToken.state = token;
    });

    // Get the initial FCM token.
    final token = await messaging.getToken();
    fcmToken.state = token ?? '';
  }

  /// Initialize notifications info.
  static void initializeInfo({required context, required ref}) {
    const androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInitialize);
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initSettings, onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      try {
        final routeFromMessage = notificationResponse.payload;
        if (routeFromMessage != null && routeFromMessage.isNotEmpty) {
          if (routeFromMessage == ChatScreen.routeName) {
            Navigator.of(context).pushNamed(routeFromMessage);
          } else {
            // Navigate to other screens
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("NotificationsConfiguration.initializeInfo.flutterLocalNotificationsPlugin: $e");
        }
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification?.body.toString() ?? '',
        htmlFormatBigText: true,
        contentTitle: message.notification?.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidNotificationPlatformChannelSpecifics = AndroidNotificationDetails(
        'emmieainotifications',
        'emmieainotifications',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidNotificationPlatformChannelSpecifics);

      final appSettings = ref.read(settingsModelStateProvider);
      if (!appSettings.notifictionsMuted) {
        await flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          message.notification?.title,
          message.notification?.body,
          platformChannelSpecifics,
          payload: message.data['route'],
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      try {
        final routeFromMessage = message.data['route'] as String;
        if (routeFromMessage == ChatScreen.routeName) {
          ref.read(pageIndexStateProvider.notifier).state = 1;
          Navigator.pushNamed(context, routeFromMessage);
        }
      } catch (e) {
        if (kDebugMode) {
          print("NotificationsConfiguration.initializeInfo.FirebaseMessaging.onMessageOpenedApp: $e");
        }
      }
    });
  }
}
