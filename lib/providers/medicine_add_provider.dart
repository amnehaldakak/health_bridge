import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/medication_time.dart';

class MedicineListNotifier extends StateNotifier<List<MedicationTime>> {
  MedicineListNotifier() : super([]);

  void addMedicine(MedicationTime medicine) {
    state = [...state, medicine]; // Add new medicine to the list
  }
}

// Provider for the medicine list
final medicineListProvider =
    StateNotifierProvider<MedicineListNotifier, List<MedicationTime>>(
        (ref) => MedicineListNotifier());
