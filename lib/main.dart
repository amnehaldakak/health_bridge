import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/api/firebase_api.dart';
import 'package:health_bridge/config/routes/app_route_config.dart';
import 'package:health_bridge/config/app_theme.dart';
import 'package:health_bridge/firebase_options.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseApi().initNotification();
  prefs = await SharedPreferences.getInstance();

  NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(
      NotificationService.firebaseMessagingBackgroundHandler);
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs), // ✅
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Health Bridge',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter, // استخدم routerConfig بدلاً من الطريقة القديمة
      theme: appTheme,
    );
  }
}
