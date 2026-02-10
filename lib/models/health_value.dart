// lib/models/health_value.dart
class HealthValue {
  final int id;
  final int patientId;
  final int diseaseId;
  final int value;
  final int? valuee; // القيمة الثانية (مثل الضغط الانبساطي)
  final String? status;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthValue({
    required this.id,
    required this.patientId,
    required this.diseaseId,
    required this.value,
    this.valuee,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthValue.fromJson(Map<String, dynamic> json) {
    return HealthValue(
      id: json['id'] ?? json['values_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      diseaseId: json['disease_id'] ?? 0,
      value: json['value'] ?? 0,
      valuee: json['valuee'],
      status: json['status'],
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt:
          DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'disease_id': diseaseId,
      'value': value,
      'valuee': valuee,
      'status': status,
    };
  }

  // الحصول على نوع المرض بناءً على diseaseId
  String get diseaseType {
    switch (diseaseId) {
      case 1: // افترض أن 1 هو ضغط الدم
        return 'ضغط الدم';
      case 2: // افترض أن 2 هو السكر
        return 'سكر الدم';
      default:
        return 'غير معروف';
    }
  }

  String get displayValue {
    if (diseaseId == 1) {
      // ضغط الدم
      return '$value/${valuee ?? 0}';
    } else {
      // السكر أو أمراض أخرى
      return value.toString();
    }
  }
}
