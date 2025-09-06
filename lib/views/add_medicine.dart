import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/build_section_title.dart';
import 'package:health_bridge/config/content/convert_time.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/providers/medicine_add_provider.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:intl/intl.dart';

class AddMedicinePage extends ConsumerStatefulWidget {
  const AddMedicinePage({super.key});

  @override
  ConsumerState<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends ConsumerState<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController medicineName = TextEditingController();
  final TextEditingController dosageAmount = TextEditingController();

  int selectedRepetition = 1; // عدد المرات
  TimeOfDay? selectedTime; // وقت الجرعة الأولى (للمريض فقط)
  DateTime? selectedStartDate; // تاريخ البدء (للمريض فقط)
  String selectedDurationDays = '1'; // عدد الأيام

  final List<int> repetitions = [1, 2, 3, 4, 5];
  final List<String> durations = List.generate(30, (i) => '${i + 1}');

  void _pickTime(BuildContext context) async {
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        selectedStartDate = date;
      });
    }
  }

  void _saveMedicine() async {
    if (_formKey.currentState?.validate() != true) return;

    final user = ref.read(currentUserProvider);
    final loc = AppLocalizations.of(context);

    if (user?.role == 'patient') {
      // ✅ المريض لازم يختار وقت وتاريخ
      if (selectedTime == null || selectedStartDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc!.get('select_time_date'))),
        );
        return;
      }

      final firstDose =
          "${convertTime(selectedTime!.hour.toString())}:${convertTime(selectedTime!.minute.toString())}";

      try {
        final apiService = ref.read(apiServiceProvider);

        await apiService.storePatientMedication(
          name: medicineName.text,
          dosage: dosageAmount.text,
          frequency: selectedRepetition,
          duration: int.parse(selectedDurationDays),
          startDate: DateFormat('yyyy-MM-dd').format(selectedStartDate!),
          firstDoseTime: firstDose,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc!.get('medicine_saved_success'))),
        );

        context.goNamed('home_patient');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc!.get('save_medicine_failed')}: $e')),
        );
      }
    } else if (user?.role == 'doctor') {
      // ✅ الطبيب يضيف الدواء للقائمة فقط
      ref.read(treatmentPlanProvider.notifier).addMedicine(
            MedicationTime(
                name: medicineName.text,
                dosage: dosageAmount.text,
                frequency: selectedRepetition,
                firstDoseTime: "", // الطبيب ما يحدد وقت
                startDate: DateTime.now(), // تاريخ افتراضي
                duration: int.parse(selectedDurationDays),
                medicationId: null),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc!.get('medicine_added_to_list'))),
      );

      Navigator.pop(context); // ✅ يرجع للصفحة السابقة
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(currentUserProvider);
    final isPatient = user?.role == 'patient';
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc!.get('add_medicine')),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildSectionTitle(loc.get('medicine_name'), theme),
            TextFormField(
              controller: medicineName,
              validator: (val) =>
                  val == null || val.isEmpty ? loc.get('required') : null,
              decoration: InputDecoration(
                hintText: loc.get('example_amoxicillin'),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            buildSectionTitle(loc.get('dosage'), theme),
            TextFormField(
              controller: dosageAmount,
              validator: (val) =>
                  val == null || val.isEmpty ? loc.get('required') : null,
              decoration: InputDecoration(
                hintText: loc.get('example_500mg'),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            buildSectionTitle(loc.get('daily_usage_times'), theme),
            DropdownButtonFormField<int>(
              value: selectedRepetition,
              onChanged: (val) => setState(() => selectedRepetition = val!),
              items: repetitions
                  .map((e) => DropdownMenuItem(
                      value: e, child: Text('${loc.get('times')} $e')))
                  .toList(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
            ),

            // ✅ يظهر فقط للمريض
            if (isPatient) ...[
              const SizedBox(height: 16),
              buildSectionTitle(loc.get('first_dose_time'), theme),
              ElevatedButton.icon(
                onPressed: () => _pickTime(context),
                icon: const Icon(MyFlutterApp.clock),
                label: Text(selectedTime == null
                    ? loc.get('select_time')
                    : "${convertTime(selectedTime!.hour.toString())}:${convertTime(selectedTime!.minute.toString())}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              buildSectionTitle(loc.get('start_date'), theme),
              ElevatedButton.icon(
                onPressed: () => _pickDate(context),
                icon: const Icon(MyFlutterApp.calendar),
                label: Text(selectedStartDate == null
                    ? loc.get('select_date')
                    : DateFormat('y/M/d').format(selectedStartDate!)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],

            const SizedBox(height: 16),
            buildSectionTitle(loc.get('usage_days_count'), theme),
            DropdownButtonFormField<String>(
              value: selectedDurationDays,
              onChanged: (val) => setState(() => selectedDurationDays = val!),
              items: durations
                  .map((e) => DropdownMenuItem(
                      value: e, child: Text('${loc.get('day')} $e')))
                  .toList(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveMedicine,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(loc.get('save_medicine')),
            ),
          ],
        ),
      ),
    );
  }
}
