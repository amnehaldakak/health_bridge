import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/treatment_pathway_contoller.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:health_bridge/models/medication_group.dart';

/// Provider للـ MedicationGroupController
final medicationGroupControllerProvider =
    Provider<MedicationGroupController>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MedicationGroupController(apiService: apiService);
});

/// FutureProvider لجلب بيانات المسار العلاجي حسب caseId
final medicationGroupProvider =
    FutureProvider.family<MedicationGroup, int>((ref, caseId) async {
  final controller = ref.watch(medicationGroupControllerProvider);
  return controller.getMedicationGroup(caseId);
});
