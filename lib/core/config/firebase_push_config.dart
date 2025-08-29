import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebasePushConfig {
  static final FirebasePushConfig _i = FirebasePushConfig._();
  FirebasePushConfig._();

  factory FirebasePushConfig() => _i;
  static late FirebaseMessaging messaging;

  static Future<void> init() async {
    messaging = FirebaseMessaging.instance;
    if (kIsWeb) {
      final token = await messaging.getToken(
        vapidKey:
            "BHDPVjiZe1SndybScWry_5GfseA-uj27aJcsuAoyBgDyONRUYd5G9M7xg21YRVdGnMb8wghhXKurPvZkSTIy4Dg",
      );
    }
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Inicializar o plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'min_importance_channel',
      'Min Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

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
            icon: 'ic_launcher', // Especifica o ícone
            importance: Importance.min,
            priority: Priority.min,
          )),
        );
      }
    });
  }

  static Future<void> subscriberTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscriberTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
  }

  static Future<void> messagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    print("Handling a background message: ${message.messageId}");
  }
}
