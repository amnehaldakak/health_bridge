import 'package:flutter/material.dart';

class ReminderTime {
  final int id;
  final int medicationId;
  final DateTime date;
  final TimeOfDay time;
  final int status; // immutable
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderTime({
    required this.id,
    required this.medicationId,
    required this.date,
    required this.time,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء نسخة جديدة مع تعديل الحقول المطلوبة
  ReminderTime copyWith({
    int? status,
    int? id,
    int? medicationId,
    DateTime? date,
    TimeOfDay? time,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderTime(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ReminderTime.fromJson(Map<String, dynamic> json) {
    // معالجة الوقت "HH:mm:ss"
    List<String> timeParts = json['time'].split(":");
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    return ReminderTime(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      medicationId: json['medication_id'] is int
          ? json['medication_id']
          : int.tryParse(json['medication_id'].toString()) ?? 0,
      date: DateTime.parse(json['date']),
      time: TimeOfDay(hour: hour, minute: minute),
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication_id': medicationId,
      'date': date.toIso8601String(),
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
