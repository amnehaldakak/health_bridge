// ProfilePage.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/profile_responce.dart';
import 'package:health_bridge/providers/profile_provider.dart';
import 'package:health_bridge/controller/profile_controller.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/views/edit_profile_page.dart';
import 'package:health_bridge/constant/link.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final controller = ref.read(profileControllerProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc!.get('profile')),
      ),
      body: profileAsync.when(
        data: (profile) {
          final user = profile.user;
          final doctor = profile.doctor;
          final patient = profile.patient;

          if (user == null) {
            return Center(child: Text(loc.get('no_data')));
          }

          // بناء رابط الصورة بشكل صحيح
          String? imageUrl;
          if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
            if (user.profilePicture!.startsWith('http')) {
              imageUrl = user.profilePicture;
            } else if (user.profilePicture!.startsWith('/')) {
              imageUrl = '$serverLink${user.profilePicture!.substring(1)}';
            } else {
              imageUrl = '$serverLink${user.profilePicture}';
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileImage(imageUrl),
                const SizedBox(height: 12),
                Text(user.name ?? '-',
                    style: Theme.of(context).textTheme.titleLarge),
                Text(user.email ?? '-',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),

                // عرض بيانات المريض إذا موجود
                if (patient != null) ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.cake),
                      title: Text(loc.get('birth_date')),
                      subtitle: Text(patient.birthDate),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.male),
                      title: Text(loc.get('gender')),
                      subtitle: Text(patient.gender),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(loc.get('phone')),
                      subtitle: Text(patient.phone),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: Text(loc.get('chronic_diseases')),
                      subtitle: Text(patient.chronicDiseases),
                    ),
                  ),
                  if (patient.casesCount != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(loc.get('cases_count')),
                        subtitle: Text(patient.casesCount.toString()),
                      ),
                    ),
                ] else if (doctor != null) ...[
                  // بيانات الطبيب
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.local_hospital),
                          title: Text(loc.get('specialization')),
                          subtitle: Text(doctor.specialization ?? '-'),
                        ),
                        Divider(color: Theme.of(context).dividerColor),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(loc.get('clinic_address')),
                          subtitle: Text(doctor.clinicAddress ?? '-'),
                        ),
                        Divider(color: Theme.of(context).dividerColor),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text(loc.get('clinic_phone')),
                          subtitle: Text(doctor.clinicPhone ?? '-'),
                        ),
                        Divider(color: Theme.of(context).dividerColor),
                        ListTile(
                          leading: const Icon(Icons.verified),
                          title: Text(loc.get('verification_status')),
                          subtitle: Text(doctor.verificationStatus ?? '-'),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: Text(loc.get('edit')),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfilePage(profile: profile),
                          ),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: Text(loc.get('delete_account')),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(loc.get('confirm_delete')),
                            content: Text(loc.get('confirm_delete_message')),
                            actions: [
                              TextButton(
                                  child: Text(loc.get('cancel')),
                                  onPressed: () => Navigator.pop(ctx, false)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error),
                                child: Text(loc.get('delete')),
                                onPressed: () => Navigator.pop(ctx, true),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await controller.deleteProfile();
                          if (context.mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed("/login");
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text("${loc!.get('error')}: ${err.toString()}")),
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.grey[300],
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        backgroundImage: AssetImage("assets/profile.jpg"),
      );
    }
  }
}
