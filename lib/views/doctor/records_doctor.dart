import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:health_bridge/models/patient.dart';

class RecordsDoctor extends StatefulWidget {
  const RecordsDoctor({super.key});

  @override
  State<RecordsDoctor> createState() => _RecordsDoctorState();
}

class _RecordsDoctorState extends State<RecordsDoctor> {
  late Future<List<PatientModel>> _patientsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() {
    setState(() {
      _patientsFuture = _apiService.getDoctorPatients();
    });
  }

  /// دالة السحب للتحديث
  Future<void> _refreshPatients() async {
    final patients = await _apiService.getDoctorPatients();
    setState(() {
      _patientsFuture = Future.value(patients);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('add_record');
        },
        child: Icon(
          Icons.add,
          color: blue5,
        ),
      ),
      body: FutureBuilder<List<PatientModel>>(
        future: _patientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refreshPatients,
              child: ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text("خطأ: ${snapshot.error}")),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshPatients,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text("لا يوجد مرضى")),
                ],
              ),
            );
          }

          final patients = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshPatients,
            child: ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return InkWell(
                  onTap: () {
                    context.pushNamed('patient_cases', extra: patient);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    elevation: 2,
                    shadowColor: blue3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            backgroundImage: patient.user.profileImage != null
                                ? FileImage(patient.user.profileImage!)
                                : (patient.user.profilePicture != null &&
                                        patient.user.profilePicture!.isNotEmpty
                                    ? NetworkImage(patient.user.profilePicture!)
                                    : null) as ImageProvider<Object>?,
                            child: (patient.user.profileImage == null &&
                                    (patient.user.profilePicture == null ||
                                        patient.user.profilePicture!.isEmpty))
                                ? Icon(
                                    Icons.person,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              patient.user.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
