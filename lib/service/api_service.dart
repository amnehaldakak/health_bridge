import 'dart:convert';
import 'dart:io';
import 'package:health_bridge/constant/link.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ApiService {
  /// دالة عامة لإرسال POST request
  Future<Map<String, dynamic>> postRequest(
      String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
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

    // الملف
    request.files.add(
      await http.MultipartFile.fromPath(
        "certificate_path",
        certificateFile.path,
      ),
    );

    return await request.send();
  }
}
