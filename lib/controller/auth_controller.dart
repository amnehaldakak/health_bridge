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
  final SharedPreferences prefs; // ✅ استخدم provider هنا

  AuthController({
    required this.apiService,
    required this.prefs,
  }) : super(Unauthenticated()) {
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
            final doctorClinicAddress = prefs.getString('doctor_clinicAddress');
            final doctorClinicPhone = prefs.getString('doctor_clinicPhone');
            final doctorRejectionReason =
                prefs.getString('doctor_rejectionReason');

            if (doctorId != null && doctorUserId != null) {
              doctor = DoctorModel(
                id: doctorId,
                userId: doctorUserId,
                specialization: doctorSpecialization ?? '',
                certificatePath: doctorCertificatePath ?? '',
                verificationStatus: doctorVerificationStatus ?? '',
                createdAt: DateTime.tryParse(doctorCreatedAt ?? ''),
                updatedAt: DateTime.tryParse(
                    doctorUpdatedAt ?? ''), // يجب أن يكون DateTime? وليس String
                clinicAddress: doctorClinicAddress ?? '',
                clinicPhone: doctorClinicPhone ?? '',
                rejectionReason: doctorRejectionReason, // يمكن أن يكون null
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
        "device_name": deviceName,
      };

      const apiUrl = '$serverLink$loginLink';
      final response = await apiService.postRequest(apiUrl, loginData);

      if (response == null) {
        state = AuthError('لا يوجد استجابة من السيرفر');
        return;
      }

      if (response is! Map<String, dynamic>) {
        state =
            AuthError('استجابة غير متوقعة من السيرفر: ${response.runtimeType}');
        return;
      }

      if (response.containsKey('error')) {
        state = AuthError(response['error'] ?? 'حدث خطأ غير معروف');
        return;
      }

      if (response['token'] != null) {
        final token = response['token'].toString();
        await prefs.setString('token', token);

        if (response['user'] == null ||
            response['user'] is! Map<String, dynamic>) {
          state = AuthError('بيانات المستخدم غير متوفرة أو غير صحيحة');
          return;
        }

        final userData = response['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);

        // بناء رابط الصورة الكامل
        String profilePictureUrl = '';
        if (user.role == 'doctor' && response['doctor_image_url'] != null) {
          profilePictureUrl = response['doctor_image_url'];
        } else if (user.role == 'patient' &&
            response['patient_image_url'] != null) {
          profilePictureUrl = response['patient_image_url'];
        } else if (userData['profile_picture'] != null &&
            userData['profile_picture'] != '') {
          // fallback: بناء الرابط لو لم يرسل السيرفر الرابط الكامل
          profilePictureUrl =
              userData['profile_picture'].toString().startsWith('http')
                  ? userData['profile_picture']
                  : '$serverLink${userData['profile_picture']}';
        }
        user.profilePicture = profilePictureUrl;
        print(user.profilePicture);

        // حفظ بيانات المستخدم
        await prefs.setInt('user_id', user.id ?? 0);
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_role', user.role ?? '');
        await prefs.setInt('user_isApproved', user.isApproved ?? 0);
        await prefs.setString('user_profilePicture', profilePictureUrl);
        await prefs.setString('user_createdAt', user.createdAt ?? '');
        await prefs.setString('user_updatedAt', user.updatedAt ?? '');

        DoctorModel? doctor;
        PatientModel? patient;

        if (user.role == 'doctor' && response['doctor'] != null) {
          final doctorData = response['doctor'] as Map<String, dynamic>;
          doctor = DoctorModel.fromJson(doctorData);

          await prefs.setInt('doctor_id', doctor.id ?? 0);
          await prefs.setInt('doctor_userId', doctor.userId ?? 0);
          await prefs.setString(
              'doctor_specialization', doctor.specialization ?? '');
          await prefs.setString(
              'doctor_certificatePath', doctor.certificatePath ?? '');
          await prefs.setString(
              'doctor_verificationStatus', doctor.verificationStatus ?? '');
          await prefs.setString(
              'doctor_createdAt', doctor.createdAt.toString());
          await prefs.setString(
              'doctor_updatedAt', doctor.updatedAt.toString());
          await prefs.setString(
              'doctor_clinicAddress', doctor.clinicAddress ?? '');
          await prefs.setString('doctor_clinicPhone', doctor.clinicPhone ?? '');
          await prefs.setString(
              'doctor_rejectionReason', doctor.rejectionReason ?? '');
        } else if (user.role == 'patient' && response['patient'] != null) {
          final patientData = response['patient'] as Map<String, dynamic>;
          patient = PatientModel.fromLoginResponse(patientData, userData);

          await prefs.setInt('patient_id', patient.id);
          await prefs.setInt('patient_userId', patient.userId);
          await prefs.setString('patient_birthDate', patient.birthDate);
          await prefs.setString('patient_gender', patient.gender);
          await prefs.setString('patient_phone', patient.phone);
          await prefs.setString(
              'patient_chronicDiseases', patient.chronicDiseases);
          await prefs.setString('patient_createdAt', patient.createdAt);
          await prefs.setString('patient_updatedAt', patient.updatedAt);
        }

        state = Authenticated(
          user: user,
          doctor: doctor,
          patient: patient,
          token: token,
        );
      } else {
        final errorMessage = response['message'] ??
            response['error'] ??
            'حدث خطأ أثناء تسجيل الدخول';
        state = AuthError(errorMessage);
      }
    } catch (e) {
      print('تفاصيل الخطأ: $e');
      state = AuthError("خطأ في الاتصال: ${e.toString()}");
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      await _clearAllUserData();
      state = Unauthenticated();
    } catch (e) {
      print('خطأ أثناء تسجيل الخروج: $e');
      await _clearAllUserData();
      state = Unauthenticated();
    }
  }

  // مسح كل البيانات
  Future<void> _clearAllUserData() async {
    await prefs.clear();
  }
}
