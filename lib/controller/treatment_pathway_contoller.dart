import 'package:health_bridge/models/medication_group.dart';
import 'package:health_bridge/service/api_service.dart';

class MedicationGroupController {
  final ApiService apiService;

  MedicationGroupController({required this.apiService});

  Future<MedicationGroup> getMedicationGroup(int caseId) async {
    return apiService.fetchMedicationGroup(caseId);
  }
}
