import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:health_bridge/views/doctor/add_treatment_pathway.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class AddRecords extends ConsumerStatefulWidget {
  const AddRecords({Key? key}) : super(key: key);

  @override
  ConsumerState<AddRecords> createState() => _AddRecordsState();
}

class _AddRecordsState extends ConsumerState<AddRecords> {
  int currentStep = 0;

  final _storyKey = GlobalKey<FormState>();
  final _examKey = GlobalKey<FormState>();
  final _diagnosisKey = GlobalKey<FormState>();

  // المرضى
  List<PatientModel> allPatients = [];
  List<PatientModel> filteredPatients = [];
  bool loading = true;
  PatientModel? selectedPatient;
  final TextEditingController searchController = TextEditingController();

  // الملفات
  File? _echoFile;
  File? _labTestFile;

  // الكنترولات
  final controllers = <String, TextEditingController>{
    "chiefComplaint": TextEditingController(),
    "symptoms": TextEditingController(),
    "pastMedical": TextEditingController(),
    "pastSurgical": TextEditingController(),
    "medications": TextEditingController(),
    "allergies": TextEditingController(),
    "smoking": TextEditingController(),
    "signs": TextEditingController(),
    "vitals": TextEditingController(),
    "examResult": TextEditingController(),
    "diagnosis": TextEditingController(),
    "medicationPlan": TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => loading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final patients = await api.getDoctorPatients();
      setState(() {
        allPatients = patients;
        filteredPatients = patients;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${loc!.get('failed_load_patients')}: $e")),
      );
    }
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPatients = allPatients;
      } else {
        filteredPatients = allPatients.where((p) {
          final name = p.user.name.toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || p.id.toString().contains(q);
        }).toList();
      }
    });
  }

  void _submit() async {
    final loc = AppLocalizations.of(context);

    if (selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc!.get('select_patient_first'))),
      );
      return;
    }

    // التحقق من الحقول الإلزامية
    if (controllers["chiefComplaint"]!.text.isEmpty ||
        controllers["symptoms"]!.text.isEmpty ||
        controllers["pastMedical"]!.text.isEmpty ||
        controllers["pastSurgical"]!.text.isEmpty ||
        controllers["allergies"]!.text.isEmpty ||
        controllers["smoking"]!.text.isEmpty ||
        controllers["diagnosis"]!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc!.get('fill_required_fields'))),
      );
      return;
    }

    final api = ref.read(apiServiceProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 10),
            Text(
                "${loc!.get('sending_data_to')} ${selectedPatient!.user.name}"),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );

    try {
      final response = await api.casePatient(
        patientId: selectedPatient!.id,
        chiefComplaint: controllers["chiefComplaint"]!.text,
        symptoms: controllers["symptoms"]!.text,
        medicalHistory: controllers["pastMedical"]!.text,
        surgicalHistory: controllers["pastSurgical"]!.text,
        allergicHistory: controllers["allergies"]!.text,
        smokingStatus: controllers["smoking"]!.text,
        signs: controllers["signs"]!.text,
        vitalSigns: controllers["vitals"]!.text,
        clinicalExaminationResults: controllers["examResult"]!.text,
        diagnosis: controllers["diagnosis"]!.text,
        echo: _echoFile,
        labTest: _labTestFile,
      );

      final httpResponse = await http.Response.fromStream(response);
      final responseBody = json.decode(httpResponse.body);

      if (response.statusCode == 201) {
        final caseId = responseBody['case']['id'];
        final patientName = selectedPatient!.user.name;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc!.get('case_created_success'))),
        );
        _resetForm();
        setState(() => currentStep = 0);
        print('caseId: $caseId');

        // إعادة التوجيه إلى صفحة إضافة مسار علاجي
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddTreatmentPathway(
            caseId: caseId,
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${loc!.get('error')}: ${responseBody['message'] ?? loc.get('unknown_error')}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${loc!.get('sending_error')}: $e")),
      );
    }
  }

  void _resetForm() {
    controllers.forEach((key, controller) => controller.clear());
    setState(() {
      _echoFile = null;
      _labTestFile = null;
    });
  }

  void _onStepContinue() {
    final formKeys = [_storyKey, _examKey, _diagnosisKey];
    final isLast =
        currentStep == _steps(AppLocalizations.of(context)!).length - 1;

    if (formKeys[currentStep]!.currentState?.validate() != true) return;

    if (isLast && _diagnosisValidated()) {
      _submit();
    } else {
      setState(() => currentStep += 1);
    }
  }

  void _onStepCancel() {
    if (currentStep == 0) return;
    setState(() => currentStep -= 1);
  }

  bool _diagnosisValidated() {
    return controllers["diagnosis"]!.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc!.get('medical_form')),
          centerTitle: true,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: loc.get('search_patient_by_name_id'),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: _filterPatients,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: loc.get('select_patient'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: selectedPatient?.id,
                      items: filteredPatients.map((p) {
                        return DropdownMenuItem<int>(
                          value: p.id,
                          child: Text("${p.user.name} (ID: ${p.id})"),
                        );
                      }).toList(),
                      onChanged: (id) {
                        setState(() {
                          selectedPatient =
                              allPatients.firstWhere((p) => p.id == id);
                        });
                      },
                    ),
                  ),
                  if (selectedPatient != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${loc.get('selected_patient')}: ${selectedPatient!.user.name} (ID: ${selectedPatient!.id})",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  Expanded(
                    child: Stepper(
                      type: StepperType.vertical,
                      currentStep: currentStep,
                      onStepContinue: _onStepContinue,
                      onStepCancel: _onStepCancel,
                      steps: _steps(loc), // ✅ تم إضافة loc هنا
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Step> _steps(AppLocalizations loc) {
    return [
      Step(
        title: Text(loc.get('clinical_history')),
        isActive: currentStep >= 0,
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _storyKey,
          child: Column(
            children: [
              field(loc.get('main_complaint'), controllers["chiefComplaint"]!,
                  maxLines: 2, loc: loc),
              field(loc.get('symptoms'), controllers["symptoms"]!,
                  maxLines: 2, loc: loc),
              field(loc.get('medical_history'), controllers["pastMedical"]!,
                  maxLines: 2, loc: loc),
              field(loc.get('surgical_history'), controllers["pastSurgical"]!,
                  maxLines: 2, loc: loc),
              field(loc.get('allergies'), controllers["allergies"]!,
                  maxLines: 1, loc: loc),
              field(loc.get('smoking_status'), controllers["smoking"]!,
                  maxLines: 1, loc: loc),
              optionalField(
                  loc.get('medication_history'), controllers["medications"]!,
                  maxLines: 2, loc: loc),
              fileUploadField(
                loc.get('echo_image_optional'),
                _echoFile,
                (file) => setState(() => _echoFile = file),
                loc: loc,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: Text(loc.get('clinical_examination')),
        isActive: currentStep >= 1,
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _examKey,
          child: Column(
            children: [
              optionalField(loc.get('signs'), controllers["signs"]!,
                  maxLines: 2, loc: loc),
              optionalField(loc.get('vital_signs'), controllers["vitals"]!,
                  hint: loc.get('pressure_temp_pulse'), maxLines: 2, loc: loc),
              optionalField(loc.get('exam_results'), controllers["examResult"]!,
                  maxLines: 3, loc: loc),
              fileUploadField(
                loc.get('lab_results_optional'),
                _labTestFile,
                (file) => setState(() => _labTestFile = file),
                loc: loc,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: Text(loc.get('diagnosis')),
        isActive: currentStep >= 2,
        state: StepState.indexed,
        content: Form(
          key: _diagnosisKey,
          child: Column(
            children: [
              field(loc.get('diagnosis'), controllers["diagnosis"]!,
                  maxLines: 2, loc: loc),
              optionalField(
                  loc.get('treatment_plan'), controllers["medicationPlan"]!,
                  maxLines: 3, loc: loc),
            ],
          ),
        ),
      ),
    ];
  }

  Widget field(String label, TextEditingController controller,
      {int maxLines = 1, String? hint, required AppLocalizations loc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: const [
                TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? loc.get('fill_this_field')
            : null,
      ),
    );
  }

  Widget optionalField(String label, TextEditingController controller,
      {int maxLines = 1, String? hint, required AppLocalizations loc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget fileUploadField(
      String label, File? currentFile, Function(File?) onFileSelected,
      {required AppLocalizations loc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null && result.files.single.path != null) {
                    onFileSelected(File(result.files.single.path!));
                  }
                },
                child: Text(loc.get('choose_file')),
              ),
              const SizedBox(width: 10),
              if (currentFile != null)
                Expanded(
                  child: Text(
                    currentFile.path.split('/').last,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
