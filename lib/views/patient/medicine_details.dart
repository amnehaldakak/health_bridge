import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/content/convert_time.dart';
import 'package:health_bridge/config/content/time_line_tile.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/models/reminder_time.dart';
import 'package:health_bridge/providers/medicine_details_provider.dart';
import 'package:intl/intl.dart';

class MedicineDetails extends ConsumerStatefulWidget {
  final MedicationTime medication;
  final DateTime selectedDate;

  const MedicineDetails({
    super.key,
    required this.medication,
    required this.selectedDate,
  });

  @override
  ConsumerState<MedicineDetails> createState() => _MedicineDetailsState();
}

class _MedicineDetailsState extends ConsumerState<MedicineDetails> {
  @override
  void initState() {
    super.initState();
    // تحميل ReminderTimes بناءً على medicationId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(medicineDetailControllerProvider.notifier)
          .fetchReminderTimes(widget.medication.medicationId ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final reminders = ref.watch(medicineDetailControllerProvider);
    final controller = ref.read(medicineDetailControllerProvider.notifier);
    final loc = AppLocalizations.of(context);

    // تحويل التاريخ المختار إلى تنسيق yyyy-MM-dd للمقارنة
    final formattedSelectedDate =
        DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    // فلترة المواعيد حسب التاريخ المختار (باستخدام تنسيق string للمقارنة)
    final filteredReminders = reminders.where((r) {
      // تحويل تاريخ الـ reminder إلى تنسيق yyyy-MM-dd للمقارنة
      final reminderDateFormatted = DateFormat('yyyy-MM-dd').format(r.date);
      return reminderDateFormatted == formattedSelectedDate;
    }).toList();

    // طباعة القائمة بعد الفلترة للتحقق
    print('=== ${loc!.get('filtered_list')} ===');
    print('${loc.get('selected_date')}: $formattedSelectedDate');
    print('${loc.get('total_reminders')}: ${reminders.length}');
    print('${loc.get('filtered_reminders')}: ${filteredReminders.length}');

    if (filteredReminders.isEmpty) {
      print(loc.get('no_reminders_for_date'));
    } else {
      for (var reminder in filteredReminders) {
        final reminderTimeFormatted =
            DateFormat('HH:mm:ss').format(reminder.date);
        print(
            '${loc.get('reminder_id')}: ${reminder.id}, ${loc.get('time')}: $reminderTimeFormatted, ${loc.get('status')}: ${reminder.status}');
      }
    }
    print('==========================');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.medication.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredReminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(loc.get('no_medications_for_date')),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.get('change_date')),
                      )
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        loc.get('dose_times'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // قائمة المواعيد
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredReminders.length,
                        itemBuilder: (context, index) {
                          final reminder = filteredReminders[index];

                          return TimeLineTile1(
                            isFirst: index == 0,
                            isPast: reminder.status == 1,
                            isLast: index == filteredReminders.length - 1,
                            evenCard: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  formatTimeOfDay(reminder.time),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: reminder.status == 1
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                // الزر يعتمد على حالة الـ status
                                reminder.status != 1
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.check_box_outline_blank,
                                          size: 30,
                                        ),
                                        color: Colors.grey,
                                        onPressed: () async {
                                          print(reminder.id);
                                          await controller.updateReminderStatus(
                                              reminder.id,
                                              1); // تغيير إلى 1 (تم)
                                        },
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.check_box,
                                          size: 30,
                                        ),
                                        color: blue4,
                                        onPressed: () async {
                                          await controller.updateReminderStatus(
                                              reminder.id,
                                              0); // تغيير إلى 0 (لم يتم)
                                        }),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
