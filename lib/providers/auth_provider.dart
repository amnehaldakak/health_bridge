import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/auth_controller.dart';
import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('يجب تهيئة sharedPreferencesProvider');
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthController(apiService: apiService, prefs: prefs);
});

// Provider للوصول إلى بيانات المستخدم الحالي
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState is Authenticated ? authState.user : null;
});

// Provider للتحقق من حالة المصادقة
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState is Authenticated;
});

// Provider للحصول على التوكن
final tokenProvider = Provider<String?>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState is Authenticated ? authState.token : null;
});
