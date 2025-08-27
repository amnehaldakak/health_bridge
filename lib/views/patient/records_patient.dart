import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/config/content/health_value_card.dart';
import 'package:health_bridge/controller/health_value_controller.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:animated_expandable_fab/animated_expandable_fab.dart';
import 'package:health_bridge/providers/health_value_provider.dart';
import 'package:health_bridge/views/doctor/patient_cases.dart';

class RecordsPatient extends StatefulWidget {
  RecordsPatient({super.key});

  @override
  State<RecordsPatient> createState() => _RecordsPatientState();
}

class _RecordsPatientState extends State<RecordsPatient> {
  PatientModel?
      patient; // جعلنا patient nullable لأنه سيتم تحميله بشكل غير متزامن

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      PatientModel loadedPatient = await PatientModel.getPatientFromPrefs();
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

/// Provider لتخزين اليوم المختار
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

class HealthValue extends ConsumerStatefulWidget {
  const HealthValue({super.key});

  @override
  ConsumerState<HealthValue> createState() => _HealthValueState();
}

class _HealthValueState extends ConsumerState<HealthValue> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات لجميع الأمراض عند فتح الصفحة
    Future.microtask(() {
      ref
          .read(healthValueControllerProvider.notifier)
          .loadHealthValues(1); // ضغط الدم
      ref
          .read(healthValueControllerProvider.notifier)
          .loadHealthValues(2); // سكر الدم
    });
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(healthValuesProvider);
    final state = ref.watch(healthValueControllerProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // فلترة القيم حسب اليوم المختار وترتيبها من الأحدث للأقدم
    final filteredValues = values
        .where((val) =>
            val.createdAt.year == selectedDate.year &&
            val.createdAt.month == selectedDate.month &&
            val.createdAt.day == selectedDate.day)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      floatingActionButton: ExpandableFab(
        distance: 100,
        openIcon: const Icon(Icons.add),
        closeIcon: const Icon(Icons.close),
        children: [
          ActionButton(
            color: Colors.white,
            icon: Icon(MyFlutterApp.noun_blood_pressure_7315638,
                color: Colors.red),
            onPressed: () {
              context.pushNamed('addpressure');
            },
          ),
          ActionButton(
            color: Colors.white,
            icon: Icon(MyFlutterApp.noun_diabetes_test_7357853,
                color: Colors.blue),
            onPressed: () {
              context.pushNamed('add_sugar');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarTimeline(
            initialDate: selectedDate,
            firstDate: DateTime(2020, 1, 1),
            lastDate: DateTime(9999, 12, 31),
            onDateSelected: (date) {
              ref.read(selectedDateProvider.notifier).state = date;
            },
            leftMargin: 20,
            monthColor: Colors.blueGrey,
            dayColor: Theme.of(context).colorScheme.primary,
            activeDayColor: Colors.white,
            activeBackgroundDayColor:
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
            dotColor: const Color(0xFF333A47),
            selectableDayPredicate: (date) => date.day != 0,
            locale: 'en',
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state is HealthValueLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HealthValueError) {
                  return Center(child: Text(state.message));
                } else if (filteredValues.isEmpty) {
                  return const Center(
                      child: Text("لا توجد بيانات في هذا اليوم"));
                } else {
                  return ListView.builder(
                    itemCount: filteredValues.length,
                    itemBuilder: (context, index) {
                      final val = filteredValues[index];
                      final isBloodPressure = val.diseaseId == 1;

                      return HealthValueCard(
                        cardColor: isBloodPressure
                            ? Colors.red.shade100
                            : Colors.blue.shade100,
                        borderColor: isBloodPressure ? Colors.red : Colors.blue,
                        iconColor: isBloodPressure ? Colors.red : Colors.blue,
                        icon: isBloodPressure
                            ? MyFlutterApp.noun_blood_pressure_7315638
                            : MyFlutterApp.noun_diabetes_test_7357853,
                        text:
                            "${val.diseaseType}: ${val.displayValue} (${val.status ?? ''})\nتم الإدخال: ${val.createdAt.hour}:${val.createdAt.minute.toString().padLeft(2, '0')}",
                        onDelete: () async {
                          try {
                            final success = await ref
                                .read(healthValueControllerProvider.notifier)
                                .deleteHealthValue(val.id);
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('فشل في حذف القيمة id=${val.id}')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('خطأ عند الحذف: $e')),
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
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
