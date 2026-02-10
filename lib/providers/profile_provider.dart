import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/profile_responce.dart';
import 'package:health_bridge/providers/auth_provider.dart';

final profileProvider = FutureProvider<ProfileResponse>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getProfile();
  return ProfileResponse.fromJson(response);
});
