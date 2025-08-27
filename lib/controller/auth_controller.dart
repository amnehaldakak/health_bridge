import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/constant/link.dart';
import 'package:health_bridge/models/doctor.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/content/get_device_name.dart';

// حالات المصادقة
abstract class AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final DoctorModel? doctor;
  final PatientModel? patient;
  final String token;

  Authenticated({
    required this.user,
    this.doctor,
    this.patient,
    required this.token,
  });
}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Controller للمصادقة
class AuthController extends StateNotifier<AuthState> {
  final ApiService apiService;
  final SharedPreferences prefs;

  AuthController({required this.apiService, required this.prefs})
      : super(Unauthenticated()) {
    checkAuthStatus();
  }

  // التحقق من حالة المصادقة عند بدء التطبيق
  Future<void> checkAuthStatus() async {
    try {
      final token = prefs.getString('token');
      if (token != null) {
        final userId = prefs.getInt('user_id');
        final userName = prefs.getString('user_name');
        final userEmail = prefs.getString('user_email');
        final userRole = prefs.getString('user_role');
        final userIsApproved = prefs.getInt('user_isApproved');
        final userProfilePicture = prefs.getString('user_profilePicture');
        final userCreatedAt = prefs.getString('user_createdAt');
        final userUpdatedAt = prefs.getString('user_updatedAt');

        if (userId != null &&
            userName != null &&
            userEmail != null &&
            userRole != null) {
          final user = User(
            id: userId,
            name: userName,
            email: userEmail,
            role: userRole,
            isApproved: userIsApproved ?? 0,
            profilePicture: userProfilePicture ?? '',
            createdAt: userCreatedAt ?? '',
            updatedAt: userUpdatedAt ?? '',
          );

          DoctorModel? doctor;
          PatientModel? patient;

          if (userRole == 'doctor') {
            final doctorId = prefs.getInt('doctor_id');
            final doctorUserId = prefs.getInt('doctor_userId');
            final doctorSpecialization =
                prefs.getString('doctor_specialization');
            final doctorCertificatePath =
                prefs.getString('doctor_certificatePath');
            final doctorVerificationStatus =
                prefs.getString('doctor_verificationStatus');
            final doctorCreatedAt = prefs.getString('doctor_createdAt');
            final doctorUpdatedAt = prefs.getString('doctor_updatedAt');

            if (doctorId != null && doctorUserId != null) {
              doctor = DoctorModel(
                id: doctorId,
                userId: doctorUserId,
                specialization: doctorSpecialization ?? '',
                certificatePath: doctorCertificatePath ?? '',
                verificationStatus: doctorVerificationStatus ?? '',
                createdAt: doctorCreatedAt ?? '',
                updatedAt: doctorUpdatedAt ?? '',
              );
            }
          } else if (userRole == 'patient') {
            final patientId = prefs.getInt('patient_id');
            final patientUserId = prefs.getInt('patient_userId');
            final patientBirthDate = prefs.getString('patient_birthDate');
            final patientGender = prefs.getString('patient_gender');
            final patientPhone = prefs.getString('patient_phone');
            final patientChronicDiseases =
                prefs.getString('patient_chronicDiseases');
            final patientCreatedAt = prefs.getString('patient_createdAt');
            final patientUpdatedAt = prefs.getString('patient_updatedAt');

            if (patientId != null && patientUserId != null) {
              patient = PatientModel(
                id: patientId,
                userId: patientUserId,
                birthDate: patientBirthDate ?? '',
                gender: patientGender ?? '',
                phone: patientPhone ?? '',
                chronicDiseases: patientChronicDiseases ?? '',
                createdAt: patientCreatedAt ?? '',
                updatedAt: patientUpdatedAt ?? '',
                user: user,
              );
            }
          }

          state = Authenticated(
            user: user,
            doctor: doctor,
            patient: patient,
            token: token,
          );
        } else {
          // إذا كانت البيانات غير مكتملة، نمسح كل شيء ونبدأ من جديد
          await _clearAllUserData();
          state = Unauthenticated();
        }
      }
    } catch (e) {
      print('خطأ في checkAuthStatus: $e');
      state = AuthError('فشل في تحميل بيانات المستخدم');
    }
  }

