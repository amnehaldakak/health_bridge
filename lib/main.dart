import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/routes/app_route_config.dart';
import 'package:health_bridge/config/app_theme.dart';
import 'package:health_bridge/firebase_options.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/providers/local_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_bridge/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // هنا نستخدم Riverpod
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Health Bridge',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: appTheme,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      locale: locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
