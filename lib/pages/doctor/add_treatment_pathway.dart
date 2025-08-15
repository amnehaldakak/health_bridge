import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/content/buildMedicationItem.dart';
import 'package:health_bridge/config/content/build_section_title.dart';
import 'package:health_bridge/pages/add_medicine.dart';
import 'package:health_bridge/providers/medicine_add_provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class AddTreatmentPathway extends ConsumerStatefulWidget {
  const AddTreatmentPathway({super.key});

  @override
  ConsumerState<AddTreatmentPathway> createState() =>
      _AddTreatmentPlanPageState();
}

class _AddTreatmentPlanPageState extends ConsumerState<AddTreatmentPathway> {
  final TextEditingController treatmentNameController = TextEditingController();

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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: medicines.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.7,
                  ),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تم حفظ المسار العلاجي بنجاح')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('حفظ المسار العلاجي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
