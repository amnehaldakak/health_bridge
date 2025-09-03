import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/medicine_detail_controller.dart';
import 'package:health_bridge/models/reminder_time.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';

final medicineDetailControllerProvider =
    StateNotifierProvider<MedicineDetailController, List<ReminderTime>>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    return MedicineDetailController(apiService);
  },
);

final isLoadingProvider = Provider<bool>((ref) {
  final controller = ref.read(medicineDetailControllerProvider.notifier);
  return controller.isLoading;
});

final filteredMedicationsProvider = Provider<List<ReminderTime>>((ref) {
  return ref.watch(medicineDetailControllerProvider);
});
