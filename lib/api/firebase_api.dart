import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// class FirebaseApi {
//   BuildContext? context;
//   // create instance of firebase messaging
//   final _firebaseMessaging = FirebaseMessaging.instance;
//   //function to initalize the notification
//   Future<void> initNotification() async {
//     //request permission from user (will prompt user)
//     await _firebaseMessaging.requestPermission();
//     //fetch the FCM token for this device
//     final fCMToken = await _firebaseMessaging.getToken();

//     //print the token
//     print('Token: ' + fCMToken.toString());

//     initPushNotification();
//   }

//   // funtion to handle the recve messages
//   void handleMessage(RemoteMessage? message) async {
//     //check if the message is null
//     if (message == null) return;
//     //check if the message is a data message
//     context!.goNamed('notification',
//         pathParameters: {'message': message.data.toString()});
//     //if the message is a notification message
//     //context!.goNamed('notification',pathParameters:
//   }

//   //function to initialize forground and background setting
//   Future initPushNotification() async {
//     //register the message listener
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//     //register the background messaonMessagege listener
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_bridge/firebase_options.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // تهيئة الإشعارات المحلية
  static Future<void> initializeLocalNotification() async {
    final fCMToken = await _firebaseMessaging.getToken();

    //print the token
    print('Token: ' + fCMToken.toString());
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // عرض الإشعار
  static Future<void> showFlutterNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            channelDescription: 'channel_description',
            importance: Importance.max,
            priority: Priority.high,
            icon: android.smallIcon,
          ),
        ),
      );
    }
  }

  // معالج رسائل Firebase عند وجود التطبيق في الخلفية
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await initializeLocalNotification();
    await showFlutterNotification(message);
  }

  // تهيئة كل خدمات الإشعارات
  static Future<void> initialize() async {
    await initializeLocalNotification();

    // طلب إذن الإشعارات (لنظام iOS)
    await _firebaseMessaging.requestPermission();

    // تعيين معالج الرسائل في الخلفية
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // معالجة الإشعارات عند فتح التطبيق
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
  }
}
