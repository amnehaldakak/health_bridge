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
    this.medicationId,
    this.groupId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.startDate,
    required this.firstDoseTime,
    this.patientConfirmed,
    this.createdAt,
    this.updatedAt,
    this.medicationGroup,
  });

  // Create from JSON
  factory MedicationTime.fromJson(Map<String, dynamic> json) {
    return MedicationTime(
      medicationId: (json['medication_id'] != null)
          ? int.tryParse(json['medication_id'].toString()) ?? 0
          : 0,
      groupId: (json['group_id'] != null)
          ? int.tryParse(json['group_id'].toString()) ?? 0
          : 0,
      name: json['name']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      frequency: (json['frequency'] != null)
          ? int.tryParse(json['frequency'].toString()) ?? 0
          : 0,
      duration: (json['duration'] != null)
          ? int.tryParse(json['duration'].toString()) ?? 0
          : 0,
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ??
          DateTime.now(),
      firstDoseTime: json['first_dose_time']?.toString() ?? '',
      patientConfirmed: (json['patient_confirmed'] != null)
          ? int.tryParse(json['patient_confirmed'].toString()) ?? 0
          : 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      medicationGroup: json['medication_group'] != null
          ? MedicationGroup.fromJson(json['medication_group'])
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'medication_id': medicationId,
      'group_id': groupId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'start_date': startDate.toIso8601String().split('T')[0],
      'first_dose_time': firstDoseTime,
      'patient_confirmed': patientConfirmed,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'medication_group': medicationGroup?.toJson(),
    };
  }

  // CopyWith method
  MedicationTime copyWith({
    int? medicationId,
    int? groupId,
    String? name,
    String? dosage,
    int? frequency,
    int? duration,
    DateTime? startDate,
    String? firstDoseTime,
    int? patientConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
    MedicationGroup? medicationGroup,
  }) {
    return MedicationTime(
      medicationId: medicationId ?? this.medicationId,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      firstDoseTime: firstDoseTime ?? this.firstDoseTime,
      patientConfirmed: patientConfirmed ?? this.patientConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicationGroup: medicationGroup ?? this.medicationGroup,
    );
  }

  // Calculate end date
  DateTime get endDate => startDate.add(Duration(days: duration));

  // Check if medication is active
  bool get isActive => DateTime.now().isBefore(endDate);

  // Remaining days
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  @override
  String toString() {
    return 'MedicationTime(medicationId: $medicationId, name: $name, dosage: $dosage, frequency: $frequency, duration: $duration, startDate: $startDate, firstDoseTime: $firstDoseTime)';
  }
}
