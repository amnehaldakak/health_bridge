class MedicationTime {
  final String? medicationTimeId;
  final String userId;
  final String medicationName;
  final String amount;
  final int timePerDay;
  final String firstDoseTime;
  final DateTime startDate;
  final int durationDays;

  const MedicationTime({
    required this.medicationTimeId,
    required this.userId,
    required this.medicationName,
    required this.amount,
    required this.timePerDay,
    required this.firstDoseTime,
    required this.startDate,
    required this.durationDays,
  });

  // Create from JSON
  factory MedicationTime.fromJson(Map<String, dynamic> json) {
    return MedicationTime(
      medicationTimeId: json['Medication_Time_ID'] ?? '',
      userId: json['User_ID'] ?? '',
      medicationName: json['Medication_Name'] ?? '',
      amount: json['Amount'] ?? '',
      timePerDay: json['Time_Per_Day'] ?? 0,
      firstDoseTime: json['First_Dose_Time'] ?? '',
      startDate: DateTime.tryParse(json['Start_Date'] ?? '') ?? DateTime.now(),
      durationDays: json['Duration_Days'] ?? 0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Medication_Time_ID': medicationTimeId,
      'User_ID': userId,
      'Medication_Name': medicationName,
      'Amount': amount,
      'Time_Per_Day': timePerDay,
      'First_Dose_Time': firstDoseTime,
      'Start_Date': startDate.toIso8601String(),
      'Duration_Days': durationDays,
    };
  }

  // Create a copy with updated fields
  MedicationTime copyWith({
    String? medicationTimeId,
    String? userId,
    String? medicationName,
    String? amount,
    int? timePerDay,
    String? firstDoseTime,
    DateTime? startDate,
    int? durationDays,
  }) {
    return MedicationTime(
      medicationTimeId: medicationTimeId ?? this.medicationTimeId,
      userId: userId ?? this.userId,
      medicationName: medicationName ?? this.medicationName,
      amount: amount ?? this.amount,
      timePerDay: timePerDay ?? this.timePerDay,
      firstDoseTime: firstDoseTime ?? this.firstDoseTime,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
    );
  }

  // Calculate end date
  DateTime get endDate => startDate.add(Duration(days: durationDays));

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
    return 'MedicationTime(medicationTimeId: $medicationTimeId, userId: $userId, medicationName: $medicationName, amount: $amount, timePerDay: $timePerDay, firstDoseTime: $firstDoseTime, startDate: $startDate, durationDays: $durationDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicationTime &&
        other.medicationTimeId == medicationTimeId &&
        other.userId == userId &&
        other.medicationName == medicationName &&
        other.amount == amount &&
        other.timePerDay == timePerDay &&
        other.firstDoseTime == firstDoseTime &&
        other.startDate == startDate &&
        other.durationDays == durationDays;
  }

  @override
  int get hashCode {
    return medicationTimeId.hashCode ^
        userId.hashCode ^
        medicationName.hashCode ^
        amount.hashCode ^
        timePerDay.hashCode ^
        firstDoseTime.hashCode ^
        startDate.hashCode ^
        durationDays.hashCode;
  }
}
