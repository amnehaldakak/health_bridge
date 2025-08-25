import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/pages/add_medicine.dart';
import 'package:health_bridge/pages/auth/login.dart';
import 'package:health_bridge/pages/auth/signup.dart';
import 'package:health_bridge/pages/auth/doctor_info.dart';
import 'package:health_bridge/pages/doctor/add_treatment_pathway.dart';
import 'package:health_bridge/pages/doctor/doctor.dart';
import 'package:health_bridge/pages/doctor/home_doctor.dart';
import 'package:health_bridge/pages/doctor/patient_cases.dart';
import 'package:health_bridge/pages/doctor/records_doctor.dart';
import 'package:health_bridge/pages/doctor/community_doctor.dart';
import 'package:health_bridge/pages/doctor/add_records.dart';
import 'package:health_bridge/pages/doctor/patient_state.dart';
import 'package:health_bridge/pages/patient/home_patient.dart';
import 'package:health_bridge/pages/patient/chat_bot_patient.dart';
import 'package:health_bridge/pages/patient/community_patient.dart';
import 'package:health_bridge/pages/patient/medicine.dart';
import 'package:health_bridge/pages/patient/patient.dart';
import 'package:health_bridge/pages/patient/records_patient.dart';
import 'package:health_bridge/pages/patient/addbloodpre.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // صفحة تسجيل الدخول
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
    ),

    // صفحة التسجيل
    GoRoute(
      path: '/signup',
      name: 'signup',
      pageBuilder: (context, state) => const MaterialPage(child: SignUpPage()),
    ),

    // صفحة معلومات الطبيب بعد التسجيل
    GoRoute(
      path: '/doctor_info',
      name: 'doctor_info',
      pageBuilder: (context, state) {
        final user = state.extra as User;
        return MaterialPage(child: DoctorInfoPage(user: user));
      },
    ),

    // مسارات المرضى
    GoRoute(
      path: '/home_patient',
      name: 'home_patient',
      pageBuilder: (context, state) => const MaterialPage(child: Patient1()),
    ),
    GoRoute(
      path: '/chat_bot_patient',
      name: 'chat_bot_patient',
      pageBuilder: (context, state) =>
          const MaterialPage(child: ChatBotPatient()),
    ),
    GoRoute(
      path: '/community_patient',
      name: 'community_patient',
      pageBuilder: (context, state) =>
          const MaterialPage(child: CommunityPatient()),
    ),
    GoRoute(
      path: '/medicine',
      name: 'medicine',
      pageBuilder: (context, state) => const MaterialPage(child: Medicine()),
    ),
    GoRoute(
      path: '/records_patient',
      name: 'records_patient',
      pageBuilder: (context, state) => MaterialPage(child: RecordsPatient()),
    ),
    GoRoute(
      path: '/addpressure',
      name: 'addpressure',
      pageBuilder: (context, state) => const MaterialPage(child: AddBloodPre()),
    ),

    // مسارات الأطباء
    GoRoute(
      path: '/home_doctor',
      name: 'home_doctor',
      pageBuilder: (context, state) => const MaterialPage(child: Doctor()),
    ),
    GoRoute(
      path: '/records_doctor',
      name: 'records_doctor',
      pageBuilder: (context, state) =>
          const MaterialPage(child: RecordsDoctor()),
    ),
    GoRoute(
      path: '/community_doctor',
      name: 'community_doctor',
      pageBuilder: (context, state) =>
          const MaterialPage(child: CommunityDoctor()),
    ),
    GoRoute(
      path: '/add_record',
      name: 'add_record',
      pageBuilder: (context, state) => const MaterialPage(child: AddRecords()),
    ),
    GoRoute(
      path: '/patient_state',
      name: 'patient_state',
      pageBuilder: (context, state) {
        final patientCase = state.extra as Case;
        return MaterialPage(
          child: PatientState(
            patientCase: patientCase,
          ),
        );
      },
    ),
    GoRoute(
      path: '/patient_cases',
      name: 'patient_cases',
      pageBuilder: (context, state) {
        final patient1 = state.extra as Patient;
        return MaterialPage(
          child: PatientCases(
            patient: patient1,
          ),
        );
      },
    ),
    GoRoute(
      path: '/add_treatment_Pathway',
      name: 'add_treatment_Pathway',
      pageBuilder: (context, state) =>
          const MaterialPage(child: AddTreatmentPathway()),
    ),
    GoRoute(
      path: '/add_medicine',
      name: 'add_medicine',
      pageBuilder: (context, state) => MaterialPage(child: AddMedicinePage()),
    ),
  ],
  debugLogDiagnostics: true,
);
