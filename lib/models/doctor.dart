class DoctorModel {
  final int id;
  final int userId;
  final String? specialization;
  final String? certificatePath;
  final String verificationStatus;
  final String createdAt;
  final String updatedAt;

  // الحقول الجديدة
  final String? clinicAddress;
  final String? clinicPhone;
  final String? rejectionReason;

  DoctorModel({
    required this.id,
    required this.userId,
    this.specialization,
    this.certificatePath,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
    this.clinicAddress,
    this.clinicPhone,
    this.rejectionReason,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'],
      userId: json['user_id'],
      specialization: json['specialization'],
      certificatePath: json['certificate_path'],
      verificationStatus: json['verification_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],

      // الحقول الجديدة
      clinicAddress: json['clinic_address'],
      clinicPhone: json['clinic_phone'],
      rejectionReason: json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'specialization': specialization,
      'certificate_path': certificatePath,
      'verification_status': verificationStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,

      // الحقول الجديدة
      'clinic_address': clinicAddress,
      'clinic_phone': clinicPhone,
      'rejection_reason': rejectionReason,
    };
  }
}
