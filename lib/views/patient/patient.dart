import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/language_bottom_sheet.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/views/patient/chat_bot_patient.dart';
import 'package:health_bridge/views/patient/community_patient.dart';
import 'package:health_bridge/views/patient/home_patient.dart';
import 'package:health_bridge/views/patient/medicine.dart';
import 'package:health_bridge/views/patient/records_patient.dart';

class Patient1 extends ConsumerStatefulWidget {
  const Patient1({super.key});

  @override
  ConsumerState<Patient1> createState() => _PatientState();
}

class _PatientState extends ConsumerState<Patient1> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomePatient(),
    RecordsPatient(),
    Medicine(),
    CommunityPatient(),
    ChatBotPatient(),
  ];

  // الحصول على أسماء الـ widgets بناءً على اللغة الحالية
  List<String> _getWidgetNames(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      loc!.get('home'),
      loc.get('health_records'),
      loc.get('medicines'),
      loc.get('community'),
      loc.get('smart_assistant'),
    ];
  }

  // دالة مساعدة للحصول على الحرف الأول من الاسم بشكل آمن
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "?";
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final widgetNames = _getWidgetNames(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widgetNames[_currentIndex],
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            InkWell(
              onTap: () => context.pushNamed('profile_page'),
              child: UserAccountsDrawerHeader(
                accountName:
                    Text(currentUser?.name ?? loc!.get('unknown_user')),
                accountEmail: Text(currentUser?.email ?? loc!.get('no_email')),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (currentUser?.profilePicture != null &&
                          currentUser!.profilePicture!.isNotEmpty)
                      ? NetworkImage(currentUser.profilePicture!)
                      : null,
                  child: (currentUser?.profilePicture == null ||
                          currentUser?.profilePicture?.isEmpty == true)
                      ? Text(
                          _getInitials(currentUser?.name),
                          style: const TextStyle(
                              fontSize: 30, color: Colors.black),
                        )
                      : null,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                ),
              ),
            ),
            // زر تغيير اللغة
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: Text(loc!.get('change_language')),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const LanguageBottomSheet(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(loc.get('logout')),
              onTap: () async {
                final bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(loc.get('logout')),
                    content: Text(loc.get('logout_confirmation')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(loc.get('cancel')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(loc.get('confirm')),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  // عرض دائرة التحميل
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // تنفيذ تسجيل الخروج
                  await ref.read(authControllerProvider.notifier).logout();

                  // إغلاق دائرة التحميل والتوجيه
                  if (mounted) {
                    Navigator.of(context).pop(); // إغلاق دائرة التحميل
                    context.go('/login');
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        selectedFontSize: 18,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.home, size: 30),
            label: loc!.get('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_records_7876298, size: 30),
            label: loc.get('records'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_medicine_7944091, size: 30),
            label: loc.get('medicines'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_public_health_7933246, size: 30),
            label: loc.get('community'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.chatempty, size: 30),
            label: loc.get('smart_assistant'),
          ),
        ],
      ),
    );
  }
}
