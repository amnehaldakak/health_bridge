import 'package:health_bridge/models/user.dart';

class DoctorModel {
  int? id;
  int? userId;
  String? specialization;
  String? clinicAddress;
  String? clinicPhone;
  String? certificatePath;
  String? verificationStatus;
  String? rejectionReason;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;

  DoctorModel({
    this.id,
    this.userId,
    this.specialization,
    this.clinicAddress,
    this.clinicPhone,
    this.certificatePath,
    this.verificationStatus,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      specialization: json['specialization'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      clinicPhone: json['clinic_phone'] as String?,
      certificatePath: json['certificate_path'] as String?,
      verificationStatus: json['verification_status'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'specialization': specialization,
      'clinic_address': clinicAddress,
      'clinic_phone': clinicPhone,
      'certificate_path': certificatePath,
      'verification_status': verificationStatus,
      'rejection_reason': rejectionReason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
