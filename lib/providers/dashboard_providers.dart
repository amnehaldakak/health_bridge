import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/doctor.dart';
import 'package:health_bridge/providers/auth_provider.dart';

// Pending Doctors Provider
final pendingDoctorsProvider = StateNotifierProvider<PendingDoctorsNotifier,
    AsyncValue<List<DoctorModel>>>(
  // <-- صحّحت النوع هنا
  (ref) => PendingDoctorsNotifier(ref),
);

// Certificate Provider (PDF/Image)
final certificateProvider =
    FutureProvider.family<Uint8List, int>((ref, doctorId) async {
  final api = ref.read(apiServiceProvider);
  return await api.showCertificate(doctorId);
});
final dashboardDataProvider = FutureProvider<Map<String, int>>((ref) async {
  final api = ref.watch(apiServiceProvider);

  final userData = await api.getUserCount();
  final communityData = await api.getCommunityCount();
  print(userData);
  print(communityData);

  return {
    "الأطباء المعتمدون": userData['approvedDoctors'] ?? 0,
    "المرضى": userData['patient'] ?? 0,
    "المجتمعات العامة": communityData['publicCommunity'] ?? 0,
    "المجتمعات الخاصة": communityData['privateCommunity'] ?? 0,
  };
});

class PendingDoctorsNotifier
    extends StateNotifier<AsyncValue<List<DoctorModel>>> {
  final Ref ref;
  PendingDoctorsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchPendingDoctors();
  }

  /// جلب قائمة الأطباء بانتظار الموافقة
  Future<void> fetchPendingDoctors() async {
    try {
      state = const AsyncValue.loading();
      final doctors = await ref.read(apiServiceProvider).getPendingDoctors();
      state = AsyncValue.data(doctors);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// الموافقة أو رفض الطبيب
  Future<void> approveOrRejectDoctor(int doctorId, String action) async {
    try {
      await ref
          .read(apiServiceProvider)
          .approveOrRejectDoctor(doctorId, action);
      await fetchPendingDoctors(); // تحديث القائمة بعد أي إجراء
    } catch (e) {
      rethrow;
    }
  }
}
