import 'dart:io';

class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? passwordConfirmation;
  final File? profileImage;
  final String? profilePicture;
  final String role;
  final int? isApproved;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.passwordConfirmation,
    this.profileImage,
    this.profilePicture,
    required this.role,
    this.isApproved,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: (json['name'] ?? '') as String, // safe default
      email: (json['email'] ?? '') as String, // safe default

      // بعض الـ responses ما بيرجع email_verified_at
      emailVerifiedAt: json['email_verified_at'] as String?,

      // ✅ إذا ما رجع role من السيرفر، نخلي default "patient"
      role: (json['role'] ?? 'patient') as String,

      // ✅ is_approved ممكن يجي bool أو int أو null
      isApproved: json['is_approved'] is bool
          ? ((json['is_approved'] as bool) ? 1 : 0)
          : (json['is_approved'] as int?),

      profilePicture: json['profile_picture'] as String?,

      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'profile_picture': profilePicture,
      'role': role,
      'is_approved': isApproved,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
