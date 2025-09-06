import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/communities_page_controller.dart';
import 'package:health_bridge/providers/auth_provider.dart';

final communitiesPageProvider =
    ChangeNotifierProvider<CommunitiesPageController>((ref) {
  final apiService = ref.watch(apiServiceProvider); // ApiService موجود
  return CommunitiesPageController(apiService: apiService);
});
