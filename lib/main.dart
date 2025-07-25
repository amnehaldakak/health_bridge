import 'package:flutter/material.dart';
import 'package:health_bridge/config/routes/app_route_config.dart';
import 'package:health_bridge/config/app_theme.dart';

void main() {
  runApp(const MyApp());
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
