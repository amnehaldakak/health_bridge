import 'medication_time.dart';

class MedicationGroup {
  final int groupId;
  final int caseId;
  final int patientId;
  final int doctorId;
  final String prescriptionDate;
  final String description;
  final String createdAt;
  final String updatedAt;
  final List<MedicationTime> medications;

  MedicationGroup({
    required this.groupId,
    required this.caseId,
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
      groupId: json['group_id'],
      caseId: json['case_id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      prescriptionDate: json['prescription_date'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      medications: (json['medications'] as List<dynamic>)
          .map((m) => MedicationTime.fromJson(m))
          .toList(),
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
