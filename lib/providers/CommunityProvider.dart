import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';

class CommunityProvider extends ChangeNotifier {
  final ApiService apiService;

  CommunityProvider({required this.apiService});

  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? createdCommunity;
  Map<String, dynamic>? updatedCommunity;
  Map<String, dynamic>? joinedCommunity;
  Map<String, dynamic>? createdPost;
  Map<String, dynamic>? communityDetails;

  // 🟢 إنشاء مجتمع جديد
  Future<void> createCommunity({
    required String name,
    String? description,
    required String type,
    String? specialization,
    String? imagePath,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.createCommunity(
        name: name,
        description: description,
        type: type,
        specialization: specialization,
        imagePath: imagePath,
      );
      createdCommunity = response['community'];
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // 🟠 تحديث مجتمع موجود
  Future<void> updateCommunity({
    required String id,
    String? name,
    String? description,
    String? type,
    String? specialization,
    String? imagePath,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.updateCommunity(
        id: id,
        name: name,
        description: description,
        type: type,
        specialization: specialization,
        imagePath: imagePath,
      );
      updatedCommunity = response['community'];
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // 🟢 الانضمام إلى مجتمع
  Future<void> joinCommunity(String communityId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.joinCommunity(communityId);
      joinedCommunity = response['member'];
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // 🟢 إنشاء منشور داخل مجتمع
  Future<void> createPost({
    required String communityId,
    required String title,
    required String content,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.createPost(
        communityId: communityId,
        title: title,
        content: content,
      );
      createdPost = response['post'];
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // 🟢 جلب تفاصيل المجتمع مع المنشورات
  Future<void> fetchCommunityDetails(String communityId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.getCommunityDetails(communityId);
      communityDetails = response['community'];
      print(communityDetails);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // 🟢 جلب منشور واحد مع التعليقات
  Future<Map<String, dynamic>?> fetchPostWithComments(String postId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.getPostWithComments(postId);
      print(response);
      return response['post'];
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🟢 إضافة التعليق
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.addComment(
        postId: postId,
        content: content,
      );

      // بعد الإضافة، جلب التعليقات من جديد لتحديث الصفحة
      await fetchPostWithComments(postId);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}

// 🟢 Provider
final communityProvider = ChangeNotifierProvider<CommunityProvider>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CommunityProvider(apiService: apiService);
});
