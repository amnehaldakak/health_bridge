// lib/providers/health_value_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/health_value_controller.dart';
import 'package:health_bridge/models/health_value.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';
import 'package:flutter/material.dart';

// ================= HealthValue Controller Provider =================
final healthValueControllerProvider =
    StateNotifierProvider<HealthValueController, HealthValueState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return HealthValueController(apiService: apiService, prefs: prefs);
});

// ================= All Health Values Provider =================
final healthValuesProvider = Provider<List<HealthValue>>((ref) {
  final state = ref.watch(healthValueControllerProvider);
  if (state is HealthValueLoaded) {
    return state.healthValues;
  }
  return [];
});

// ================= Disease-specific Providers =================
final bloodPressureValuesProvider = Provider<List<HealthValue>>((ref) {
  final allValues = ref.watch(healthValuesProvider);
  return allValues.where((val) => val.diseaseId == 1).toList();
});

final sugarValuesProvider = Provider<List<HealthValue>>((ref) {
  final allValues = ref.watch(healthValuesProvider);
  return allValues.where((val) => val.diseaseId == 2).toList();
});

// ================= Selected Date Provider =================
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// ================= Filtered Values by Selected Date =================
final filteredHealthValuesProvider = Provider<List<HealthValue>>((ref) {
  final allValues = ref.watch(healthValuesProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  final filtered = allValues
      .where((val) =>
          val.createdAt.year == selectedDate.year &&
          val.createdAt.month == selectedDate.month &&
          val.createdAt.day == selectedDate.day)
      .toList();

  filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return filtered;
});
