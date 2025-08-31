import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/medication_time.dart';

class MedicineListNotifier extends StateNotifier<List<MedicationTime>> {
  MedicineListNotifier() : super([]);

  void addMedicine(MedicationTime medicine) {
    state = [...state, medicine];
  }

  void removeMedicine(MedicationTime medicine) {
    state = state.where((m) => m != medicine).toList();
  }

  void clearMedicines() {
    state = [];
  }
}

// Provider
final medicineListProvider =
    StateNotifierProvider<MedicineListNotifier, List<MedicationTime>>(
  (ref) => MedicineListNotifier(),
);
