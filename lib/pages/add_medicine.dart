import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/content/build_section_title.dart';
import 'package:health_bridge/config/content/convert_time.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/providers/medicine_add_provider.dart';
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

  int selectedRepetition = 1; // عدد المرات في اليوم
  TimeOfDay? selectedTime; // وقت الجرعة الأولى
  DateTime? selectedStartDate; // تاريخ البدء
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

  void _saveMedicine() {
    if (_formKey.currentState?.validate() != true) return;

    if (selectedTime == null || selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الوقت والتاريخ')),
      );
      return;
    }

    // تحويل وقت الجرعة الأولى إلى String بصيغة hh:mm
    final firstDose =
        "${convertTime(selectedTime!.hour.toString())}:${convertTime(selectedTime!.minute.toString())}";

    // إضافة الدواء إلى القائمة
    ref.read(medicineListProvider.notifier).addMedicine(
          MedicationTime(
            medicationTimeId: null, // أو قيمة ID إذا موجودة
            userId: "101",
            medicationName: medicineName.text,
            amount: dosageAmount.text,
            timePerDay: selectedRepetition,
            firstDoseTime: firstDose,
            startDate: selectedStartDate!,
            durationDays: int.parse(selectedDurationDays),
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الدواء بنجاح')),
    );
    Navigator.of(context).pop();

    // إعادة القيم للوضع الافتراضي
    medicineName.clear();
    dosageAmount.clear();
    setState(() {
      selectedTime = null;
      selectedStartDate = null;
      selectedRepetition = 1;
      selectedDurationDays = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final medicines = ref.watch(medicineListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة دواء'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildSectionTitle('اسم الدواء', theme),
            TextFormField(
              controller: medicineName,
              validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              decoration: InputDecoration(
                hintText: 'مثال: أموكسيسيلين',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            buildSectionTitle('الجرعة', theme),
            TextFormField(
              controller: dosageAmount,
              validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
              decoration: InputDecoration(
                hintText: 'مثال: 500mg',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            buildSectionTitle('عدد مرات الاستخدام يومياً', theme),
            DropdownButtonFormField<int>(
              value: selectedRepetition,
              onChanged: (val) => setState(() => selectedRepetition = val!),
              items: repetitions
                  .map(
                      (e) => DropdownMenuItem(value: e, child: Text('$e مرات')))
                  .toList(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            buildSectionTitle('وقت الجرعة الأولى', theme),
            ElevatedButton.icon(
              onPressed: () => _pickTime(context),
              icon: const Icon(MyFlutterApp.clock),
              label: Text(selectedTime == null
                  ? 'اختر الوقت'
                  : "${convertTime(selectedTime!.hour.toString())}:${convertTime(selectedTime!.minute.toString())}"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
            buildSectionTitle('تاريخ البدء', theme),
            ElevatedButton.icon(
              onPressed: () => _pickDate(context),
              icon: const Icon(MyFlutterApp.calendar),
              label: Text(selectedStartDate == null
                  ? 'اختر التاريخ'
                  : DateFormat('y/M/d').format(selectedStartDate!)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
            buildSectionTitle('عدد أيام الاستخدام', theme),
            DropdownButtonFormField<String>(
              value: selectedDurationDays,
              onChanged: (val) => setState(() => selectedDurationDays = val!),
              items: durations
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e يوم')))
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
              child: const Text('حفظ الدواء'),
            ),
          ],
        ),
      ),
    );
  }
}
