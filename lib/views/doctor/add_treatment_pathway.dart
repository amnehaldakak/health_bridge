import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/content/buildMedicationItem.dart';
import 'package:health_bridge/config/content/build_section_title.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/views/add_medicine.dart';
import 'package:health_bridge/providers/medicine_add_provider.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'dart:ui' as ui;

class AddTreatmentPathway extends ConsumerStatefulWidget {
  final int caseId;
  const AddTreatmentPathway({super.key, required this.caseId});

  @override
  ConsumerState<AddTreatmentPathway> createState() =>
      _AddTreatmentPlanPageState();
}

class _AddTreatmentPlanPageState extends ConsumerState<AddTreatmentPathway> {
  final TextEditingController treatmentNameController = TextEditingController();

  bool isLoading = false;

  void _saveMedicationGroup() async {
    final medicines = ref.read(medicineListProvider);

    // تحويل قائمة MedicationTime إلى List<Map>
    final medsData = medicines
        .map((med) => {
              "name": med.medicationName,
              "dosage": med.amount,
              "frequency": med.timePerDay,
              "duration": med.durationDays,
            })
        .toList();

    final apiService = ref.read(apiServiceProvider);

    final response = await apiService.storeMedicationGroupForDoctor(
      caseId: widget.caseId,
      medications: medsData,
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الأدوية بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حفظ الأدوية: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicines = ref.watch(medicineListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مسار علاجي'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionTitle('اسم الخطة العلاجية', theme),
              const SizedBox(height: 20),
              TextField(
                controller: treatmentNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'أدخل اسم الخطة العلاجية',
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddMedicinePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة دواء'),
              ),
              if (medicines.isNotEmpty) ...[
                const SizedBox(height: 20),
                buildSectionTitle('الأدوية المضافة', theme),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: medicines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final med = medicines[index];
                    return MedicationItem(
                      medication: med,
                      theme: theme,
                    );
                  },
                ),
              ] else ...[
                const SizedBox(height: 20),
                const Text('لم يتم إضافة أي دواء بعد'),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : _saveMedicationGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ المسار العلاجي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
