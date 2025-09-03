import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/buildMedicationItem.dart';
import 'package:health_bridge/config/content/build_section_title.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/providers/medicine_add_provider.dart';
import 'package:health_bridge/views/add_medicine.dart';
import 'package:health_bridge/service/api_service.dart';

class AddTreatmentPathway extends ConsumerStatefulWidget {
  final int caseId;
  const AddTreatmentPathway({super.key, required this.caseId});

  @override
  ConsumerState<AddTreatmentPathway> createState() =>
      _AddTreatmentPathwayState();
}

class _AddTreatmentPathwayState extends ConsumerState<AddTreatmentPathway> {
  final TextEditingController treatmentNameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // مزامنة الحقل النصي مع الوصف في الـ Provider عند الكتابة
    treatmentNameController.addListener(() {
      ref
          .read(treatmentPlanProvider.notifier)
          .setDescription(treatmentNameController.text);
    });
  }

  @override
  void dispose() {
    treatmentNameController.dispose();
    super.dispose();
  }

  void _saveMedicationGroup() async {
    final state = ref.read(treatmentPlanProvider);

    if (state.description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال وصف الخطة العلاجية')),
      );
      return;
    }

    if (state.medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم إضافة أي دواء')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);

      // تحويل الأدوية إلى List<Map>
      final medsData = state.medicines
          .map((med) => {
                "name": med.name,
                "dosage": med.dosage,
                "frequency": med.frequency,
                "duration": med.duration,
              })
          .toList();

      final response = await apiService.storeMedicationGroupForDoctor(
        caseId: widget.caseId,
        medications: medsData,
        description: state.description,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الأدوية بنجاح')),
        );

        // ✅ تفريغ قائمة الأدوية والوصف بعد الحفظ
        ref.read(treatmentPlanProvider.notifier).clear();
        treatmentNameController.clear();

        context.pop(); // الرجوع للصفحة السابقة
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حفظ الأدوية: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final treatmentPlan = ref.watch(treatmentPlanProvider);
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
              buildSectionTitle('وصف الخطة العلاجية', theme),
              const SizedBox(height: 20),
              TextField(
                controller: treatmentNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'أدخل وصف الخطة العلاجية',
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
              const SizedBox(height: 20),
              if (treatmentPlan.medicines.isNotEmpty) ...[
                buildSectionTitle('الأدوية المضافة', theme),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: treatmentPlan.medicines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final med = treatmentPlan.medicines[index];
                    return MedicationItem(
                      medication: med,
                      theme: theme,
                      onEdit: () {
                        // يمكن إضافة تعديل الدواء إذا رغبتِ
                      },
                    );
                  },
                ),
              ] else ...[
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
