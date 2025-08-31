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

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.get('profile')),
      ),
      body: profileAsync.when(
        data: (profile) {
          final user = profile?.user;
          final doctor = profile?.doctor;

          if (user == null) {
            return Center(
                child: Text(AppLocalizations.of(context)!.get('no_data')));
          }

          // بناء رابط الصورة بشكل صحيح
          String? imageUrl;
          if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
            // إصلاح بناء الرابط
            if (user.profilePicture!.startsWith('http')) {
              imageUrl = user.profilePicture;
            } else if (user.profilePicture!.startsWith('/')) {
              imageUrl = '$serverLink2${user.profilePicture!.substring(1)}';
            } else {
              imageUrl = '$serverLink2${user.profilePicture}';
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // استخدام CachedNetworkImage لعرض الصورة
                _buildProfileImage(imageUrl, context),
                const SizedBox(height: 12),
                Text(user.name ?? '-',
                    style: Theme.of(context).textTheme.titleLarge),
                Text(user.email ?? '-',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified_user),
                    title: Text(AppLocalizations.of(context)!.get('status')),
                    subtitle: Text(
                      (user.isApproved ?? 0) == 1
                          ? AppLocalizations.of(context)!.get('active')
                          : AppLocalizations.of(context)!.get('pending'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                if (doctor != null) ...[
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.local_hospital),
                          title: Text(AppLocalizations.of(context)!
                              .get('specialization')),
                          subtitle: Text(doctor.specialization ?? '-',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        Divider(color: Theme.of(context).dividerColor),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(AppLocalizations.of(context)!
                              .get('clinic_address')),
                          subtitle: Text(doctor.clinicAddress ?? '-',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        Divider(color: Theme.of(context).dividerColor),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text(AppLocalizations.of(context)!
                              .get('clinic_phone')),
                          subtitle: Text(doctor.clinicPhone ?? '-',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        Divider(color: Theme.of(context).dividerColor),
                        ListTile(
                          leading: const Icon(Icons.verified),
                          title: Text(AppLocalizations.of(context)!
                              .get('verification_status')),
                          subtitle: Text(doctor.verificationStatus ?? '-',
                              style: Theme.of(context).textTheme.bodyMedium),
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
                      label: Text(AppLocalizations.of(context)!.get('edit')),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfilePage(profile: profile!),
                          ),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: Text(
                          AppLocalizations.of(context)!.get('delete_account')),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(AppLocalizations.of(context)!
                                .get('confirm_delete')),
                            content: Text(AppLocalizations.of(context)!
                                .get('confirm_delete_message')),
                            actions: [
                              TextButton(
                                  child: Text(AppLocalizations.of(context)!
                                      .get('cancel')),
                                  onPressed: () => Navigator.pop(ctx, false)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error),
                                child: Text(AppLocalizations.of(context)!
                                    .get('delete')),
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
        error: (err, _) => Center(
            child: Text(
                "${AppLocalizations.of(context)!.get('error')}: ${err.toString()}")),
      ),
    );
  }

  // دالة مساعدة لعرض صورة البروفايل
  Widget _buildProfileImage(String? imageUrl, BuildContext context) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 50,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: const AssetImage("assets/images/avatar.png"),
          child: const Icon(Icons.error, color: Colors.red),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        backgroundImage: const AssetImage("assets/images/avatar.png"),
      );
    }
  }
}
