import 'package:health_bridge/main.dart';
import 'package:health_bridge/models/user.dart';

class PatientModel {
  final int id;
  final int userId;
  final String birthDate;
  final String gender;
  final String phone;
  final String chronicDiseases;
  final String createdAt;
  final String updatedAt;
  final int? casesCount;
  final User user;

  PatientModel({
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

  // دالة fromJson للمريض عندما تأتي البيانات منفصلة
  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      birthDate: json['birth_date']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      chronicDiseases: json['chronic_diseases']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      casesCount: json['cases_count'] != null
          ? int.tryParse(json['cases_count'].toString())
          : null,
      user: User.fromJson(json), // في هذه الحالة، البيانات تأتي منفصلة
    );
  }

  // دالة fromJson للمريض عندما تأتي البيانات من استجابة تسجيل الدخول
  factory PatientModel.fromLoginResponse(
      Map<String, dynamic> patientData, Map<String, dynamic> userData) {
    return PatientModel(
      id: patientData['id'] ?? 0,
      userId: patientData['user_id'] ?? 0,
      birthDate: patientData['birth_date']?.toString() ?? '',
      gender: patientData['gender']?.toString() ?? '',
      phone: patientData['phone']?.toString() ?? '',
      chronicDiseases: patientData['chronic_diseases']?.toString() ?? '',
      createdAt: patientData['created_at']?.toString() ?? '',
      updatedAt: patientData['updated_at']?.toString() ?? '',
      casesCount: patientData['cases_count'] != null
          ? int.tryParse(patientData['cases_count'].toString())
          : null,
      user: User.fromJson(userData),
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

  static Future<PatientModel> getPatientFromPrefs() async {
    // جلب بيانات المستخدم من SharedPreferences
    final userId = prefs.getInt('user_id') ?? 0;
    final userName = prefs.getString('user_name') ?? '';
    final userEmail = prefs.getString('user_email') ?? '';
    final userRole = prefs.getString('user_role') ?? '';
    final userIsApproved = prefs.getInt('user_isApproved') ?? 0;
    final userProfilePicture = prefs.getString('user_profilePicture') ?? '';
    final userCreatedAt = prefs.getString('user_createdAt') ?? '';
    final userUpdatedAt = prefs.getString('user_updatedAt') ?? '';

    final user = User(
      id: userId,
      name: userName,
      email: userEmail,
      role: userRole,
      isApproved: userIsApproved,
      profilePicture: userProfilePicture,
      createdAt: userCreatedAt,
      updatedAt: userUpdatedAt,
    );

    return PatientModel(
      id: prefs.getInt('patient_id') ?? 0,
      userId: prefs.getInt('patient_userId') ?? 0,
      birthDate: prefs.getString('patient_birthDate') ?? '',
      gender: prefs.getString('patient_gender') ?? '',
      phone: prefs.getString('patient_phone') ?? '',
      chronicDiseases: prefs.getString('patient_chronicDiseases') ?? '',
      createdAt: prefs.getString('patient_createdAt') ?? '',
      updatedAt: prefs.getString('patient_updatedAt') ?? '',
      user: user,
    );
  }
}
