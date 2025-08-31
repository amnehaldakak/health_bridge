import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // لازم تضيفها
import 'package:health_bridge/config/content/language_bottom_sheet.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/views/doctor/community_doctor.dart';
import 'package:health_bridge/views/doctor/community_list.dart';
import 'package:health_bridge/views/doctor/home_doctor.dart';
import 'package:health_bridge/views/doctor/records_doctor.dart';
import 'package:health_bridge/views/patient/chat_bot_patient.dart';

class Doctor extends ConsumerStatefulWidget {
  const Doctor({super.key});

  @override
  ConsumerState<Doctor> createState() => _DoctorState();

  static Doctor? fromJson(doctorData) {
    // هنا لو محتاج تعمل parsing لبيانات الدكتور
    return null;
  }
}

class _DoctorState extends ConsumerState<Doctor> {
  int _currentIndex = 0;

  final List<String> _nameWidget = [
    'Home',
    'Health Records',
    'Community',
    'Chat Bot'
  ];

  final List<Widget> _children = [
    const HomeDoctor(),
    const RecordsDoctor(),
    CommunitiesPage(),
    const ChatBotPatient(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            InkWell(
              onTap: () => context.pushNamed('profile_page'),
              child: UserAccountsDrawerHeader(
                accountName: Text(currentUser?.name ?? 'مستخدم غير معروف'),
                accountEmail:
                    Text(currentUser?.email ?? "لا يوجد بريد إلكتروني"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (currentUser?.profilePicture != null &&
                          currentUser!.profilePicture!.isNotEmpty)
                      ? NetworkImage(currentUser.profilePicture!)
                      : null,
                  child: (currentUser?.profilePicture == null ||
                          currentUser!.profilePicture!.isEmpty)
                      ? Text(
                          (currentUser?.name?.isNotEmpty == true)
                              ? currentUser!.name![0].toUpperCase()
                              : "?",
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
              title: const Text("تغيير اللغة"),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) =>
                      const LanguageBottomSheet(), // استخدم الـ Bottom Sheet
                );
              },
            ),

            // زر تسجيل الخروج
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
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  await ref.read(authControllerProvider.notifier).logout();

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_records_7876298, size: 30),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_public_health_7933246, size: 30),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.chatempty, size: 30),
            label: 'Chat bot',
          ),
        ],
      ),
    );
  }
}
