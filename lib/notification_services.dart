import 'dart:io';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

class NotificationService with WidgetsBindingObserver {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const MethodChannel _badgeChannel =
  MethodChannel('badge_channel');


  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    await _requestPermissions();
    await _initLocalNotifications();
    await _createAndroidChannel();
    await _setIOSForegroundOptions();

    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    _firebaseMessaging.onTokenRefresh.listen((token) async {
      debugPrint("🔄 FCM Token refreshed: $token");

      await AuthLocalStorage().setFcmToken(
        fcmToken: token,
      );
    });

    await Future.delayed(const Duration(seconds: 3));
    final token = await _getTokenWithRetry();
    print("📱 FCM Token: $token");
    AuthLocalStorage().setFcmToken(fcmToken: token);


    // iOS APNs token
    // if (Platform.isIOS) {
    //   final apnsToken = await _firebaseMessaging.getAPNSToken();
    //   print("🍏 APNs Token: $apnsToken");
    //   ObjectFactory().prefs.setFcmToken(fcmToken: token);
    // }
    if (Platform.isIOS) {
      final apnsToken = await _firebaseMessaging.getAPNSToken();

      if (apnsToken != null) {
        debugPrint("🍏 APNs Token: $apnsToken");
      } else {
        debugPrint("⚠️ APNs Token not available yet");
      }
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageTap);

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageTap(initialMessage);
    }
  }

  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 Notification tapped: ${response.payload}");
        _clearAll();
      },
    );
  }

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Important notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setIOSForegroundOptions() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> _getTokenWithRetry() async {
    for (int i = 0; i < 3; i++) {
      try {
        final token = await _firebaseMessaging.getToken();
        if (token != null) return token;
      } catch (e) {
        debugPrint("⚠️ Token retry ${i + 1} failed: $e");
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint("📩 Foreground message: ${message.notification?.title}");
    _showNotification(message);
  }

  void _onMessageTap(RemoteMessage message) {
    debugPrint("📲 Notification tapped: ${message.data}");
    _clearAll();
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const android = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: android,
      iOS: ios,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  Future<void> _clearAll() async {
    await _localNotifications.cancelAll();
  }

  static Future<int> getBadgeCount() async {
    try {
      return await _badgeChannel.invokeMethod<int>('getBadgeCount') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clearAll();
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📦 Background message: ${message.messageId}");
}
