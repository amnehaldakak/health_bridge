import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'treatment_pathway.dart';

class PatientState extends StatefulWidget {
  final Case patientCase;

  const PatientState({Key? key, required this.patientCase}) : super(key: key);

  @override
  State<PatientState> createState() => _PatientStateState();
}

class _PatientStateState extends State<PatientState> {
  bool _isEditing = false;
  late Map<String, String> _patientData;
  late Map<String, TextEditingController> _controllers;
  List<String> _medications = [];
  File? _echoFile;
  File? _labTestFile;

  @override
  void initState() {
    super.initState();
    _patientData = _getDynamicPatientData();
    _initializeControllers();
    _initializeMedications();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  Map<String, String> _getDynamicPatientData() {
    return {
      'chiefComplaint': widget.patientCase.chiefComplaint ?? '',
      'symptoms': widget.patientCase.symptoms ?? '',
      'pastMedical': widget.patientCase.medicalHistory ?? '',
      'pastSurgical': widget.patientCase.surgicalHistory ?? '',
      'medications': widget.patientCase.allergicHistory ?? '',
      'allergies': widget.patientCase.allergicHistory ?? '',
      'smoking': widget.patientCase.smokingStatus ?? '',
      'signs': widget.patientCase.signs ?? '',
      'vitals': widget.patientCase.vitalSigns ?? '',
      'examResult': widget.patientCase.clinicalExaminationResults ?? '',
      'diagnosis': widget.patientCase.diagnosis ?? '',
      'treatmentPlan': widget.patientCase.diagnosis ?? '',
      'medicationPlan': widget.patientCase.diagnosis ?? '',
    };
  }

  void _initializeControllers() {
    _controllers = {};
    for (String key in _patientData.keys) {
      if (key != 'medicationPlan') {
        _controllers[key] = TextEditingController(text: _patientData[key]);
      }
    }
  }

  void _initializeMedications() {
    String medicationPlan = _patientData['medicationPlan'] ?? '';
    _medications = medicationPlan
        .split('،')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _disposeControllers() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(theme),
        body: _buildBody(context, theme),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('تفاصيل الحالة'),
      centerTitle: true,
      backgroundColor: theme.appBarTheme.backgroundColor,
      actions: [
        IconButton(
          onPressed: _toggleEditMode,
          icon: Icon(_isEditing ? Icons.save : Icons.edit),
          tooltip: _isEditing ? 'حفظ التغييرات' : 'تعديل الحالة',
        ),
      ],
    );
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _saveChanges();
      } else {
        _isEditing = !_isEditing;
      }
    });
  }

  Future<void> _saveChanges() async {
    try {
      // تحديث البيانات المحلية أولاً
      for (String key in _controllers.keys) {
        _patientData[key] = _controllers[key]!.text.trim();
      }

      _patientData['medicationPlan'] = _medications.join('، ');

      // إرسال التحديثات إلى السيرفر
      final response = await ApiService.updateMedicalCase(
        caseId: widget.patientCase.id!,
        chiefComplaint: _controllers['chiefComplaint']!.text,
        symptoms: _controllers['symptoms']!.text,
        medicalHistory: _controllers['pastMedical']!.text,
        surgicalHistory: _controllers['pastSurgical']!.text,
        allergicHistory: _controllers['allergies']!.text,
        smokingStatus: _controllers['smoking']!.text,
        signs: _controllers['signs']!.text,
        vitalSigns: _controllers['vitals']!.text,
        clinicalExaminationResults: _controllers['examResult']!.text,
        diagnosis: _controllers['diagnosis']!.text,
        echo: _echoFile,
        labTest: _labTestFile,
      );

      // معالجة الاستجابة
      final httpResponse = await http.Response.fromStream(response);
      final responseBody = json.decode(httpResponse.body);

      if (response.statusCode == 200) {
        _showSuccessSnackBar('تم تحديث الحالة بنجاح');

        setState(() {
          _isEditing = false;
        });
      } else if (response.statusCode == 403) {
        _showErrorSnackBar('غير مصرح لك بتعديل هذه الحالة');
      } else {
        _showErrorSnackBar('فشل في تحديث الحالة: ${responseBody['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('فشل في حفظ التغييرات: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(PatientStateConstants.padding),
          child: Column(
            children: [
              _buildCaseInfoSection(context),
              _buildClinicalHistorySection(context),
              _buildClinicalExaminationSection(context),
              _buildDiagnosisSection(context),
              const SizedBox(height: PatientStateConstants.buttonSpacing),
              const SizedBox(height: 80.0),
            ],
          ),
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: _buildTreatmentPathwayButton(context, theme),
        ),
      ],
    );
  }

  Widget _buildCaseInfoSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: PatientStateConstants.cardMargin),
      elevation: PatientStateConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(PatientStateConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PatientStateConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات الحالة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.calendar_today, color: blue1),
              title: Text(
                  'تاريخ الإنشاء: ${_formatDate(widget.patientCase.createdAt)}'),
            ),
            ListTile(
              leading: Icon(Icons.update, color: blue1),
              title: Text(
                  'آخر تحديث: ${_formatDate(widget.patientCase.updatedAt)}'),
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: blue1),
              title: Text('رقم الحالة: ${widget.patientCase.id}'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "غير معروف";

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd – HH:mm').format(date);
    } catch (e) {
      return "غير معروف";
    }
  }

  Widget _buildClinicalHistorySection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: PatientStateConstants.clinicalHistoryTitle,
      icon: Icons.history_edu,
      items: [
        _buildEditableTile(
            PatientStateConstants.chiefComplaintLabel, 'chiefComplaint'),
        _buildEditableTile(PatientStateConstants.symptomsLabel, 'symptoms'),
        _buildEditableTile(
            PatientStateConstants.pastMedicalLabel, 'pastMedical'),
        _buildEditableTile(
            PatientStateConstants.pastSurgicalLabel, 'pastSurgical'),
        _buildEditableTile(
            PatientStateConstants.medicationsLabel, 'medications'),
        _buildEditableTile(PatientStateConstants.allergiesLabel, 'allergies'),
        _buildEditableTile(PatientStateConstants.smokingLabel, 'smoking'),
      ],
    );
  }

  Widget _buildClinicalExaminationSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: PatientStateConstants.clinicalExaminationTitle,
      icon: MyFlutterApp.history,
      items: [
        _buildEditableTile(PatientStateConstants.signsLabel, 'signs'),
        _buildEditableTile(PatientStateConstants.vitalsLabel, 'vitals'),
        _buildEditableTile(PatientStateConstants.examResultLabel, 'examResult'),
      ],
    );
  }

  Widget _buildDiagnosisSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: PatientStateConstants.diagnosisTitle,
      icon: Icons.medical_information,
      items: [
        _buildEditableTile(PatientStateConstants.diagnosisLabel, 'diagnosis'),
      ],
    );
  }

  Widget _buildEditableTile(String label, String dataKey) {
    if (_isEditing) {
      return _buildEditableField(label, dataKey);
    } else {
      return _buildReadOnlyTile(label, _patientData[dataKey]);
    }
  }

  Widget _buildEditableField(String label, String dataKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _controllers[dataKey],
            maxLines: dataKey == 'symptoms' ? 3 : 1,
            decoration: InputDecoration(
              hintText: 'أدخل $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildReadOnlyTile(String label, String? value) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _getDisplayValue(value),
        style:
            const TextStyle(fontSize: PatientStateConstants.subtitleFontSize),
      ),
    );
  }

  Widget _buildTreatmentPathwayButton(BuildContext context, ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToTreatmentPathway(context),
      icon: const Icon(Icons.timeline),
      label: const Text(PatientStateConstants.treatmentPathwayButtonText),
      backgroundColor: theme.colorScheme.secondary,
      foregroundColor: theme.colorScheme.onSecondary,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            PatientStateConstants.floatingButtonBorderRadius),
      ),
    );
  }

  void _navigateToTreatmentPathway(BuildContext context) {
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TreatmentPathway(),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('فشل في الانتقال إلى صفحة المسار العلاجي');
    }
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: PatientStateConstants.cardMargin),
      elevation: PatientStateConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(PatientStateConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PatientStateConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(theme, color, icon, title),
            const Divider(),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      ThemeData theme, Color color, IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _getDisplayValue(String? value) {
    return (value != null && value.trim().isNotEmpty)
        ? value
        : PatientStateConstants.undefinedText;
  }
}

class PatientStateConstants {
  static const double padding = 16.0;
  static const double cardMargin = 8.0;
  static const double cardPadding = 12.0;
  static const double cardElevation = 3.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonSpacing = 20.0;
  static const double subtitleFontSize = 15.0;
  static const double floatingButtonBorderRadius = 16.0;

  static const String clinicalHistoryTitle = 'القصة السريرية';
  static const String clinicalExaminationTitle = 'الفحص السريري';
  static const String diagnosisTitle = 'التشخيص';

  static const String chiefComplaintLabel = 'الشكاية الرئيسية';
  static const String symptomsLabel = 'الأعراض';
  static const String pastMedicalLabel = 'السوابق المرضية';
  static const String pastSurgicalLabel = 'السوابق الجراحية';
  static const String medicationsLabel = 'السوابق الدوائية';
  static const String allergiesLabel = 'التحسس';
  static const String smokingLabel = 'التدخين';
  static const String signsLabel = 'العلامات';
  static const String vitalsLabel = 'العلامات الحيوية';
  static const String examResultLabel = 'نتيجة الفحص السريري';
  static const String diagnosisLabel = 'التشخيص';

  static const String treatmentPathwayButtonText = 'المسار العلاجي';
  static const String undefinedText = 'غير محدد';
}
