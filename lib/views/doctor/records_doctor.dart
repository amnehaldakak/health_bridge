import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/providers/records_doctor_provider.dart';
import 'package:health_bridge/providers/request_provider.dart';

class RecordsDoctor extends ConsumerWidget {
  const RecordsDoctor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(doctorPatientsProvider);
    final patientsController = ref.read(doctorPatientsProvider.notifier);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          // زر إضافة المريض فوق القائمة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final TextEditingController nameController =
                      TextEditingController();

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(loc!.get('add_patient')),
                        content: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: loc.get('patient_name'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(loc.get('cancel')),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final id = nameController.text.trim();
                              if (id.isNotEmpty) {
                                try {
                                  final patientData = await ref
                                      .read(requestDetailProvider(id).future);

                                  Navigator.of(context).pop();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "${loc.get('added_patient')}: ${nameController.text}"),
                                    ),
                                  );

                                  ref.invalidate(doctorPatientsProvider);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("${loc.get('error')}: $e")),
                                  );
                                }
                              }
                            },
                            child: Text(loc.get('add')),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.person_add, color: blue5),
                label: Text(loc!.get('add_patient')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // قائمة المرضى
          Expanded(
            child: patientsAsync.when(
              data: (patients) {
                if (patients.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: patientsController.refreshPatients,
                    child: ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(child: Text(loc!.get('no_patients'))),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: patientsController.refreshPatients,
                  child: ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return InkWell(
                        onTap: () =>
                            context.pushNamed('patient_cases', extra: patient),
                        borderRadius: BorderRadius.circular(12),
                        child: Card(
                          elevation: 2,
                          shadowColor: blue3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                                  backgroundImage: patient.user.profileImage !=
                                          null
                                      ? FileImage(patient.user.profileImage!)
                                      : (patient.user.profilePicture != null &&
                                              patient.user.profilePicture!
                                                  .isNotEmpty
                                          ? NetworkImage(
                                              patient.user.profilePicture!)
                                          : null) as ImageProvider<Object>?,
                                  child: (patient.user.profileImage == null &&
                                          (patient.user.profilePicture ==
                                                  null ||
                                              patient.user.profilePicture!
                                                  .isEmpty))
                                      ? Icon(
                                          Icons.person,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patient.user.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ],
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => RefreshIndicator(
                onRefresh: patientsController.refreshPatients,
                child: ListView(
                  children: [
                    const SizedBox(height: 100),
                    Center(child: Text("${loc!.get('error')}: $err")),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('add_record');
        },
        child: Icon(
          Icons.add,
          color: blue5,
        ),
      ),
    );
  }
}
