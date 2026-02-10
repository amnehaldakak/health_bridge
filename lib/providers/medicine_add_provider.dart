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

// Provider للأدوية فقط
final medicineListProvider =
    StateNotifierProvider<MedicineListNotifier, List<MedicationTime>>(
  (ref) => MedicineListNotifier(),
);

// Notifier جديد لإدارة وصف الخطة العلاجية + الأدوية (يمكن استخدامه في AddTreatmentPathway)
class TreatmentPlanNotifier extends StateNotifier<TreatmentPlanState> {
  TreatmentPlanNotifier()
      : super(TreatmentPlanState(description: '', medicines: []));

  void setDescription(String desc) {
    state = state.copyWith(description: desc);
  }

  void addMedicine(MedicationTime med) {
    state = state.copyWith(medicines: [...state.medicines, med]);
  }

  void removeMedicine(MedicationTime med) {
    state = state.copyWith(
      medicines: state.medicines.where((m) => m != med).toList(),
    );
  }

  void clear() {
    state = state.copyWith(description: '', medicines: []);
  }
}

class TreatmentPlanState {
  final String description;
  final List<MedicationTime> medicines;

  TreatmentPlanState({required this.description, required this.medicines});

  TreatmentPlanState copyWith({
    String? description,
    List<MedicationTime>? medicines,
  }) {
    return TreatmentPlanState(
      description: description ?? this.description,
      medicines: medicines ?? this.medicines,
    );
  }
}

// Provider للخطة العلاجية
final treatmentPlanProvider =
    StateNotifierProvider<TreatmentPlanNotifier, TreatmentPlanState>(
  (ref) => TreatmentPlanNotifier(),
);
