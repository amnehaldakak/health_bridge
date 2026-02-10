import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/reminder_time.dart';
import 'package:health_bridge/service/api_service.dart';

class MedicineDetailController extends StateNotifier<List<ReminderTime>> {
  final ApiService apiService;

  MedicineDetailController(this.apiService) : super([]);

  bool isLoading = false;

  /// تحميل ReminderTimes من الـ ApiService
  Future<void> fetchReminderTimes(int medicationId) async {
    try {
      isLoading = true;
      final reminders = await apiService.fetchReminderTimes(medicationId);
      state = reminders;
      print('✅ تم جلب ${reminders.length} موعد للدواء $medicationId');
    } catch (e) {
      print('❌ فشل في جلب البيانات: $e');
      state = [];
      rethrow; // إعادة throw الخطأ للتعامل معه في الواجهة
    } finally {
      isLoading = false;
    }
  }

  /// تحديث حالة التذكير محلياً وفي السيرفر
  Future<void> updateReminderStatus(int reminderId, int status) async {
    final oldState = List<ReminderTime>.from(state);
    try {
      _updateLocalStatus(reminderId, status);
      await apiService.updateReminderStatus(reminderId, status);
      print('✅ تم تحديث حالة التذكير id=$reminderId إلى status=$status');
    } catch (e) {
      print('❌ فشل في تحديث حالة التذكير: $e');
      state = oldState; // رجّع للحالة القديمة
      // ما تعمل throw إذا بدك تمنع الكراش
    }
  }

  /// تحديث الحالة محلياً فقط (دالة مساعدة)
  void _updateLocalStatus(int reminderId, int status) {
    state = state.map((r) {
      if (r.id == reminderId) {
        return r.copyWith(status: status);
      }
      return r;
    }).toList();
  }

  /// فلترة المواعيد حسب التاريخ
  List<ReminderTime> filterByDate(DateTime selectedDate) {
    return state.where((r) {
      return r.date.year == selectedDate.year &&
          r.date.month == selectedDate.month &&
          r.date.day == selectedDate.day;
    }).toList();
  }

  /// الحصول على حالة التحميل
  bool get isLoaded => !isLoading && state.isNotEmpty;

  /// الحصول على عدد المواعيد المكتملة
  int getCompletedCount(DateTime selectedDate) {
    final filtered = filterByDate(selectedDate);
    return filtered.where((r) => r.status == 1).length;
  }

  /// الحصول على إجمالي عدد المواعيد لليوم
  int getTotalCount(DateTime selectedDate) {
    return filterByDate(selectedDate).length;
  }

  /// تحديث تذكير محدد (للاستخدام من واجهات أخرى)
  void updateReminder(ReminderTime updatedReminder) {
    state = state.map((r) {
      if (r.id == updatedReminder.id) {
        return updatedReminder;
      }
      return r;
    }).toList();
  }

  /// إضافة تذكير جديد (إذا لزم الأمر)
  void addReminder(ReminderTime newReminder) {
    state = [...state, newReminder];
  }

  /// حذف تذكير (إذا لزم الأمر)
  void removeReminder(int reminderId) {
    state = state.where((r) => r.id != reminderId).toList();
  }
}
