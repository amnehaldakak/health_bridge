import 'package:flutter/material.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'treatment_pathway.dart';

/// Patient state page that displays comprehensive medical information
/// including clinical history, examination results, diagnosis, and treatment plan.
/// Supports Arabic RTL text direction for medical documentation.
class PatientState extends StatefulWidget {
  const PatientState({Key? key}) : super(key: key);

  @override
  State<PatientState> createState() => _PatientStateState();
}

class _PatientStateState extends State<PatientState> {
  bool _isEditing = false;
  late Map<String, String> _patientData;
  late Map<String, TextEditingController> _controllers;
  List<String> _medications = [];

  @override
  void initState() {
    super.initState();
    _patientData = _getMockPatientData();
    _initializeControllers();
    _initializeMedications();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  /// Initialize text editing controllers for all editable fields
  void _initializeControllers() {
    _controllers = {};
    for (String key in _patientData.keys) {
      if (key != 'medicationPlan') {
        // Exclude medicationPlan as it's handled separately
        _controllers[key] = TextEditingController(text: _patientData[key]);
      }
    }
  }

  /// Initialize medications list from the medication plan
  void _initializeMedications() {
    String medicationPlan = _patientData['medicationPlan'] ?? '';
    _medications = medicationPlan
        .split('،')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Dispose all text editing controllers
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

  /// Builds the app bar with patient state title and edit button
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('حالة المريض'),
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

  /// Toggles between view and edit modes
  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _saveChanges();
      }
      _isEditing = !_isEditing;
    });
  }

  /// Saves the changes made in edit mode
  void _saveChanges() {
    try {
      // Update patient data with controller values
      for (String key in _controllers.keys) {
        _patientData[key] = _controllers[key]!.text.trim();
      }

      // Update medication plan from medications list
      _patientData['medicationPlan'] = _medications.join('، ');

      _showSuccessSnackBar('تم حفظ التغييرات بنجاح');
    } catch (e) {
      _showErrorSnackBar('فشل في حفظ التغييرات');
    }
  }

  /// Shows success snack bar with Arabic text
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Builds the main body content with patient information sections
  Widget _buildBody(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(PatientStateConstants.padding),
          child: Column(
            children: [
              _buildClinicalHistorySection(context),
              _buildClinicalExaminationSection(context),
              _buildDiagnosisSection(context),
              // _buildTreatmentPlanSection(context),
              // _buildMedicationsSection(context),
              const SizedBox(height: PatientStateConstants.buttonSpacing),

              // Add extra padding for floating button
              const SizedBox(height: 80.0),
            ],
          ),
        ),
        // Floating action button for treatment pathway navigation
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: _buildTreatmentPathwayButton(context, theme),
        ),
      ],
    );
  }

  /// Builds the clinical history section card
  Widget _buildClinicalHistorySection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: PatientStateConstants.clinicalHistoryTitle,
      icon: Icons.history_edu,
      items: [
        Row(
          children: [
            Icon(
              Icons.watch_later_outlined,
              color: blue1,
            ),
            Text(DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now()))
          ],
        ),
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

  /// Builds the clinical examination section card
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

  /// Builds the diagnosis section card
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

  /// Builds the treatment plan section card
  Widget _buildTreatmentPlanSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: PatientStateConstants.treatmentPlanTitle,
      icon: Icons.healing,
      items: [
        _buildEditableTile(
            PatientStateConstants.treatmentPlanLabel, 'treatmentPlan'),
      ],
    );
  }

  /// Builds the medications section card
  Widget _buildMedicationsSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: PatientStateConstants.medicationsTitle,
      icon: Icons.medication,
      items: [
        if (_isEditing)
          _buildMedicationsEditSection()
        else
          _buildMedicationsViewSection(),
      ],
    );
  }

  /// Builds the medications view section
  Widget _buildMedicationsViewSection() {
    if (_medications.isEmpty) {
      return ListTile(
        title: Text(
          PatientStateConstants.noMedicationsText,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: _medications
          .map((medication) => ListTile(
                leading: const Icon(Icons.medication, color: Colors.blue),
                title: Text(medication),
                dense: true,
              ))
          .toList(),
    );
  }

  /// Builds the medications edit section
  Widget _buildMedicationsEditSection() {
    return Column(
      children: [
        // Display existing medications
        ..._medications.asMap().entries.map((entry) {
          int index = entry.key;
          String medication = entry.value;
          return _buildMedicationEditTile(index, medication);
        }).toList(),

        // Add new medication button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _addNewMedication,
            icon: const Icon(Icons.add),
            label: Text(PatientStateConstants.addMedicationText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds an individual medication edit tile
  Widget _buildMedicationEditTile(int index, String medication) {
    final controller = TextEditingController(text: medication);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: PatientStateConstants.medicationHintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                if (index < _medications.length) {
                  _medications[index] = value;
                }
              },
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: () => _removeMedication(index),
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: PatientStateConstants.removeMedicationText,
          ),
        ],
      ),
    );
  }

  /// Adds a new medication to the list
  void _addNewMedication() {
    setState(() {
      _medications.add('');
    });
  }

  /// Removes a medication from the list
  void _removeMedication(int index) {
    setState(() {
      if (index < _medications.length) {
        _medications.removeAt(index);
      }
    });
  }

  /// Builds an editable tile that can switch between view and edit modes
  Widget _buildEditableTile(String label, String dataKey) {
    if (_isEditing) {
      return _buildEditableField(label, dataKey);
    } else {
      return _buildReadOnlyTile(label, _patientData[dataKey]);
    }
  }

  /// Builds an editable text field for edit mode
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
            maxLines:
                dataKey == 'symptoms' || dataKey == 'treatmentPlan' ? 3 : 1,
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

  /// Builds a read-only tile for view mode
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

  /// Shows error snack bar with Arabic text
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Builds the floating treatment pathway navigation button
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

  /// Navigates to the treatment pathway page
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

  /// Builds a section card with title, icon, and content items
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

  /// Builds the section header with icon and title
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

  /// Gets the display value or default text for empty values
  String _getDisplayValue(String? value) {
    return (value != null && value.trim().isNotEmpty)
        ? value
        : PatientStateConstants.undefinedText;
  }

  /// Returns mock patient data for demonstration purposes
  Map<String, String> _getMockPatientData() {
    return {
      'chiefComplaint': 'ألم في البطن منذ 3 أيام',
      'symptoms': 'غثيان، إقياء، حرارة خفيفة',
      'pastMedical': 'سكري من النوع الثاني',
      'pastSurgical': 'استئصال زائدة دودية قبل 5 سنوات',
      'medications': 'ميتفورمين 500mg مرتين يوميًا',
      'allergies': 'تحسس من البنسلين',
      'smoking': 'لا',
      'signs': 'ألم بالجس في الربع السفلي الأيمن',
      'vitals': 'الحرارة 37.8، الضغط 120/80، النبض 90',
      'examResult': 'ألم موضعي + علامة بلومبرغ إيجابية',
      'diagnosis': 'التهاب زائدة دودية',
      'treatmentPlan': 'مضاد حيوي + تحضير لجراحة',
      'medicationPlan': 'مضاد حيوي + تحضير لجراحة',
    };
  }
}

