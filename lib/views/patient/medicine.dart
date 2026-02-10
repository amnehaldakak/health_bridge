import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/medicine_card.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/providers/medicine_provider.dart';

class Medicine extends ConsumerWidget {
  const Medicine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicineNotifierProvider);
    final controller = ref.read(medicineNotifierProvider.notifier);
    final loc = AppLocalizations.of(context);

    // تحديد لغة CalendarTimeline بناءً على لغة التطبيق
    final localeCode = Localizations.localeOf(context).languageCode;
    final calendarLocale = (localeCode == 'en') ? 'en' : 'ar';

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('add_medicine'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          CalendarTimeline(
            initialDate: controller.selectedDate,
            firstDate: DateTime(2020, 1, 1),
            lastDate: DateTime(9999, 12, 31),
            onDateSelected: controller.changeDate,
            leftMargin: 20,
            monthColor: Colors.blueGrey,
            dayColor: Theme.of(context).colorScheme.primary,
            activeDayColor: Colors.white,
            activeBackgroundDayColor:
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
            dotColor: const Color(0xFF333A47),
            selectableDayPredicate: (date) => date.day != 0,
            locale: calendarLocale, // <-- استخدام اللغة المحددة
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              loc!.get('todays_medications'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (_) {
                final todaysMeds = controller.getTasksForSelectedDate();

                if (todaysMeds.isEmpty) {
                  return Center(child: Text(loc.get('no_medications')));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8, // مناسب للكارد
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: todaysMeds.length,
                  itemBuilder: (context, index) {
                    return MedicineCard(
                      medication: todaysMeds[index],
                      selectedDate: controller.selectedDate,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
