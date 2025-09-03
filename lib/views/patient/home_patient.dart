import 'package:flutter/material.dart';
import 'package:health_bridge/config/content/health_value_card.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';

class HomePatient extends StatefulWidget {
  const HomePatient({super.key});

  @override
  State<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // عنوان القسم
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                loc!.get('health_status'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // بطاقات القيم الصحية
            Row(
              children: [
                Expanded(
                  child: HealthValueCard(
                    cardColor: Colors.red.shade100,
                    borderColor: Colors.red,
                    iconColor: Colors.red,
                    icon: MyFlutterApp.noun_blood_pressure_7315638,
                    text: "${loc.get('blood_pressure')}: 120/80",
                  ),
                ),
                Expanded(
                  child: HealthValueCard(
                    cardColor: Colors.blue.shade100,
                    borderColor: Colors.blue,
                    iconColor: Colors.blue,
                    icon: MyFlutterApp.noun_diabetes_test_7357853,
                    text: "${loc.get('blood_sugar')}: 120",
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // قسم الإحصائيات أو المعلومات الإضافية
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                loc.get('recent_activity'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // محتوى إضافي (يمكن استبداله ببيانات حقيقية)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.get('last_measurement'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${loc.get('blood_pressure')}: 120/80 (${loc.get('normal')})",
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    "${loc.get('blood_sugar')}: 98 (${loc.get('normal')})",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${loc.get('measured_on')}: 2023-12-07 10:30",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // قسم سريع للإجراءات
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                loc.get('quick_actions'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // أزرار الإجراءات السريعة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // الانتقال إلى صفحة إضافة ضغط الدم
                  },
                  icon:
                      Icon(MyFlutterApp.noun_blood_pressure_7315638, size: 20),
                  label: Text(loc.get('add_blood_pressure')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // الانتقال إلى صفحة إضافة السكر
                  },
                  icon: Icon(MyFlutterApp.noun_diabetes_test_7357853, size: 20),
                  label: Text(loc.get('add_blood_sugar')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
