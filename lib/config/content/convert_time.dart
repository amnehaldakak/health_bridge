import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String convertTime(String minutes) {
  if (minutes.length == 1) {
    return "0$minutes";
  } else {
    return minutes;
  }
}

String formatTimeOfDay(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  final format = DateFormat.jm(); // صيغة الوقت، يمكنك تخصيصها حسب الحاجة
  return format.format(dt);
}

String getFormattedDate(DateTime dateTime) {
  // تنسيق التاريخ
  return DateFormat('yyyy-MM-dd').format(dateTime);
}
