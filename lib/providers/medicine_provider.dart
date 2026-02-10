import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/medicine_controller.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/providers/auth_provider.dart';

List<MedicationTime> medicnePathway = [];

final medicineProvider = Provider(
  (ref) {
    return medicnePathway;
  },
);
// ملف medicine_provider.dart

// تأكد من أن هذا هو الـ Provider الصحيح
final medicineProvider2 = FutureProvider<List<MedicationTime>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getMedicine();
});

// أو إذا كنت تستخدم StateNotifierProvider
final medicineNotifierProvider =
    StateNotifierProvider<MedicineController, AsyncValue<List<MedicationTime>>>(
        (ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MedicineController(apiService);
});
