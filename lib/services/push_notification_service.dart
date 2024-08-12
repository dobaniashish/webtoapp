// https://medium.com/@alaa07996/firebase-push-notifications-with-flutter-6848892a1c15
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_messaging/firebase_messaging/example/lib/main.dart

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class PushNotificationService {
  // Singleton instance
  static PushNotificationService? _instance;

  // Variables
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Function(NotificationResponse notificationResponse)? onDidReceiveNotificationResponse;

  // Constructor
  PushNotificationService._() : flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Factory for singleton
  factory PushNotificationService() {
    return _instance ??= PushNotificationService._();
  }

  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // Register with FCM
    await messaging.getToken();

    // Subscribe to our channel
    FirebaseMessaging.instance.subscribeToTopic('all');

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    AndroidNotificationChannel channel = androidNotificationChannel();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle local notification payload
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        if (onDidReceiveNotificationResponse != null) {
          onDidReceiveNotificationResponse!(notificationResponse);
        }
      },
    );

    // Handle message when app is active
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });
  }

  AndroidNotificationChannel androidNotificationChannel() => const AndroidNotificationChannel(
        'foreground_notifications', // Id
        'Foreground notifications', // Title
        description:
            'This channel is used to send notifications when the app is in foreground.', // Description
        importance: Importance.high,
      );
}
