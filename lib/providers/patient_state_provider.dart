import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:http/http.dart' as http;

// Provider لحفظ الحالة الحالية
final patientCaseProvider =
    StateNotifierProvider.family<PatientCaseController, AsyncValue<Case>, Case>(
  (ref, patientCase) => PatientCaseController(ref, patientCase),
);

class PatientCaseController extends StateNotifier<AsyncValue<Case>> {
  final Ref ref;
  final ApiService _api;

  PatientCaseController(this.ref, Case initialCase)
      : _api = ref.read(apiServiceProvider),
        super(AsyncValue.data(initialCase));

  Future<void> updateCase({
    String? chiefComplaint,
    String? symptoms,
    String? medicalHistory,
    String? surgicalHistory,
    String? allergicHistory,
    String? smokingStatus,
    String? signs,
    String? vitalSigns,
    String? clinicalExaminationResults,
    String? diagnosis,
    File? echo,
    File? labTest,
  }) async {
    if (state.value == null) return;

    try {
      final response = await _api.updateMedicalCase(
        caseId: state.value!.id!,
        chiefComplaint: chiefComplaint ?? state.value!.chiefComplaint ?? '',
        symptoms: symptoms ?? state.value!.symptoms ?? '',
        medicalHistory: medicalHistory ?? state.value!.medicalHistory ?? '',
        surgicalHistory: surgicalHistory ?? state.value!.surgicalHistory ?? '',
        allergicHistory: allergicHistory ?? state.value!.allergicHistory ?? '',
        smokingStatus: smokingStatus ?? state.value!.smokingStatus ?? '',
        signs: signs ?? state.value!.signs ?? '',
        vitalSigns: vitalSigns ?? state.value!.vitalSigns ?? '',
        clinicalExaminationResults: clinicalExaminationResults ??
            state.value!.clinicalExaminationResults ??
            '',
        diagnosis: diagnosis ?? state.value!.diagnosis ?? '',
        echo: echo,
        labTest: labTest,
      );

      final httpResponse = await http.Response.fromStream(response);
      if (httpResponse.statusCode == 200) {
        // تحديث الحالة محلياً بعد نجاح الطلب
        state = AsyncValue.data(
          state.value!.copyWith(
            chiefComplaint: chiefComplaint ?? state.value!.chiefComplaint,
            symptoms: symptoms ?? state.value!.symptoms,
            medicalHistory: medicalHistory ?? state.value!.medicalHistory,
            surgicalHistory: surgicalHistory ?? state.value!.surgicalHistory,
            allergicHistory: allergicHistory ?? state.value!.allergicHistory,
            smokingStatus: smokingStatus ?? state.value!.smokingStatus,
            signs: signs ?? state.value!.signs,
            vitalSigns: vitalSigns ?? state.value!.vitalSigns,
            clinicalExaminationResults: clinicalExaminationResults ??
                state.value!.clinicalExaminationResults,
            diagnosis: diagnosis ?? state.value!.diagnosis,
          ),
        );
      } else {
        final body = json.decode(httpResponse.body);
        throw Exception(body['message'] ?? 'Failed to update case');
      }
    } catch (e) {
      throw Exception('Failed to update case: $e');
    }
  }
}
