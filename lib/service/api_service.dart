import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health_bridge/constant/link.dart';
import 'package:health_bridge/main.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final SharedPreferences prefs;

  ApiService({required this.prefs});

  /// الهيدر الديناميكي الذي يتحدث تلقائياً بعد كل تسجيل دخول
  Map<String, String> get headers {
    final token = prefs.getString('token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /// دالة عامة لإرسال POST request
  Future<Map<String, dynamic>> postRequest(
      String url, Map<String, dynamic> body) async {
    print('---------------------${jsonEncode(body)}');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed POST request: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('POST request error: $e');
    }
  }

  // register api function
  Future<Map<String, dynamic>> registerUser(
      String name, String email, String password, String role) async {
    String url = 'https://$serverLink$registerLink'; // ضع رابط الـ API هنا

    Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
      'role': role, // إضافة الدور
    };

    try {
      // نستخدم الدالة العامة postRequest
      Map<String, dynamic> response = await postRequest(url, body);
      return response;
    } catch (e) {
      throw Exception('فشل إنشاء الحساب: $e');
    }
  }

  /// تسجيل الطبيب
  static Future<http.StreamedResponse> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String specialization,
    required String clinicAddress,
    required String clinicPhone,
    required File certificateFile,
    File? profilePhoto, // 👈 إضافة اختيارية
  }) async {
    var url = Uri.parse("$serverLink$registerLink");

    var request = http.MultipartRequest("POST", url);

    // البيانات النصية
    request.fields.addAll({
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
      "role": "doctor",
      "specialization": specialization,
      "clinic_address": clinicAddress,
      "clinic_phone": clinicPhone,
    });

    // ملف الشهادة
    request.files.add(
      await http.MultipartFile.fromPath(
        "certificate_path",
        certificateFile.path,
      ),
    );

    // صورة البروفايل (اختيارية)
    if (profilePhoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "profile_picture",
          profilePhoto.path,
        ),
      );
    }

    return await request.send();
  }

  static Future<http.StreamedResponse> registerPatient({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String birthDate,
    required String gender,
    required String phone,
    required String chronicDiseases,
    File? profilePhoto, // 👈 اختياري
  }) async {
    var url = Uri.parse("$serverLink$registerLink");

    var request = http.MultipartRequest("POST", url);

    // البيانات النصية
    request.fields.addAll({
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
      "role": "patient",
      "birth_date": birthDate,
      "gender": gender,
      "phone": phone,
      "chronic_diseases": chronicDiseases,
    });

    // الملف الشخصي إذا موجود
    if (profilePhoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "profile_picture", // اسم الحقل في السيرفر
          profilePhoto.path,
        ),
      );
    }

    return await request.send();
  }

  // get the patients of the current doctor
  Future<List<PatientModel>> getDoctorPatients() async {
    print(headers);
    // headers['Content-Type'] = 'text/plain';
    // print(headers);

    try {
      String url = "$serverLink$getDoctorPatientsLink";
      print('Request URL: $url');

      final response = await http.get(Uri.parse(url), headers: headers);
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          List<dynamic> patientsJson = data["patients"];

          // تحقق من البيانات قبل تحويلها
          if (patientsJson != null) {
            return patientsJson.map((p) {
              try {
                return PatientModel.fromJson(p);
              } catch (e) {
                print('Error parsing patient: $e');
                print('Problematic patient data: $p');
                // يمكنك إرجاع patient افتراضي أو إعادة throw الخطأ
                throw Exception("Failed to parse patient data: $e");
              }
            }).toList();
          } else {
            throw Exception("No patients data found");
          }
        } else {
          throw Exception(
              "Failed to fetch patients: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print('Exception in getDoctorPatients: $e');
      rethrow;
    }
  }

  /// 🔹 التابع الذكي حسب الرول
  Future<List<Case>> getPatientCasesByRole(String? role, int patientId) async {
    if (role == "doctor") {
      return getPatientCasesByDoctor(patientId);
    } else if (role == "patient") {
      return getPatientCasesForPatient(patientId);
    } else {
      return [];
    }
  }

  /// تابع للطبيب
  Future<List<Case>> getPatientCasesByDoctor(int patientId) async {
    String url = '$serverLink$getPatientCasesByCurrentDoctor/$patientId';
    print("Doctor URL: $url");
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final casesJson = data['cases'] as List;
        return casesJson.map((c) => Case.fromJson(c)).toList();
      } else {
        throw Exception("فشل في جلب الحالات: ${data['message'] ?? ''}");
      }
    } else {
      throw Exception("خطأ في الاتصال بالسيرفر: ${response.statusCode}");
    }
  }

  /// تابع للمريض
  Future<List<Case>> getPatientCasesForPatient(int patientId) async {
    String url = '$serverLink$getPatientCasesLink/$patientId';
    print("Patient URL: $url");
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((c) => Case.fromJson(c)).toList();
    } else {
      throw Exception("خطأ في الاتصال بالسيرفر: ${response.statusCode}");
    }
  }

  Future<http.StreamedResponse> casePatient({
    required int patientId,
    required String chiefComplaint,
    required String symptoms,
    String? medicalHistory,
    String? surgicalHistory,
    String? allergicHistory,
    String? smokingStatus,
    String? signs,
    String? vitalSigns,
    String? clinicalExaminationResults,
    required String diagnosis,
    File? echo,
    File? labTest,
  }) async {
    try {
      var url = Uri.parse("$serverLink$storePatient");
      if (kDebugMode) {
        print('🌐 URL: $url');
      }

      var request = http.MultipartRequest("POST", url);

      // إلزامية
      request.fields["patient_id"] = patientId.toString();
      request.fields["chief_complaint"] = chiefComplaint;
      request.fields["symptoms"] = symptoms;
      request.fields["diagnosis"] = diagnosis;

      // اختياري + فقط إذا مش null أو مش فاضي
      if (medicalHistory != null && medicalHistory.trim().isNotEmpty) {
        request.fields["medical_history"] = medicalHistory;
      }
      if (surgicalHistory != null && surgicalHistory.trim().isNotEmpty) {
        request.fields["surgical_history"] = surgicalHistory;
      }
      if (allergicHistory != null && allergicHistory.trim().isNotEmpty) {
        request.fields["allergic_history"] = allergicHistory;
      }
      if (smokingStatus != null && smokingStatus.trim().isNotEmpty) {
        request.fields["smoking_status"] = smokingStatus;
      }
      if (signs != null && signs.trim().isNotEmpty) {
        request.fields["signs"] = signs;
      }
      if (vitalSigns != null && vitalSigns.trim().isNotEmpty) {
        request.fields["vital_signs"] = vitalSigns;
      }
      if (clinicalExaminationResults != null &&
          clinicalExaminationResults.trim().isNotEmpty) {
        request.fields["clinical_examination_results"] =
            clinicalExaminationResults;
      }

      if (kDebugMode) {
        print('📋 Fields: ${request.fields}');
      }

      // الملفات إذا موجودة
      if (echo != null) {
        final echoBytes = await echo.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            "echo",
            echoBytes,
            filename: echo.path.split('/').last,
          ),
        );
      }

      if (labTest != null) {
        final labTestBytes = await labTest.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            "lab_test",
            labTestBytes,
            filename: labTest.path.split('/').last,
          ),
        );
      }

      // الهيدر
      request.headers.addAll(headers);

      if (kDebugMode) {
        print('🚀 Sending request...');
        print('🔑 Headers: ${request.headers}');
      }

      final response = await request.send();

      if (kDebugMode) {
        print('📨 Response status: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in casePatient: $e');
      }
      rethrow;
    }
  }

  static Future<String> sendMessage(String question) async {
    try {
      final response = await http.post(
        Uri.parse("${serverLink2}ask"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_question": question}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["answer"]["result"] ?? "No response from server.";
      } else {
        return "Server error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error connecting to server: $e";
    }
  }

  Future<http.StreamedResponse> updateMedicalCase({
    required int caseId,
    required String chiefComplaint,
    required String symptoms,
    required String medicalHistory,
    required String surgicalHistory,
    required String allergicHistory,
    required String smokingStatus,
    required String signs,
    required String vitalSigns,
    required String clinicalExaminationResults,
    required String diagnosis,
    File? echo,
    File? labTest,
  }) async {
    try {
      var url = Uri.parse("$serverLink$updateCase/$caseId");
      if (kDebugMode) {
        print('🌐 Update URL: $url');
      }

      var request = http.MultipartRequest("POST", url);
      // أو استخدام PUT إذا كان السيرفر يتطلب ذلك
      // var request = http.MultipartRequest("PUT", url);

      // البيانات النصية للتحديث
      request.fields.addAll({
        "chief_complaint": chiefComplaint,
        "symptoms": symptoms,
        "medical_history": medicalHistory,
        "surgical_history": surgicalHistory,
        "allergic_history": allergicHistory,
        "smoking_status": smokingStatus,
        "signs": signs,
        "vital_signs": vitalSigns,
        "clinical_examination_results": clinicalExaminationResults,
        "diagnosis": diagnosis,
      });

      if (kDebugMode) {
        print('📋 Update Fields: ${request.fields}');
      }

      // الملفات إذا موجودة
      if (echo != null) {
        if (kDebugMode) {
          print('📎 Echo file: ${echo.path}');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            "echo",
            echo.path,
          ),
        );
      }
      if (labTest != null) {
        if (kDebugMode) {
          print('📎 Lab test file: ${labTest.path}');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            "lab_test",
            labTest.path,
          ),
        );
      }

      // استخدام الهدر الجاهز
      request.headers.addAll(headers);

      if (kDebugMode) {
        print('🚀 Sending update request...');
        print('🔑 Headers: ${request.headers}');
      }

      final response = await request.send();

      if (kDebugMode) {
        print('📨 Update response status: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in updateMedicalCase: $e');
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getPendingApprovals() async {
    final url = Uri.parse("$serverLink/pendingApprovals");

    final response = await http.get(url, headers: headers);
    // 🔹 getHeaders() هي الدالة الجاهزة عندك اللي ترجع الهيدر

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("فشل في جلب الموافقات: ${response.body}");
    }
  }

  Future<void> storePatientMedication({
    required String name,
    required String dosage,
    required int frequency,
    required int duration,
    required String startDate, // بصيغة yyyy-MM-dd
    required String firstDoseTime, // بصيغة HH:mm
  }) async {
    final url = Uri.parse("$serverLink$storePatientMedicationLink");
    print(url);
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "name": name,
        "dosage": dosage,
        "frequency": frequency,
        "duration": duration,
        "start_date": startDate,
        "first_dose_time": firstDoseTime,
      }),
    );
    print('${response.statusCode}----------------');
    print(jsonEncode({
      "name": name,
      "dosage": dosage,
      "frequency": frequency,
      "duration": duration,
      "start_date": startDate,
      "first_dose_time": firstDoseTime,
    }));
    if (response.statusCode != 201) {
      throw Exception("Failed to store medication: ${response.body}");
    }
  }

  Future<dynamic> storeHealthValue(
    int diseaseId,
    Map<String, dynamic> data,
  ) async {
    try {
      String url = '$serverLink$storeValueLink/$diseaseId';
      print(url);
      print(headers);
      print(data);
      print(json.encode(data));
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تخزين البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // عرض القيم الصحية لمرض معين
  Future<dynamic> showHealthValues(int diseaseId) async {
    String url = '$serverLink$showValueLink/$diseaseId';
    print(url);
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(Duration(seconds: 30));
      print('------------------------------${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في جلب البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // حذف قيمة صحية
  Future<dynamic> deleteHealthValue(int valueId) async {
    String url = '$serverLink$deleteValueLink/$valueId';
    print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في حذف البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // دالة تسجيل الخروج
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$serverLink$logoutLink'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'تم تسجيل الخروج بنجاح'};
      } else {
        return {
          'success': false,
          'message': 'فشل تسجيل الخروج: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ================== Profile APIs ==================

  /// عرض البروفايل
  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse("$serverLink$showProfileLink");
    try {
      final response = await http.get(url, headers: headers);
      print('showProfileLink${response.body}');
      print(response.statusCode);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("فشل في جلب البروفايل: ${response.body}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }

  /// تحديث البروفايل (داتا + صورة اختيارية)
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    File? profilePicture,
    Map<String, String>? extraFields, // بيانات إضافية (مريض/دكتور)
  }) async {
    final url = Uri.parse("$serverLink$updateProfileLink");

    var request = http.MultipartRequest("POST", url);
    request.headers.addAll(headers);

    if (name != null) request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;

    if (extraFields != null) {
      request.fields.addAll(extraFields);
    }

    if (profilePicture != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
            "profile_picture", profilePicture.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("فشل في تحديث البروفايل: ${response.body}");
    }
  }

  /// حذف البروفايل
  Future<Map<String, dynamic>> deleteProfile() async {
    final url = Uri.parse("$serverLink$destroyProfileLink");
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("فشل في حذف الحساب: ${response.body}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }

  // إضافة مجموعة الأدوية للطبيب
  Future<http.Response> storeMedicationGroupForDoctor({
    required int caseId,
    required List<Map<String, dynamic>> medications,
  }) async {
    String url = '$serverLink$storeMedicationGroupLink/$caseId';
    print(url);

    final uri = Uri.parse(url);
    print(medications);
    // إرسال البيانات كـ JSON
    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode({
        "medications": medications,
      }),
    );

    return response;
  }
}
