import 'package:flutter/material.dart';
import 'package:health_bridge/config/content/buildMedicationItem.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/views/add_medicine.dart';
import 'package:health_bridge/views/doctor/add_treatment_pathway.dart';

class TreatmentPlan {
  String name;
  String description;
  List<MedicationTime> medications;

  TreatmentPlan({
    required this.name,
    required this.description,
    required this.medications,
  });
}

class TreatmentPathway extends StatefulWidget {
  const TreatmentPathway({super.key});

  @override
  State<TreatmentPathway> createState() => _TreatmentPathwayState();
}

class _TreatmentPathwayState extends State<TreatmentPathway> {
  List<TreatmentPlan> _treatmentPlans = [
    TreatmentPlan(
      name: 'الخطة رقم 1',
      description: 'استخدام الأدوية مع الالتزام بالوقت',
      medications: [
        MedicationTime(
          medicationTimeId: 'MT001',
          userId: 'USER123',
          medicationName: 'سيبروفلوسين',
          amount: '500mg',
          timePerDay: 2,
          firstDoseTime: '08:00',
          startDate: DateTime.now(),
          durationDays: 7,
        ),
        MedicationTime(
          medicationTimeId: 'MT002',
          userId: 'USER123',
          medicationName: 'باراسيتامول',
          amount: '500mg',
          timePerDay: 3,
          firstDoseTime: '06:00',
          startDate: DateTime.now(),
          durationDays: 5,
        ),
      ],
    ),
    TreatmentPlan(
      name: 'الخطة رقم 2',
      description: 'بعد الخروج من المستشفى',
      medications: [
        MedicationTime(
          medicationTimeId: 'MT003',
          userId: 'USER123',
          medicationName: 'أوميبرازول',
          amount: '20mg',
          timePerDay: 1,
          firstDoseTime: '07:00',
          startDate: DateTime.now(),
          durationDays: 10,
        ),
        MedicationTime(
          medicationTimeId: 'MT003',
          userId: 'USER123',
          medicationName: 'أوميبرازول',
          amount: '20mg',
          timePerDay: 1,
          firstDoseTime: '07:00',
          startDate: DateTime.now(),
          durationDays: 10,
        ),
      ],
    ),
  ];

  void _editTreatmentPlan(int index) async {
    String input = _treatmentPlans[index].description;
    final newPlan = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل ${_treatmentPlans[index].name}'),
          content: TextField(
            onChanged: (value) => input = value,
            controller: TextEditingController(text: input),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (newPlan != null && newPlan.trim().isNotEmpty) {
      setState(() {
        _treatmentPlans[index].description = newPlan;
      });
    }
  }

  void _editMedication(MedicationTime medication,
      {required int planIndex}) async {
    String amount = medication.amount;
    int timesPerDay = medication.timePerDay;

    final result = await showDialog<MedicationTime>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل ${medication.medicationName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'الجرعة'),
                controller: TextEditingController(text: amount),
                onChanged: (val) => amount = val,
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'مرات الاستخدام يومياً'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: timesPerDay.toString()),
                onChanged: (val) =>
                    timesPerDay = int.tryParse(val) ?? timesPerDay,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  medication.copyWith(
                    amount: amount,
                    timePerDay: timesPerDay,
                  ),
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        final index = _treatmentPlans[planIndex].medications.indexWhere(
            (m) => m.medicationTimeId == medication.medicationTimeId);
        if (index != -1) {
          _treatmentPlans[planIndex].medications[index] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسار العلاجي', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTreatmentPathway(),
            ),
          );
        },
        child: const Icon(MyFlutterApp.add, size: 24),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: _treatmentPlans.length,
          itemBuilder: (context, index) {
            final plan = _treatmentPlans[index];
            return _buildTreatmentPlanCard(theme, plan, index);
          },
        ),
      ),
    );
  }

  Widget _buildTreatmentPlanCard(
      ThemeData theme, TreatmentPlan plan, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.healing, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    plan.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note, size: 20),
                  onPressed: () => _editTreatmentPlan(index),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              plan.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plan.medications.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7, // تم تعديل هذه النسبة
              ),
              itemBuilder: (context, medIndex) {
                final med = plan.medications[medIndex];
                return MedicationItem(
                  medication: med,
                  theme: theme,
                  onEdit: () {
                    _editMedication(med, planIndex: medIndex);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(MedicationTime medication, ThemeData theme,
      {required int planIndex}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        width: 180, // عرض ثابت
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة التعديل في الزاوية
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: theme.colorScheme.primary,
                onPressed: () =>
                    _editMedication(medication, planIndex: planIndex),
              ),
            ),
            Center(
              child: Icon(
                MyFlutterApp.noun_medicine_7230298,
                color: medication.isActive ? Colors.green : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(height: 6.0),
            Center(
              child: Text(
                medication.medicationName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8.0),
            Divider(height: 1, thickness: 1, color: Colors.grey[400]),
            const SizedBox(height: 6.0),
            _buildInfoRow('الجرعة:', medication.amount, theme),
            const SizedBox(height: 6.0),
            Divider(height: 1, thickness: 1, color: Colors.grey[400]),
            const SizedBox(height: 6.0),
            Center(
              child: Text(
                '${medication.timePerDay} مرات يومياً',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Divider(height: 1, thickness: 1, color: Colors.grey[400]),
            const SizedBox(height: 6.0),
            _buildInfoRow('المدة:', '${medication.durationDays} يوم', theme),
          ],
        ),
      ),
    );
  }

// دالة مساعدة لعناصر المعلومات
  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}
