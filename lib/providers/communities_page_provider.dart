import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/communities_page_controller.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/controller/auth_controller.dart';
import 'package:health_bridge/service/api_service.dart';

// Provider للـ CommunitiesPageController
final communitiesPageControllerProvider =
    ChangeNotifierProvider<CommunitiesPageController>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final authState =
      ref.watch(authControllerProvider); // 👈 watch لمزامنة التحديثات

  String role = '';
  if (authState is Authenticated) {
    role = authState.user.role ?? '';
  }

  return CommunitiesPageController(
    apiService: apiService,
    userRole: role,
  );
});
