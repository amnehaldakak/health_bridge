// lib/providers/health_value_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/health_value_controller.dart';
import 'package:health_bridge/models/health_value.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final healthValueControllerProvider =
    StateNotifierProvider<HealthValueController, HealthValueState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return HealthValueController(apiService: apiService, prefs: prefs);
});

// Provider للحصول على كل القيم الصحية
final healthValuesProvider = Provider<List<HealthValue>>((ref) {
  final state = ref.watch(healthValueControllerProvider);
  if (state is HealthValueLoaded) {
    return state.healthValues;
  }
  return [];
});

// Provider لفصل القيم حسب المرض
final bloodPressureValuesProvider = Provider<List<HealthValue>>((ref) {
  final allValues = ref.watch(healthValuesProvider);
  return allValues.where((val) => val.diseaseId == 1).toList();
});

final sugarValuesProvider = Provider<List<HealthValue>>((ref) {
  final allValues = ref.watch(healthValuesProvider);
  return allValues.where((val) => val.diseaseId == 2).toList();
});
