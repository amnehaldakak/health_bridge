import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/providers/patient_cases_provider.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/providers/patient_state_provider.dart';
import 'package:intl/intl.dart' as ui;
import 'treatment_pathway.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/providers/communities_page_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    Future.microtask(() {
      ref.read(communitiesPageProvider).fetchCommunities();
    });
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
    final loc = AppLocalizations.of(context);

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
        SnackBar(
            content: Text(loc!.get('state_updated_success')),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${loc!.get('failed_update_state')}: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  // 🟢 تأكيد المشاركة
  Future<void> _confirmAndShareCase(
      int caseId, int communityId, String communityName) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool includeTreatment = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("مشاركة الحالة"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(labelText: "عنوان المشاركة"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      decoration:
                          const InputDecoration(labelText: "محتوى المشاركة"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text("مشاركة مع المسار العلاجي"),
                      value: includeTreatment,
                      onChanged: (val) {
                        setState(() {
                          includeTreatment = val ?? false;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("مشاركة"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final title = titleController.text.trim();
      final content = contentController.text.trim();

      if (title.isEmpty || content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى إدخال عنوان ومحتوى")),
        );
        return;
      }

      await ref.read(communitiesPageProvider).shareMedicalCase(
            caseId: caseId,
            communityId: communityId,
            title: title,
            content: content,
            includeTreatmentPlan: includeTreatment,
          );

      final provider = ref.read(communitiesPageProvider);

      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: ${provider.errorMessage}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تمت مشاركة الحالة مع $communityName")),
        );
      }
    }
  }

  // 🟢 اختيار المجتمع من BottomSheet
  // 🟢 اختيار المجتمع من BottomSheet (المجتمعات الخاصة فقط)
  Future<void> _shareCase() async {
    final communitiesProvider = ref.read(communitiesPageProvider);

    // جلب فقط المجتمعات الخاصة والمنضم إليها
    final privateCommunities = communitiesProvider.communities
        .where((c) =>
            c['is_member'] == true &&
            (c['type'] == 'private' || c['is_private'] == true))
        .toList();

    if (privateCommunities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد مجتمعات خاصة منضم إليها')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // عشان نقدر نحط خلفية للـ container
      builder: (context) {
        return Container(
          height: 220,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Colors.grey.shade300, width: 1.5), // 🟢 الحد
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "اختر المجتمع للمشاركة",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: privateCommunities.map((community) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _confirmAndShareCase(
                          widget.patientCase.id!,
                          community['id'],
                          community['name'],
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        elevation: 2,
                        child: SizedBox(
                          width: 140,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage: community['image'] != null
                                    ? NetworkImage(community['image'])
                                    : null,
                                child: community['image'] == null
                                    ? const Icon(Icons.group, size: 35)
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                community['name'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String role = ref.watch(currentUserProvider)!.role;
    final loc = AppLocalizations.of(context);
    final localeCode = loc!.locale.languageCode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.get('case_details')),
          centerTitle: true,
          actions: [
            if (role == "doctor")
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareCase,
              ),
            if (role == "doctor")
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
              _buildCaseInfoCard(loc, localeCode),
              _buildSectionCard(
                  loc.get('clinical_history'),
                  Icons.history_edu,
                  [
                    _buildEditableField(
                        loc.get('main_complaint'), "chiefComplaint", loc),
                    _buildEditableField(loc.get('symptoms'), "symptoms", loc),
                    _buildEditableField(
                        loc.get('medical_history'), "pastMedical", loc),
                    _buildEditableField(
                        loc.get('surgical_history'), "pastSurgical", loc),
                    _buildEditableField(
                        loc.get('medication_history'), "medications", loc),
                    _buildEditableField(loc.get('allergies'), "allergies", loc),
                    _buildEditableField(loc.get('smoking'), "smoking", loc),
                  ],
                  loc),
              _buildSectionCard(
                  loc.get('clinical_examination'),
                  MyFlutterApp.history,
                  [
                    _buildEditableField(loc.get('signs'), "signs", loc),
                    _buildEditableField(loc.get('vital_signs'), "vitals", loc),
                    _buildEditableField(
                        loc.get('exam_results'), "examResult", loc),
                  ],
                  loc),
              _buildSectionCard(
                  loc.get('diagnosis'),
                  Icons.medical_information,
                  [
                    _buildEditableField(loc.get('diagnosis'), "diagnosis", loc),
                  ],
                  loc),
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
          label: Text(loc.get('treatment_pathway')),
          icon: const Icon(Icons.timeline),
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }

  Widget _buildCaseInfoCard(AppLocalizations loc, String localeCode) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.get('case_info'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: blue1),
              title: Text(
                  '${loc.get('creation_date')}: ${_formatDate(widget.patientCase.createdAt, loc, localeCode)}'),
            ),
            ListTile(
              leading: const Icon(Icons.update, color: blue1),
              title: Text(
                  '${loc.get('last_update')}: ${_formatDate(widget.patientCase.updatedAt, loc, localeCode)}'),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: blue1),
              title:
                  Text('${loc.get('case_number')}: ${widget.patientCase.id}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      String title, IconData icon, List<Widget> items, AppLocalizations loc) {
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

  Widget _buildEditableField(String label, String key, AppLocalizations loc) {
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
                  ? loc.get('not_specified')
                  : _controllers[key]!.text),
            ),
    );
  }

  String _formatDate(String? dateStr, AppLocalizations loc, String localeCode) {
    if (dateStr == null) return loc.get('unknown');
    try {
      final date = DateTime.parse(dateStr);
      final formattedDate =
          ui.DateFormat('yyyy-MM-dd – HH:mm', localeCode).format(date);
      final relative = timeago.format(date, locale: localeCode);
      return '$formattedDate ($relative)';
    } catch (e) {
      return loc.get('unknown');
    }
  }
}
