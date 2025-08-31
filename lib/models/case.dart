class Case {
  final int id;
  final String? chiefComplaint;
  final String? symptoms;
  final String? medicalHistory;
  final String? surgicalHistory;
  final String? allergicHistory;
  final String? smokingStatus;
  final String? signs;
  final String? vitalSigns;
  final String? clinicalExaminationResults;
  final String? diagnosis;
  final String? createdAt;
  final String? updatedAt;

  Case({
    required this.id,
    this.chiefComplaint,
    this.symptoms,
    this.medicalHistory,
    this.surgicalHistory,
    this.allergicHistory,
    this.smokingStatus,
    this.signs,
    this.vitalSigns,
    this.clinicalExaminationResults,
    this.diagnosis,
    this.createdAt,
    this.updatedAt,
  });
  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['id'],
      chiefComplaint: json['chief_complaint'] as String?,
      symptoms: json['symptoms'] as String?,
      medicalHistory: json['medical_history'] as String?,
      surgicalHistory: json['surgical_history'] as String?,
      allergicHistory: json['allergic_history'] as String?,
      smokingStatus: json['smoking_status'] as String?,
      signs: json['signs'] as String?,
      vitalSigns: json['vital_signs'] as String?,
      clinicalExaminationResults:
          json['clinical_examination_results'] as String?,
      diagnosis: json['diagnosis'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Case copyWith({
    String? chiefComplaint,
    String? symptoms,
    String? medicalHistory,
    String? surgicalHistory,
    String? allergicHistory,
    String? smokingStatus,
    String? signs,
    String? vitalSigns,
    String? clinicalExaminationResults,
    String? diagnosis,
  }) {
    return Case(
      id: id,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      symptoms: symptoms ?? this.symptoms,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      surgicalHistory: surgicalHistory ?? this.surgicalHistory,
      allergicHistory: allergicHistory ?? this.allergicHistory,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      signs: signs ?? this.signs,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      clinicalExaminationResults:
          clinicalExaminationResults ?? this.clinicalExaminationResults,
      diagnosis: diagnosis ?? this.diagnosis,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
