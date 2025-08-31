import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';

// =================== Patient Cases Provider ===================
final patientCasesProvider =
    StateNotifierProvider.family<PatientCasesController, AsyncValue<List<Case>>, PatientModel>(
  (ref, patient) {
    final api = ref.watch(apiServiceProvider);
    return PatientCasesController(api: api, patient: patient);
  },
);

class PatientCasesController extends StateNotifier<AsyncValue<List<Case>>> {
  final ApiService api;
  final PatientModel patient;

  PatientCasesController({required this.api, required this.patient})
      : super(const AsyncValue.loading()) {
    fetchCases();
  }

  Future<void> fetchCases() async {
    try {
      state = const AsyncValue.loading();
      final prefs = await api.prefs; // أو استخدم prefs إذا ApiService يحملها
      final userRole = prefs.getString('user_role');
      final cases = await api.getPatientCasesByRole(userRole, patient.id);
      state = AsyncValue.data(cases);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshCases() async {
    await fetchCases();
  }

  Future<bool> checkApproval() async {
    try {
      final pending = await api.getPendingApprovals();
      final hasPending = pending.any((approval) =>
          approval['patient_id'] == patient.id &&
          approval['status'] == 'pending');
      return !hasPending;
    } catch (_) {
      return false;
    }
  }
}
