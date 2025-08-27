// lib/controllers/health_value_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/health_value.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// حالات HealthValue
abstract class HealthValueState {}

class HealthValueLoading extends HealthValueState {}

class HealthValueLoaded extends HealthValueState {
  final List<HealthValue> healthValues;

  HealthValueLoaded({required this.healthValues});
}

class HealthValueError extends HealthValueState {
  final String message;
  HealthValueError(this.message);
}

// Controller للـ HealthValue
class HealthValueController extends StateNotifier<HealthValueState> {
  final ApiService apiService;
  final SharedPreferences prefs;

  // خريطة لتخزين كل القيم لكل مرض
  final Map<int, List<HealthValue>> _allValues = {};

  HealthValueController({required this.apiService, required this.prefs})
      : super(HealthValueLoading());

  // تحميل القيم الصحية لمرض معين
  Future<void> loadHealthValues(int diseaseId) async {
    try {
      final token = prefs.getString('token');
      if (token == null) {
        state = HealthValueError('يجب تسجيل الدخول أولاً');
        return;
      }
      print(token + "---------------------");
      final response = await apiService.showHealthValues(diseaseId);

      if (response is List) {
        final healthValues =
            response.map((item) => HealthValue.fromJson(item)).toList();

        // تحديث الخريطة دون مسح القيم القديمة
        _allValues[diseaseId] = healthValues;

        // دمج كل القيم في قائمة واحدة
        final mergedValues = _allValues.values.expand((e) => e).toList();

        // ترتيب القيم من الأحدث للأقدم
        mergedValues.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        state = HealthValueLoaded(healthValues: mergedValues);
      } else {
        state = HealthValueError('فشل في تحميل البيانات');
      }
    } catch (e) {
      state = HealthValueError('خطأ في الاتصال: $e');
    }
  }

  // إضافة قيمة صحية جديدة
  Future<bool> addHealthValue(int diseaseId, int value,
      {int? valuee, String? status}) async {
    try {
      final token = prefs.getString('token');
      final patientId = prefs.getInt('patient_id');

      if (token == null || patientId == null) {
        return false;
      }

      final data = {
        'value': value,
        'valuee': valuee,
        'status': status,
      };

      final response =
          await apiService.storeHealthValue(diseaseId, data, token: token);

      if (response is Map<String, dynamic> && response['message'] != null) {
        // إعادة تحميل البيانات للمرض فقط بعد الإضافة
        await loadHealthValues(diseaseId);
        return true;
      }
      return false;
    } catch (e) {
      print('AddHealthValue error: $e');
      return false;
    }
  }

  // حذف قيمة صحية
  Future<bool> deleteHealthValue(int valueId) async {
    try {
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await apiService.deleteHealthValue(valueId);
      print('Delete response: $response');

      if (response is Map<String, dynamic> && response['message'] != null) {
        // إعادة تحميل كل الأمراض بعد الحذف
        for (final diseaseId in _allValues.keys) {
          await loadHealthValues(diseaseId);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('DeleteHealthValue error: $e');
      return false;
    }
  }
}
