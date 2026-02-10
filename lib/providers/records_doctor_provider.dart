import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';

// Provider لإدارة قائمة المرضى للطبيب
final doctorPatientsProvider = StateNotifierProvider<DoctorPatientsController,
    AsyncValue<List<PatientModel>>>(
  (ref) => DoctorPatientsController(ref),
);

class DoctorPatientsController
    extends StateNotifier<AsyncValue<List<PatientModel>>> {
  final Ref ref;

  DoctorPatientsController(this.ref) : super(const AsyncValue.loading()) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    try {
      final api = ref.read(apiServiceProvider);
      final patients = await api.getDoctorPatients();
      state = AsyncValue.data(patients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshPatients() async {
    state = const AsyncValue.loading();
    await loadPatients();
  }
}
