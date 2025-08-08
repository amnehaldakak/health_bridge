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
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      // يمكن إضافة إعدادات iOS هنا إذا لزم الأمر
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
