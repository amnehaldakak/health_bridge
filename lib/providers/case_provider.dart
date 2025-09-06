import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';

// 🟢 Provider للوصول لتفاصيل الحالة الطبية
class CaseProvider extends ChangeNotifier {
  final ApiService apiService;

  CaseProvider({required this.apiService});

  bool isLoading = false;
  String? errorMessage;
  Case? medicalCase;

  // 🟢 جلب تفاصيل حالة معينة
  Future<void> fetchCaseDetails(int caseId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final caseDetails = await apiService.getCaseDetails(caseId);
      medicalCase = caseDetails;
    } catch (e) {
      errorMessage = e.toString();
      medicalCase = null;
    }

    isLoading = false;
    notifyListeners();
  }

  void notifyListeners() {}
}

// 🟢 Provider العام لاستخدامه مع Riverpod
final caseProvider = ChangeNotifierProvider<CaseProvider>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CaseProvider(apiService: apiService);
});
