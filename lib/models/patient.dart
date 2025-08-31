import 'package:health_bridge/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: (json['id'] ?? 0) as int,
      userId: (json['user_id'] ?? 0) as int,
      birthDate: (json['birth_date']?.toString() ?? '') as String,
      gender: (json['gender']?.toString() ?? '') as String,
      phone: (json['phone']?.toString() ?? '') as String,
      chronicDiseases: (json['chronic_diseases']?.toString() ?? '') as String,
      createdAt: (json['created_at']?.toString() ?? '') as String,
      updatedAt: (json['updated_at']?.toString() ?? '') as String,
      casesCount: json['cases_count'] != null
          ? int.tryParse(json['cases_count'].toString())
          : null,
      user: User.fromJson(json['user'] ?? {}), // ✅ افصل بيانات user
    );
  }

  // دالة مساعدة لمعالجة الاستجابات المختلفة
  factory PatientModel.fromDynamicResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return PatientModel.fromJson(data);
    } else {
      throw Exception('Invalid patient data format');
    }
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

  static Future<PatientModel> getPatientFromPrefs(
      SharedPreferences prefs) async {
    final user = User(
      id: prefs.getInt('user_id'),
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      role: prefs.getString('user_role'),
      isApproved: prefs.getInt('user_isApproved'),
      profilePicture: prefs.getString('user_profilePicture'),
      createdAt: prefs.getString('user_createdAt'),
      updatedAt: prefs.getString('user_updatedAt'),
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

  // fromJson من تسجيل الدخول
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
}
