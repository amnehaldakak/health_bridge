import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/pages/add_medicine.dart';
import 'package:health_bridge/pages/doctor/add_records.dart';
import 'package:health_bridge/pages/doctor/add_treatment_pathway.dart';
import 'package:health_bridge/pages/doctor/community_doctor.dart';
import 'package:health_bridge/pages/doctor/doctor.dart';
import 'package:health_bridge/pages/doctor/home_doctor.dart';
import 'package:health_bridge/pages/doctor/records_doctor.dart';
import 'package:health_bridge/pages/doctor/treatment_pathway.dart';
import 'package:health_bridge/pages/patient/addbloodpre.dart';
import 'package:health_bridge/pages/patient/chat_bot_patient.dart';
import 'package:health_bridge/pages/patient/community_patient.dart';
import 'package:health_bridge/pages/patient/home_patient.dart';
import 'package:health_bridge/pages/patient/medicine.dart';
import 'package:health_bridge/pages/patient/patient.dart';
import 'package:health_bridge/pages/patient/records_patient.dart';
import 'package:health_bridge/pages/swich.dart';
//

final GoRouter appRouter = GoRouter(
  initialLocation: '/swich', // تحديد الصفحة الأولى
  routes: [
    GoRoute(
      path: '/swich',
      name: 'swich',
      pageBuilder: (context, state) => const MaterialPage(child: Swich()),
      routes: [
        // إضافة مسارات فرعية
        GoRoute(
            path: 'patient',
            name: 'patient',
            pageBuilder: (context, state) =>
                const MaterialPage(child: Patient())),
        GoRoute(
          path: 'home',
          name: 'home_patient',
          pageBuilder: (context, state) =>
              const MaterialPage(child: HomePatient()),
        ),
        GoRoute(
          path: 'chat_bot',
          name: 'chat_bot_patient',
          pageBuilder: (context, state) =>
              const MaterialPage(child: ChatBotPatient()),
        ),
        GoRoute(
          path: 'medicine',
          name: 'medicine',
          pageBuilder: (context, state) =>
              const MaterialPage(child: Medicine()),
        ),
        GoRoute(
          path: 'community',
          name: 'community_patient',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CommunityPatient()),
        ),
        GoRoute(
          path: 'records',
          name: 'records_patient',
          pageBuilder: (context, state) =>
              const MaterialPage(child: RecordsPatient()),
        ),
        GoRoute(
          path: 'addpressure',
          name: 'addpressure',
          pageBuilder: (context, state) =>
              const MaterialPage(child: AddBloodPre()),
        ),
        GoRoute(
          path: 'home_doctor',
          name: 'home_doctor',
          pageBuilder: (context, state) =>
              const MaterialPage(child: HomeDoctor()),
        ),
        GoRoute(
          path: 'records_doctor',
          name: 'records_doctor',
          pageBuilder: (context, state) =>
              const MaterialPage(child: RecordsDoctor()),
        ),
        GoRoute(
          path: 'community_doctor',
          name: 'community_doctor',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CommunityDoctor()),
        ),
        GoRoute(
          path: 'doctor',
          name: 'doctor',
          pageBuilder: (context, state) => const MaterialPage(child: Doctor()),
        ),
        GoRoute(
          path: 'add_record',
          name: 'add_record',
          pageBuilder: (context, state) =>
              const MaterialPage(child: AddRecords()),
        ),
      ],
    ),
  ],
  debugLogDiagnostics: true, // لتتبع الأخطاء
);
