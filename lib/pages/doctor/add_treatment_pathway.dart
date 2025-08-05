import 'package:flutter/material.dart';
import 'package:health_bridge/config/content/build_section_title.dart';
import 'package:health_bridge/pages/add_medicine.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class AddTreatmentPathway extends StatefulWidget {
  const AddTreatmentPathway({super.key});

  @override
  State<AddTreatmentPathway> createState() => _AddTreatmentPlanPageState();
}

class _AddTreatmentPlanPageState extends State<AddTreatmentPathway> {
  final TextEditingController treatmentNameController = TextEditingController();
  final List<AddMedicinePage> medicationForms = [];

  @override
  void initState() {
    super.initState();
    medicationForms.add(AddMedicinePage(key: UniqueKey()));
  }

  void _addMedicationForm() {
    setState(() {
      medicationForms.add(AddMedicinePage(key: UniqueKey()));
    });
  }

  // void _saveTreatmentPlan() {
  //   if (treatmentNameController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('يرجى إدخال اسم الخطة العلاجية')),
  //     );
  //     return;
  //   }

  //   bool allValid = true;
  //   for (var form in medicationForms) {
  //     if (!form.isFormValid()) {
  //       allValid = false;
  //       break;
  //     }
  //   }

  //   if (!allValid) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('يرجى تعبئة جميع الحقول للأدوية')),
  //     );
  //     return;
  //   }

  //   // هنا يمكن حفظ الخطة في قاعدة بيانات أو إرسالها للسيرفر
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('تم حفظ المسار العلاجي بنجاح')),
  //   );
  //   treatmentNameController.clear();
  //   setState(() {
  //     medicationForms.clear();
  //     medicationForms.add(AddMedicationPage(key: UniqueKey()));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مسار علاجي'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
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
                ),
              ),
              // const SizedBox(height: 20),
              // ListView.builder(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   itemCount: medicationForms.length,
              //   itemBuilder: (_, index) => medicationForms[index],
              // ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('إضافة دواء'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {},
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
