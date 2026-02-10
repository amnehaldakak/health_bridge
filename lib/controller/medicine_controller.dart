import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:health_bridge/providers/auth_provider.dart';

class MedicineController
    extends StateNotifier<AsyncValue<List<MedicationTime>>> {
  final ApiService apiService;

  MedicineController(this.apiService) : super(const AsyncValue.loading()) {
    // يحمل الأدوية مباشرة عند الإنشاء
    fetchMedicines();
  }

  DateTime selectedDate = DateTime.now();

  /// تحميل قائمة الأدوية من API
  Future<void> fetchMedicines() async {
    try {
      state = const AsyncValue.loading();
      final meds = await apiService.getMedicine();
      state = AsyncValue.data(meds);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// تغيير التاريخ المختار
  void changeDate(DateTime date) {
    selectedDate = date;
    // ما نعيد تحميل من API، فقط نفلتر محلياً
    state = AsyncValue.data(state.value ?? []);
  }

  /// إرجاع الأدوية الخاصة باليوم المختار
  List<MedicationTime> getTasksForSelectedDate() {
    final meds = state.value ?? [];
    return meds.where((med) {
      final startDate = med.startDate;
      final endDate = startDate.add(Duration(days: med.duration! - 1));
      return !selectedDate.isBefore(startDate) &&
          !selectedDate.isAfter(endDate);
    }).toList();
  }
}

/// Provider
final medicineProvider =
    StateNotifierProvider<MedicineController, AsyncValue<List<MedicationTime>>>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    return MedicineController(apiService);
  },
);
// ================== Provider للأدوية غير المؤكدة ==================
final unconfirmedMedicineProvider = Provider<List<MedicationTime>>((ref) {
  final state = ref.watch(medicineProvider);

  if (state is AsyncData<List<MedicationTime>>) {
    final meds = state.value;
    // ترجع الأدوية التي patientConfirmed == 0
    return meds.where((med) => med.patientConfirmed == 0).toList();
  }

  return [];
});
