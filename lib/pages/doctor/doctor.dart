import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
// import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/pages/doctor/community_doctor.dart';
import 'package:health_bridge/pages/doctor/community_list.dart';
import 'package:health_bridge/pages/doctor/home_doctor.dart';
import 'package:health_bridge/pages/doctor/records_doctor.dart';
import 'package:health_bridge/pages/patient/chat_bot_patient.dart';
import 'package:health_bridge/pages/patient/community_patient.dart';
import 'package:health_bridge/pages/patient/home_patient.dart';
import 'package:health_bridge/pages/patient/medicine.dart';
import 'package:health_bridge/pages/patient/records_patient.dart';

class Doctor extends StatefulWidget {
  const Doctor({super.key});

  @override
  State<Doctor> createState() => _DoctorState();
}

class _DoctorState extends State<Doctor> {
  int _currentIndex = 0;
  //the list of of navigator bar
  final List<String> _nameWidget = [
    'Home',
    'Health Records',
    'Community',
    'Chat Bot'
  ];
  final List<Widget> _children = [
    HomeDoctor(),
    RecordsDoctor(),
    CommunitiesPage(),
    ChatBotPatient(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          child: ListView(children: [
        ListView(
          children: [
            InkWell(
              onTap: () {
                // Get.toNamed('patentprofile');
              },
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('image/PI.jpeg'),
                      backgroundColor: Colors.grey,
                    ),
                    Expanded(
                      child: ListTile(
                        style: ListTileStyle.drawer,
                        title: Text(
                          'name ',
                          style: TextStyle(
                              fontSize: 20, color: theme.secondaryHeaderColor),
                        ),
                        subtitle: Text(
                          'email',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ])),
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
            icon: Icon(
              MyFlutterApp.home,
              size: 30,
              weight: 3,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              MyFlutterApp.noun_records_7876298,
              size: 30,
              weight: 3,
            ),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              MyFlutterApp.noun_public_health_7933246,
              size: 30,
              weight: 3,
            ),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              MyFlutterApp.chatempty,
              size: 30,
              weight: 3,
            ),
            label: 'Chat bot',
          ),
        ],
      ),
    );
  }
}
