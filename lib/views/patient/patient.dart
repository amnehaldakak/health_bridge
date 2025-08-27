import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  final List<String> _nameWidget = [
    'الرئيسية',
    'السجلات الصحية',
    'الأدوية',
    'المجتمع',
    'المساعد الذكي'
  ];

  final List<Widget> _children = [
    HomePatient(),
    RecordsPatient(),
    Medicine(),
    CommunityPatient(),
    ChatBotPatient(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // الحصول على بيانات المستخدم من الـ Provider
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _nameWidget[_currentIndex],
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(currentUser?.name ?? 'مستخدم غير معروف'),
              accountEmail: Text(currentUser?.email ?? "لا يوجد بريد إلكتروني"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (currentUser?.profilePicture != null &&
                        currentUser!.profilePicture!.isNotEmpty) // ✅ null safe
                    ? NetworkImage(
                        currentUser!.profilePicture!) // ✅ forced non-null
                    : null,
                child: (currentUser?.profilePicture == null ||
                        currentUser!.profilePicture!.isEmpty)
                    ? Text(
                        (currentUser?.name?.isNotEmpty ==
                                true) // ✅ check safely
                            ? currentUser!.name![0]
                                .toUpperCase() // ✅ safe access
                            : "?",
                        style:
                            const TextStyle(fontSize: 30, color: Colors.black),
                      )
                    : null,
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("تسجيل الخروج"),
              onTap: () async {
                final bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تسجيل الخروج'),
                    content:
                        const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('تأكيد'),
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
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_records_7876298, size: 30),
            label: 'السجلات',
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_medicine_7944091, size: 30),
            label: 'الأدوية',
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_public_health_7933246, size: 30),
            label: 'المجتمع',
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.chatempty, size: 30),
            label: 'المساعد',
          ),
        ],
      ),
    );
  }
}
