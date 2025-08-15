import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/medication_time.dart';

List<MedicationTime> medicnePathway = [];

final medicineProvider = Provider(
  (ref) {
    return medicnePathway;
  },
);