/// Constants for the PatientState widget
class PatientStateConstants {
  // Layout constants
  static const double padding = 16.0;
  static const double cardMargin = 8.0;
  static const double cardPadding = 12.0;
  static const double cardElevation = 3.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonSpacing = 20.0;
  static const double buttonHorizontalPadding = 24.0;
  static const double buttonVerticalPadding = 12.0;

  // Typography constants
  static const double buttonFontSize = 16.0;
  static const double subtitleFontSize = 15.0;

  // Arabic text constants
  static const String clinicalHistoryTitle = 'القصة السريرية';
  static const String clinicalExaminationTitle = 'الفحص السريري';
  static const String diagnosisTitle = 'التشخيص';
  static const String treatmentPlanTitle = 'الخطة العلاجية';
  static const String medicationsTitle = 'الأدوية الموصوفة';

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
  static const String treatmentPlanLabel = 'الخطة العلاجية';
  static const String medicationPlanLabel = 'الأدوية الموصوفة';

  // Medication section constants
  static const String addMedicationText = 'إضافة دواء جديد';
  static const String removeMedicationText = 'حذف الدواء';
  static const String medicationHintText = 'أدخل اسم الدواء والجرعة';
  static const String noMedicationsText = 'لا توجد أدوية موصوفة';

  static const String backButtonText = 'عودة';
  static const String undefinedText = 'غير محدد';

  // Treatment pathway navigation constants
  static const String treatmentPathwayButtonText = 'المسار العلاجي';
  static const double floatingButtonBorderRadius = 16.0;
}
