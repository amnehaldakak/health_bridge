import 'package:health_bridge/main.dart';
import 'package:health_bridge/models/user.dart';

class Patient {
  final int id;
  final int userId;
  final String birthDate;
  final String gender;
  final String phone;
  final String chronicDiseases;
  final String createdAt;
  final String updatedAt;
  final int? casesCount;
  final User user; // ✅ ربط بالموديل User

  Patient({
    required this.id,
    required this.userId,
    required this.birthDate,
    required this.gender,
    required this.phone,
    required this.chronicDiseases,
    required this.createdAt,
    required this.updatedAt,
    this.casesCount,
    required this.user,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      userId: json['user_id'],
      birthDate: json['birth_date'] ?? '',
      gender: json['gender'] ?? '',
      phone: json['phone'] ?? '',
      chronicDiseases: json['chronic_diseases'] ?? '',
      createdAt: json['created_at'] ?? '', // التعامل مع القيم الفارغة
      updatedAt: json['updated_at'] ?? '', // التعامل مع القيم الفارغة
      casesCount: json['cases_count'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'birth_date': birthDate,
      'gender': gender,
      'phone': phone,
      'chronic_diseases': chronicDiseases,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'cases_count': casesCount,
      'user': user.toJson(),
    };
  }

  static Future<Patient> getPatientFromPrefs() async {
    final user = await User.getUserFromPrefs(); // افترضنا أن لديك هذه الدالة

    return Patient(
      id: prefs.getInt('patient_id') ?? 0,
      userId: prefs.getInt('patient_userId') ?? 0,
      birthDate: prefs.getString('patient_birthDate') ?? '',
      gender: prefs.getString('patient_gender') ?? '',
      phone: prefs.getString('patient_phone') ?? '',
      chronicDiseases: prefs.getString('patient_chronicDiseases') ?? '',
      createdAt: prefs.getString('patient_createdAt') ?? '',
      updatedAt: prefs.getString('patient_updatedAt') ?? '',
      user: user, // تم تصحيح هذا السطر
    );
  }
}
