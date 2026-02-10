import 'dart:io';

class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? passwordConfirmation;
  final File? profileImage;
  String? profilePicture;
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
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      role: (json['role'] ?? 'patient') as String,
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

  /// دالة copyWith لتعديل أي حقل بدون التأثير على الباقي
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
    File? profileImage,
    String? profilePicture,
    String? role,
    int? isApproved,
    String? emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      profileImage: profileImage ?? this.profileImage,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
