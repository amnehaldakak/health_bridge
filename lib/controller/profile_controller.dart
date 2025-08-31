import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/providers/profile_provider.dart';

/// Notifier لتحديث وحذف البروفايل
class ProfileController {
  final Ref ref;
  ProfileController(this.ref);

  /// تحديث البروفايل مع دعم الصورة
  Future<void> updateProfile({
    String? name,
    String? email,
    File? profilePicture, // ✅ إضافة الصورة
    Map<String, String>? extraFields, // بيانات إضافية (مريض/دكتور)
  }) async {
    final api = ref.read(apiServiceProvider);
    await api.updateProfile(
      name: name,
      email: email,
      profilePicture: profilePicture, // تمرير الصورة للـ API
      extraFields: extraFields,
    );

    // نعمل refresh للبروفايل بعد التحديث
    ref.invalidate(profileProvider);
  }

  Future<void> deleteProfile() async {
    final api = ref.read(apiServiceProvider);
    await api.deleteProfile();

    // بعد الحذف نفضي البروفايل
    ref.invalidate(profileProvider);
  }
}

/// Provider للكنترولر
final profileControllerProvider = Provider<ProfileController>((ref) {
  return ProfileController(ref);
});
