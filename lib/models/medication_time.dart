import 'package:health_bridge/models/medication_group.dart';

class MedicationTime {
  final int? medicationId;
  final int? groupId;
  final String name;
  final String dosage;
  final int frequency;
  final int duration;
  final DateTime startDate;
  final String firstDoseTime;
  final int? patientConfirmed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final MedicationGroup? medicationGroup;

  const MedicationTime({
    required this.medicationId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.startDate,
    required this.firstDoseTime,
    this.groupId,
    this.patientConfirmed,
    this.createdAt,
    this.updatedAt,
    this.medicationGroup,
  });

  // Create from JSON
  factory MedicationTime.fromJson(Map<String, dynamic> json) {
    return MedicationTime(
      medicationId: json['medication_id'] ?? 0,
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? 0,
      duration: json['duration'] ?? 0,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      firstDoseTime: json['first_dose_time'] ?? '',
      groupId: json['group_id'],
      patientConfirmed: json['patient_confirmed'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      medicationGroup: json['medication_group'] != null
          ? MedicationGroup.fromJson(json['medication_group'])
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'medication_id': medicationId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'start_date':
          startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'first_dose_time': firstDoseTime,
      'group_id': groupId,
      'patient_confirmed': patientConfirmed,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'medication_group': medicationGroup?.toJson(),
    };
  }

  // Create a copy with updated fields
  MedicationTime copyWith({
    int? medicationId,
    String? name,
    String? dosage,
    int? frequency,
    int? duration,
    DateTime? startDate,
    String? firstDoseTime,
    int? groupId,
    int? patientConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
    MedicationGroup? medicationGroup,
  }) {
    return MedicationTime(
      medicationId: medicationId ?? this.medicationId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      firstDoseTime: firstDoseTime ?? this.firstDoseTime,
      groupId: groupId ?? this.groupId,
      patientConfirmed: patientConfirmed ?? this.patientConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicationGroup: medicationGroup ?? this.medicationGroup,
    );
  }

  // Calculate end date
  DateTime get endDate => startDate.add(Duration(days: duration));

  // Check if medication is still active
  bool get isActive => DateTime.now().isBefore(endDate);

  // Get remaining days
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  @override
  String toString() {
    return 'MedicationTime(medicationId: $medicationId, name: $name, dosage: $dosage, frequency: $frequency, duration: $duration, startDate: $startDate, firstDoseTime: $firstDoseTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicationTime &&
        other.medicationId == medicationId &&
        other.name == name &&
        other.dosage == dosage &&
        other.frequency == frequency &&
        other.duration == duration &&
        other.startDate == startDate &&
        other.firstDoseTime == firstDoseTime;
  }

  @override
  int get hashCode {
    return medicationId.hashCode ^
        name.hashCode ^
        dosage.hashCode ^
        frequency.hashCode ^
        duration.hashCode ^
        startDate.hashCode ^
        firstDoseTime.hashCode;
  }
}
