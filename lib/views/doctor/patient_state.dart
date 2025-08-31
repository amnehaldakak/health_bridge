import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/providers/patient_cases_provider.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/providers/patient_state_provider.dart';
import 'package:intl/intl.dart' as ui;
import 'treatment_pathway.dart';

class PatientState extends ConsumerStatefulWidget {
  final Case patientCase;

  const PatientState({Key? key, required this.patientCase}) : super(key: key);

  @override
  ConsumerState<PatientState> createState() => _PatientStateState();
}

class _PatientStateState extends ConsumerState<PatientState> {
  bool _isEditing = false;
  late Map<String, TextEditingController> _controllers;
  List<String> _medications = [];
  File? _echoFile;
  File? _labTestFile;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeMedications();
  }

  void _initializeControllers() {
    _controllers = {
      "chiefComplaint":
          TextEditingController(text: widget.patientCase.chiefComplaint),
      "symptoms": TextEditingController(text: widget.patientCase.symptoms),
      "pastMedical":
          TextEditingController(text: widget.patientCase.medicalHistory),
      "pastSurgical":
          TextEditingController(text: widget.patientCase.surgicalHistory),
      "medications":
          TextEditingController(text: widget.patientCase.allergicHistory),
      "allergies":
          TextEditingController(text: widget.patientCase.allergicHistory),
      "smoking": TextEditingController(text: widget.patientCase.smokingStatus),
      "signs": TextEditingController(text: widget.patientCase.signs),
      "vitals": TextEditingController(text: widget.patientCase.vitalSigns),
      "examResult": TextEditingController(
          text: widget.patientCase.clinicalExaminationResults),
      "diagnosis": TextEditingController(text: widget.patientCase.diagnosis),
      "medicationPlan":
          TextEditingController(text: widget.patientCase.diagnosis),
    };
  }

  void _initializeMedications() {
    String medicationPlan = _controllers["medicationPlan"]!.text;
    _medications = medicationPlan
        .split('،')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleEditMode() async {
    if (_isEditing) {
      await _saveChanges();
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    final controller =
        ref.read(patientCaseProvider(widget.patientCase).notifier);

    try {
      await controller.updateCase(
        chiefComplaint: _controllers["chiefComplaint"]!.text,
        symptoms: _controllers["symptoms"]!.text,
        medicalHistory: _controllers["pastMedical"]!.text,
        surgicalHistory: _controllers["pastSurgical"]!.text,
        allergicHistory: _controllers["allergies"]!.text,
        smokingStatus: _controllers["smoking"]!.text,
        signs: _controllers["signs"]!.text,
        vitalSigns: _controllers["vitals"]!.text,
        clinicalExaminationResults: _controllers["examResult"]!.text,
        diagnosis: _controllers["diagnosis"]!.text,
        echo: _echoFile,
        labTest: _labTestFile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("تم تحديث الحالة بنجاح"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("فشل في تحديث الحالة: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الحالة'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _toggleEditMode,
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCaseInfoCard(),
              _buildSectionCard("القصة السريرية", Icons.history_edu, [
                _buildEditableField("الشكاية الرئيسية", "chiefComplaint"),
                _buildEditableField("الأعراض", "symptoms"),
                _buildEditableField("السوابق المرضية", "pastMedical"),
                _buildEditableField("السوابق الجراحية", "pastSurgical"),
                _buildEditableField("السوابق الدوائية", "medications"),
                _buildEditableField("التحسس", "allergies"),
                _buildEditableField("التدخين", "smoking"),
              ]),
              _buildSectionCard("الفحص السريري", MyFlutterApp.history, [
                _buildEditableField("العلامات", "signs"),
                _buildEditableField("العلامات الحيوية", "vitals"),
                _buildEditableField("نتيجة الفحص السريري", "examResult"),
              ]),
              _buildSectionCard("التشخيص", Icons.medical_information, [
                _buildEditableField("التشخيص", "diagnosis"),
              ]),
              const SizedBox(height: 80),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TreatmentPathway(
                caseId: widget.patientCase.id,
              ),
            ));
          },
          label: const Text("المسار العلاجي"),
          icon: const Icon(Icons.timeline),
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }

  Widget _buildCaseInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('معلومات الحالة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: blue1),
              title: Text(
                  'تاريخ الإنشاء: ${_formatDate(widget.patientCase.createdAt)}'),
            ),
            ListTile(
              leading: const Icon(Icons.update, color: blue1),
              title: Text(
                  'آخر تحديث: ${_formatDate(widget.patientCase.updatedAt)}'),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: blue1),
              title: Text('رقم الحالة: ${widget.patientCase.id}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> items) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: theme.colorScheme.primary),
              title: Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: _isEditing
          ? TextField(
              controller: _controllers[key],
              maxLines: key == "symptoms" ? 3 : 1,
              decoration: InputDecoration(
                labelText: label,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            )
          : ListTile(
              title: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_controllers[key]!.text.isEmpty
                  ? 'غير محدد'
                  : _controllers[key]!.text),
            ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "غير معروف";
    try {
      final date = DateTime.parse(dateStr);
      return ui.DateFormat('yyyy-MM-dd – HH:mm').format(date);
    } catch (e) {
      return "غير معروف";
    }
  }
}
