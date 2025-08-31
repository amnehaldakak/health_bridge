import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/models/doctor.dart';
import 'package:health_bridge/models/patient.dart';

class ProfileResponse {
  final User user;
  final DoctorModel? doctor;
  final PatientModel? patient;

  ProfileResponse({
    required this.user,
    this.doctor,
    this.patient,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['data'] as Map<String, dynamic>? ?? {};
    final doctorData = json['doctor'] as Map<String, dynamic>?;
    final patientData = json['patient'] as Map<String, dynamic>?;

    return ProfileResponse(
      user: User.fromJson(userData),
      doctor: doctorData != null ? DoctorModel.fromJson(doctorData) : null,
      patient: patientData != null
          ? PatientModel.fromDynamicResponse(patientData)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': user.toJson(),
      'doctor': doctor?.toJson(),
      'patient': patient?.toJson(),
    };
  }
}
