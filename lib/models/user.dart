import 'dart:io';

import 'package:health_bridge/main.dart';

class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? passwordConfirmation;
  final File? profileImage; // صورة محلية وقت التسجيل
  final String? profilePicture; // رابط الصورة من السيرفر
  final String? role;
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
    this.role,
    this.isApproved,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// استرجاع بيانات من JSON (من السيرفر)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      role: json['role'],
      isApproved: json['is_approved'] is bool
          ? (json['is_approved'] ? 1 : 0)
          : json['is_approved'],
      profilePicture: json['profile_picture'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  /// تحويل البيانات إلى JSON (مثلاً عند التسجيل)
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

  static Future<User> getUserFromPrefs() async {
    return User(
      id: prefs.getInt('user_id'),
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      password: prefs.getString('user_password'),
      passwordConfirmation: prefs.getString('user_password_confirmation'),
      profileImage: null, // لا يمكن حفظ File مباشرة في SharedPreferences
      profilePicture: prefs.getString('user_profile_picture'),
      role: prefs.getString('user_role'),
      isApproved: prefs.getInt('user_is_approved'),
      emailVerifiedAt: prefs.getString('user_email_verified_at'),
      createdAt: prefs.getString('user_created_at'),
      updatedAt: prefs.getString('user_updated_at'),
    );
  }
}