  // تسجيل الدخول
  Future<void> login(String email, String password) async {
    state = AuthLoading();

    try {
      final deviceName = await getDeviceName();
      final loginData = {
        "email": email,
        "password": password,
        "device_name": "mobile",
      };

      const apiUrl = '$serverLink$loginLink';
      print("URL: $apiUrl");
      print("Data: $loginData");

      final response = await apiService.postRequest(apiUrl, loginData);
      print("Response: $response");

      // التحقق من أن response ليس null وأنه من النوع Map
      if (response == null) {
        state = AuthError('لا يوجد استجابة من السيرفر');
        return;
      }

      if (response is! Map<String, dynamic>) {
        state =
            AuthError('استجابة غير متوقعة من السيرفر: ${response.runtimeType}');
        return;
      }

      // التحقق من وجود خطأ في الاستجابة
      if (response.containsKey('error')) {
        state = AuthError(response['error'] ?? 'حدث خطأ غير معروف');
        return;
      }

      if (response['token'] != null) {
        final token = response['token'].toString();

        // التحقق من وجود user في الاستجابة
        if (response['user'] == null) {
          state = AuthError('بيانات المستخدم غير متوفرة في الاستجابة');
          return;
        }

        if (response['user'] is! Map<String, dynamic>) {
          state = AuthError('بيانات المستخدم غير صحيحة');
          return;
        }

        final userData = response['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);

        // حفظ التوكن وبيانات المستخدم
        await prefs.setString('token', token);
        await prefs.setInt('user_id', user.id ?? 0);
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_role', user.role ?? '');
        await prefs.setInt('user_isApproved', user.isApproved ?? 0);
        await prefs.setString('user_profilePicture', user.profilePicture ?? '');
        await prefs.setString('user_createdAt', user.createdAt ?? '');
        await prefs.setString('user_updatedAt', user.updatedAt ?? '');

        DoctorModel? doctor;
        PatientModel? patient;

        // في حالة الطبيب
        if (user.role == 'doctor') {
          final doctorData = response['doctor'] as Map<String, dynamic>;
          doctor = DoctorModel.fromJson(doctorData);

          await prefs.setInt('doctor_id', doctor.id);
          await prefs.setInt('doctor_userId', doctor.userId);
          await prefs.setString(
              'doctor_specialization', doctor.specialization ?? '');
          await prefs.setString(
              'doctor_certificatePath', doctor.certificatePath ?? '');
          await prefs.setString(
              'doctor_verificationStatus', doctor.verificationStatus);
          await prefs.setString('doctor_createdAt', doctor.createdAt);
          await prefs.setString('doctor_updatedAt', doctor.updatedAt);
        }

        // في حالة المريض
        else if (user.role == 'patient') {
          final patientData = response['patient'] as Map<String, dynamic>;
          print('patientData $patientData-------------------');
          patient = PatientModel.fromLoginResponse(patientData, userData);
          print(patient.user.email);
          await prefs.setInt('patient_id', patient.id);
          await prefs.setInt('patient_userId', patient.userId);
          await prefs.setString('patient_birthDate', patient.birthDate);
          await prefs.setString('patient_gender', patient.gender);
          await prefs.setString('patient_phone', patient.phone);
          await prefs.setString(
              'patient_chronicDiseases', patient.chronicDiseases);
          await prefs.setString('patient_createdAt', patient.createdAt);
          await prefs.setString('patient_updatedAt', patient.updatedAt);
          print('-------------------------end');
        }

        state = Authenticated(
          user: user,
          doctor: doctor,
          patient: patient,
          token: token,
        );
      } else if (response['is_approved'] != null &&
          response['is_approved'] == false) {
        state = AuthError(
            response['message'] ?? 'في انتظار مراجعة شهادتك من الإدارة');
      } else {
        final errorMessage = response['message'] ??
            response['error'] ??
            'حدث خطأ أثناء تسجيل الدخول';
        state = AuthError(errorMessage);
      }
    } catch (e) {
      print('تفاصيل الخطأ: $e');
      print('نوع الخطأ: ${e.runtimeType}');
      state = AuthError("خطأ في الاتصال: ${e.toString()}");
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      final token = prefs.getString('token');

      // إذا كان هناك token، نرسل طلب تسجيل الخروج إلى السيرفر
      if (token != null) {
        try {
          final result = await apiService.logout(token);
          if (result != null &&
              result is Map<String, dynamic> &&
              !(result['success'] ?? false)) {
            print('تحذير: ${result['message']}');
          }
        } catch (e) {
          print('تحذير: فشل إرسال طلب تسجيل الخروج إلى السيرفر: $e');
        }
      }

      // مسح جميع البيانات المحفوظة محلياً
      await _clearAllUserData();

      state = Unauthenticated();
    } catch (e) {
      print('خطأ أثناء تسجيل الخروج: $e');
      // حتى إذا فشل طلب السيرفر، نمسح البيانات المحلية
      await _clearAllUserData();
      state = Unauthenticated();
    }
  }

  // دالة مساعدة لمسح جميع البيانات
  Future<void> _clearAllUserData() async {
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_isApproved');
    await prefs.remove('user_profilePicture');
    await prefs.remove('user_createdAt');
    await prefs.remove('user_updatedAt');

    await prefs.remove('doctor_id');
    await prefs.remove('doctor_userId');
    await prefs.remove('doctor_specialization');
    await prefs.remove('doctor_certificatePath');
    await prefs.remove('doctor_verificationStatus');
    await prefs.remove('doctor_createdAt');
    await prefs.remove('doctor_updatedAt');

    await prefs.remove('patient_id');
    await prefs.remove('patient_userId');
    await prefs.remove('patient_birthDate');
    await prefs.remove('patient_gender');
    await prefs.remove('patient_phone');
    await prefs.remove('patient_chronicDiseases');
    await prefs.remove('patient_createdAt');
    await prefs.remove('patient_updatedAt');
  }
}
