import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/auth_controller.dart';
import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =================== SharedPreferences Provider ===================
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences لم يتم تهيئتها بعد');
});

// =================== ApiService Provider ===================
final apiServiceProvider = Provider<ApiService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider); // ✅ تمرير prefs
  return ApiService(prefs: prefs);
});

// =================== AuthController Provider ===================
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthController(apiService: apiService, prefs: prefs);
});

// =================== Current User Provider ===================
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState is Authenticated ? authState.user : null;
});

// =================== isLoggedIn Provider ===================
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState is Authenticated;
});

// =================== Token Provider ===================
final tokenProvider = Provider<String?>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState is Authenticated ? authState.token : null;
});
