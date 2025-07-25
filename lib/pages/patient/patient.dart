import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
// import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/pages/patient/chat_bot_patient.dart';
import 'package:health_bridge/pages/patient/community_patient.dart';
import 'package:health_bridge/pages/patient/home_patient.dart';
import 'package:health_bridge/pages/patient/medicine.dart';
import 'package:health_bridge/pages/patient/records_patient.dart';

class Patient extends StatefulWidget {
  const Patient({super.key});

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  int _currentIndex = 0;
  //the list of of navigator bar
  final List<String> _nameWidget = [
    'Home',
    'Health Records',
    'Medicine',
    'Community',
    'Chat Bot'
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _nameWidget[_currentIndex],
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
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
              MyFlutterApp.noun_medicine_7944091,
              size: 30,
              weight: 3,
            ),
            label: 'Medicine',
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
