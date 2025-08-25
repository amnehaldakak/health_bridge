import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/config/content/health_value_card.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:animated_expandable_fab/animated_expandable_fab.dart';
import 'package:health_bridge/pages/doctor/patient_cases.dart';

class RecordsPatient extends StatefulWidget {
  RecordsPatient({super.key});

  @override
  State<RecordsPatient> createState() => _RecordsPatientState();
}

class _RecordsPatientState extends State<RecordsPatient> {
  Patient? patient; // جعلنا patient nullable لأنه سيتم تحميله بشكل غير متزامن

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      Patient loadedPatient = await Patient.getPatientFromPrefs();
      setState(() {
        patient = loadedPatient;
      });
    } catch (e) {
      print("Error loading patient data: $e");
      // يمكنك إضافة تعامل مع الأخطاء هنا
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // عرض مؤشر تحميل أثناء جلب البيانات
    if (patient == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: theme.bottomNavigationBarTheme.selectedItemColor,
            unselectedLabelColor:
                theme.bottomNavigationBarTheme.unselectedItemColor,
            indicatorColor: theme.bottomNavigationBarTheme.selectedItemColor,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            unselectedLabelStyle: const TextStyle(fontSize: 15),
            tabs: const [
              Tab(
                text: 'Health Value',
              ),
              Tab(
                text: "Recoreds Health",
              )
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: TabBarView(
            children: [
              HealthValue(),
              PatientCases(
                  patient: patient!), // استخدام patient بعد التأكد من وجوده
            ],
          ),
        ),
      ),
    );
  }
}

class HealthValue extends StatefulWidget {
  const HealthValue({super.key});

  @override
  State<HealthValue> createState() => _HealthValueState();
}

class _HealthValueState extends State<HealthValue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ExpandableFab(
        distance: 100,
        openIcon: Icon(Icons.add),
        closeIcon: Icon(Icons.close),
        children: [
          ActionButton(
              color: Colors.white,
              icon: Icon(
                MyFlutterApp.noun_blood_pressure_7315638,
                color: Colors.red,
              ),
              onPressed: () {
                context.goNamed('addpressure');
              }),
          ActionButton(
            color: Colors.white,
            icon: Icon(
              MyFlutterApp.noun_diabetes_test_7357853,
              color: Colors.blue,
            ),
            onPressed: () {
              // استخدام Navigator.pushNamed بدلاً من context.goNamed إذا لم يكن مسجلاً في GoRouter
              Navigator.pushNamed(context, 'addsugar');
            },
          ),
        ],
      ),
      body: Container(
        child: ListView(
          children: [
            CalendarTimeline(
              initialDate: DateTime.now(),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(9999, 12, 31),
              onDateSelected: (date) {},
              leftMargin: 20,
              monthColor: Colors.blueGrey,
              dayColor: Theme.of(context).colorScheme.primary,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Theme.of(context)
                  .bottomNavigationBarTheme
                  .unselectedItemColor,
              dotColor: const Color(0xFF333A47),
              selectableDayPredicate: (date) => date.day != 0,
              locale: 'en',
            ),
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
        ),
      ),
    );
  }
}

class Recored extends StatefulWidget {
  const Recored({super.key});

  @override
  State<Recored> createState() => _RecoredState();
}

class _RecoredState extends State<Recored> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        child: Icon(
          Icons.add,
          weight: 3,
          color: theme.appBarTheme.backgroundColor,
        ),
      ),
    );
  }
}
