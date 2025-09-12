import 'medication_time.dart';

class MedicationGroup {
  final int groupId;
  final int? caseId;
  final int patientId;
  final int doctorId;
  final String prescriptionDate;
  final String description;
  final String createdAt;
  final String updatedAt;
  final List<MedicationTime> medications;

  MedicationGroup({
    required this.groupId,
    this.caseId,
    required this.patientId,
    required this.doctorId,
    required this.prescriptionDate,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.medications,
  });

  factory MedicationGroup.fromJson(Map<String, dynamic> json) {
    return MedicationGroup(
      groupId: (json['group_id'] != null)
          ? int.tryParse(json['group_id'].toString()) ?? 0
          : 0,
      caseId: (json['case_id'] != null)
          ? int.tryParse(json['case_id'].toString())
          : null,
      patientId: (json['patient_id'] != null)
          ? int.tryParse(json['patient_id'].toString()) ?? 0
          : 0,
      doctorId: (json['doctor_id'] != null)
          ? int.tryParse(json['doctor_id'].toString()) ?? 0
          : 0,
      prescriptionDate: json['prescription_date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      medications: (json['medications'] != null && json['medications'] is List)
          ? (json['medications'] as List<dynamic>)
              .map((m) => MedicationTime.fromJson(m))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'case_id': caseId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'prescription_date': prescriptionDate,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'medications': medications.map((m) => m.toJson()).toList(),
    };
  }
}
