import 'package:health_bridge/models/doctor.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/models/case.dart'; // استيراد كلاس الحالة
import 'package:timeago/timeago.dart' as timeago;

class Post {
  int? id;
  int? communityId;
  int? patientId;
  int? doctorId;
  int? caseId;
  Case? medicalCase; // 🟢 إضافة حقل الحالة الطبية
  String? title;
  String? content;
  bool? isPublic;
  DateTime? createdAt;
  DateTime? updatedAt;
  DoctorModel? doctor;
  PatientModel? patient;

  Post({
    this.id,
    this.communityId,
    this.patientId,
    this.doctorId,
    this.caseId,
    this.medicalCase, // 🟢
    this.title,
    this.content,
    this.isPublic,
    this.createdAt,
    this.updatedAt,
    this.doctor,
    this.patient,
  });

  /// 🟢 اسم الكاتب (دكتور أو مريض)
  String get authorName {
    if (doctor?.user != null) return doctor!.user!.name ?? 'Unknown Doctor';
    if (patient?.user != null) return patient!.user!.name ?? 'Unknown Patient';
    return 'Unknown';
  }

  /// 🟢 صورة الكاتب (دكتور أو مريض)
  String? get authorImageUrl {
    if (doctor?.user != null) return doctor!.user!.profilePicture;
    if (patient?.user != null) return patient!.user!.profilePicture;
    return null;
  }

  /// 🟢 وقت النشر بشكل مقروء (منذ 5 دقائق)
  String get timeAgo {
    if (createdAt == null) return '';
    return timeago.format(createdAt!, locale: 'ar'); // "منذ 5 دقائق"
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      communityId: json['community_id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      caseId: json['case_id'],
      medicalCase: json['medical_case'] != null
          ? Case.fromJson(json['medical_case']) // 🟢 إنشاء كائن الحالة
          : null,
      title: json['title'],
      content: json['content'],
      isPublic: json['is_public'] == 1 || json['is_public'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      doctor:
          json['doctor'] != null ? DoctorModel.fromJson(json['doctor']) : null,
      patient: json['patient'] != null
          ? PatientModel.fromJson(json['patient'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'community_id': communityId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'case_id': caseId,
      'medical_case': medicalCase?.toJson(), // 🟢
      'title': title,
      'content': content,
      'is_public': isPublic,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'doctor': doctor?.toJson(),
      'patient': patient?.toJson(),
    };
  }
}
