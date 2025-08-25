class Case {
  final int id;
  final int patientId;
  final int doctorId;
  final String? chiefComplaint;
  final String? symptoms;
  final String? medicalHistory;
  final String? surgicalHistory;
  final String? allergicHistory;
  final String? smokingStatus;
  final String? signs;
  final String? vitalSigns;
  final String? clinicalExaminationResults;
  final String? echo;
  final String? labTest;
  final String? diagnosis;
  final String? createdAt;
  final String? updatedAt;

  Case({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.chiefComplaint,
    this.symptoms,
    this.medicalHistory,
    this.surgicalHistory,
    this.allergicHistory,
    this.smokingStatus,
    this.signs,
    this.vitalSigns,
    this.clinicalExaminationResults,
    this.echo,
    this.labTest,
    this.diagnosis,
    this.createdAt,
    this.updatedAt,
  });

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      chiefComplaint: json['chief_complaint'],
      symptoms: json['symptoms'],
      medicalHistory: json['medical_history'],
      surgicalHistory: json['surgical_history'],
      allergicHistory: json['allergic_history'],
      smokingStatus: json['smoking_status'],
      signs: json['signs'],
      vitalSigns: json['vital_signs'],
      clinicalExaminationResults: json['clinical_examination_results'],
      echo: json['echo'],
      labTest: json['lab_test'],
      diagnosis: json['diagnosis'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'chief_complaint': chiefComplaint,
      'symptoms': symptoms,
      'medical_history': medicalHistory,
      'surgical_history': surgicalHistory,
      'allergic_history': allergicHistory,
      'smoking_status': smokingStatus,
      'signs': signs,
      'vital_signs': vitalSigns,
      'clinical_examination_results': clinicalExaminationResults,
      'echo': echo,
      'lab_test': labTest,
      'diagnosis': diagnosis,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
