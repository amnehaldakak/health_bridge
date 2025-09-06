import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/service/api_service.dart';

class CommunitiesPageController extends ChangeNotifier {
  final ApiService apiService;

  CommunitiesPageController({required this.apiService});

  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> communities = [];

  Future<void> fetchCommunities() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await apiService.getAllCommunities();
      communities = data;
      print(communities);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

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
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
