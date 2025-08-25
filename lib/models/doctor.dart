class Doctor {
  final int id;
  final int userId;
  final String? specialization;
  final String? certificatePath;
  final String verificationStatus;
  final String createdAt;
  final String updatedAt;

  Doctor({
    required this.id,
    required this.userId,
    this.specialization,
    this.certificatePath,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      userId: json['user_id'],
      specialization: json['specialization'],
      certificatePath: json['certificate_path'],
      verificationStatus: json['verification_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
    };
  }
}
