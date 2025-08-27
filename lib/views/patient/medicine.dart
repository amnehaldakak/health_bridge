import 'package:flutter/material.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/medicine_card.dart';
import 'package:health_bridge/models/medication_time.dart';

class Medicine extends StatefulWidget {
  const Medicine({super.key});

  @override
  State<Medicine> createState() => _MedicineState();
}

class _MedicineState extends State<Medicine> {
  @override
  MedicationTime med1 = MedicationTime(
      medicationTimeId: '1',
      userId: '1',
      medicationName: 'medicationName',
      amount: 'amount',
      timePerDay: DateTime.april,
      firstDoseTime: '1:00',
      startDate: DateTime.now(),
      durationDays: 1);
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed('add_medicine');
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        child: ListView(
          children: [
            Row(
              children: [IconButton(onPressed: () {}, icon: Icon(Icons.list))],
            ),
            CalendarTimeline(
              initialDate: DateTime.now(),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(9999, 12, 31),
              onDateSelected: (date) {},
              leftMargin: 20,
              monthColor: Colors.blueGrey,
              dayColor: Theme.of(context).colorScheme.primary,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Theme.of(context)
                  .bottomNavigationBarTheme
                  .unselectedItemColor,
              dotColor: const Color(0xFF333A47),
              selectableDayPredicate: (date) => date.day != 0,
              locale: 'en',
            ),
            Row(
              children: [
                MedicineCard(medication: med1),
                MedicineCard(medication: med1),
              ],
            )
          ],
        ),
      ),
    );
  }
}
