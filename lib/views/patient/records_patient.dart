// lib/views/patient/records_patient.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/health_value_card.dart';
import 'package:health_bridge/controller/health_value_controller.dart';
import 'package:health_bridge/models/health_value.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:animated_expandable_fab/animated_expandable_fab.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/providers/health_value_provider.dart';
import 'package:health_bridge/views/doctor/patient_cases.dart';

class RecordsPatient extends ConsumerStatefulWidget {
  const RecordsPatient({super.key});

  @override
  ConsumerState<RecordsPatient> createState() => _RecordsPatientState();
}

class _RecordsPatientState extends ConsumerState<RecordsPatient> {
  PatientModel? patient;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientData();
      _loadAllHealthValues();
    });
  }

  Future<void> _loadPatientData() async {
    try {
      final pref = ref.read(sharedPreferencesProvider);
      final loadedPatient = await PatientModel.getPatientFromPrefs(pref);
      if (mounted) {
        setState(() {
          patient = loadedPatient;
        });
      }
    } catch (e) {
      print("Error loading patient data: $e");
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل في تحميل بيانات المريض';
        });
      }
    }
  }

  Future<void> _loadAllHealthValues() async {
    try {
      final controller = ref.read(healthValueControllerProvider.notifier);

      // تحميل قيم ضغط الدم (diseaseId = 1)
      await controller.loadHealthValues(1);

      // تحميل قيم السكر (diseaseId = 2)
      await controller.loadHealthValues(2);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading health values: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل في تحميل البيانات الصحية';
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await Future.wait([_loadPatientData(), _loadAllHealthValues()]);
  }

  Future<void> _refreshHealthData() async {
    try {
      final controller = ref.read(healthValueControllerProvider.notifier);

      // إعادة تحميل كل الأمراض
      await controller.loadHealthValues(1);
      await controller.loadHealthValues(2);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
        );
      }
    } catch (e) {
      print("Error refreshing health data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحديث البيانات')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (patient == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('لا توجد بيانات للمريض'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('إعادة تحميل'),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final selectedDate = ref.watch(selectedDateProvider);
        final healthState = ref.watch(healthValueControllerProvider);
        final filteredValues = ref.watch(filteredHealthValuesProvider);

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
                indicatorColor:
                    theme.bottomNavigationBarTheme.selectedItemColor,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                unselectedLabelStyle: const TextStyle(fontSize: 15),
                tabs: const [
                  Tab(text: 'Health Value'),
                  Tab(text: 'Patient Records'),
                ],
              ),
            ),
            body: Container(
              padding: const EdgeInsets.all(10),
              child: TabBarView(
                children: [
                  // ========== Health Value Tab ==========
                  Scaffold(
                    floatingActionButton: ExpandableFab(
                      distance: 100,
                      openIcon: const Icon(Icons.add),
                      closeIcon: const Icon(Icons.close),
                      children: [
                        ActionButton(
                          color: Colors.white,
                          icon: Icon(MyFlutterApp.noun_blood_pressure_7315638,
                              color: Colors.red),
                          onPressed: () => context.pushNamed('addpressure'),
                        ),
                        ActionButton(
                          color: Colors.white,
                          icon: Icon(MyFlutterApp.noun_diabetes_test_7357853,
                              color: Colors.blue),
                          onPressed: () => context.pushNamed('add_sugar'),
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
                            ref.read(selectedDateProvider.notifier).state =
                                date;
                          },
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
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildHealthValuesContent(
                              healthState, filteredValues),
                        ),
                      ],
                    ),
                  ),

                  // ========== Patient Records Tab ==========
                  PatientCasesPage(patient: patient!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthValuesContent(
      HealthValueState healthState, List<HealthValue> filteredValues) {
    if (healthState is HealthValueLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (healthState is HealthValueError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(healthState.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshHealthData,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    } else if (filteredValues.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "لا توجد بيانات في هذا اليوم",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: _refreshHealthData,
        child: ListView.builder(
          itemCount: filteredValues.length,
          itemBuilder: (context, index) {
            final val = filteredValues[index];
            final isBP = val.diseaseId == 1;

            return HealthValueCard(
              cardColor: isBP ? Colors.red.shade100 : Colors.blue.shade100,
              borderColor: isBP ? Colors.red : Colors.blue,
              iconColor: isBP ? Colors.red : Colors.blue,
              icon: isBP
                  ? MyFlutterApp.noun_blood_pressure_7315638
                  : MyFlutterApp.noun_diabetes_test_7357853,
              text:
                  "${val.diseaseType}: ${val.displayValue} (${val.status ?? ''})\nتم الإدخال: ${val.createdAt.hour}:${val.createdAt.minute.toString().padLeft(2, '0')}",
              onDelete: () async {
                final success = await ref
                    .read(healthValueControllerProvider.notifier)
                    .deleteHealthValue(val.id);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل في حذف القيمة id=${val.id}')),
                  );
                } else {
                  // تحديث البيانات بعد الحذف
                  _refreshHealthData();
                }
              },
            );
          },
        ),
      );
    }
  }
}
