import 'package:flutter/material.dart';
// import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/config/content/health_value_card.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';

class HomePatient extends StatefulWidget {
  const HomePatient({super.key});

  @override
  State<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            Row(
              children: [
                HealthValueCard(
                    cardColor: Colors.red.shade100,
                    borderColor: Colors.red,
                    iconColor: Colors.red,
                    icon: MyFlutterApp.noun_blood_pressure_7315638,
                    text: "pressuse: 120"),
                HealthValueCard(
                    cardColor: Colors.blue.shade100,
                    borderColor: Colors.blue,
                    iconColor: Colors.blue,
                    icon: MyFlutterApp.noun_diabetes_test_7357853,
                    text: "Suger: 120")
              ],
            )
          ],
        ),
      ),
    );
  }
}
