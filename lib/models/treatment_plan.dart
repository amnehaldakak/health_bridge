import 'package:health_bridge/models/medication_time.dart';

class TreatmentPlan {
  String name;
  String description;
  List<MedicationTime> medications;

  TreatmentPlan({
    required this.name,
    required this.description,
    required this.medications,
  });
}
