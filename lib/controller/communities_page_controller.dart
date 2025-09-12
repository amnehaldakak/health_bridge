import 'package:flutter/material.dart';
import 'package:health_bridge/service/api_service.dart';

class CommunitiesPageController extends ChangeNotifier {
  final ApiService apiService;
  final String userRole;

  CommunitiesPageController({
    required this.apiService,
    required this.userRole,
  });

  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> communities = [];

  // جلب قائمة المجتمعات حسب الدور
  Future<void> fetchCommunities() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      List<Map<String, dynamic>> data;

      if (userRole.toLowerCase() == 'doctor') {
        data = await apiService.getAllCommunities(); // جميع المجتمعات للطبيب
      } else {
        data =
            await apiService.getPublicCommunities(); // المجتمعات العامة للمريض
      }

      communities = data;
    } catch (e) {
      errorMessage = 'فشل في تحميل المجتمعات: ${e.toString()}';
      communities = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // الانضمام لمجتمع
  Future<void> joinCommunity(String communityId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await apiService.joinCommunity(communityId);

      // تحديث القائمة بعد الانضمام
      await fetchCommunities();
    } catch (e) {
      errorMessage = 'فشل في الانضمام للمجتمع: ${e.toString()}';
    }

    isLoading = false;
    notifyListeners();
  }

  // مشاركة حالة طبية في مجتمع
  Future<void> shareMedicalCase({
    required int caseId,
    required int communityId,
    required String title,
    required String content,
    required bool includeTreatmentPlan,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await apiService.shareMedicalCase(
        caseId: caseId,
        communityId: communityId,
        title: title,
        content: content,
        includeTreatmentPlan: includeTreatmentPlan,
      );
    } catch (e) {
      errorMessage = 'فشل في مشاركة الحالة الطبية: ${e.toString()}';
    }

    isLoading = false;
    notifyListeners();
  }
}
