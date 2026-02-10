import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/providers/auth_provider.dart';

// 1. مزود ApiService

// 2. Provider لجلب الطلبات المعلقة
final pendingApprovalsProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getPendingApprovals();
});

// 3. Provider لجلب طلبات المرضى
final requestsForPatientsProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getRequestsForPatients();
});

// 4. Provider لجلب تفاصيل طلب محدد
final requestDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return api.getRequest(
    id,
  );
});

// 5. Provider لإجراء الموافقة على الطلب
final approveRequestProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return api.approveRequest(
    id,
  );
});

// 6. Provider لإجراء رفض الطلب
final rejectRequestProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return api.rejectRequest(
    id,
  );
});
