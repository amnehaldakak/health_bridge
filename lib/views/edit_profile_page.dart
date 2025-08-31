import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/profile_controller.dart';
import 'package:health_bridge/models/profile_responce.dart';
import 'package:image_picker/image_picker.dart';
import 'package:health_bridge/providers/profile_provider.dart';
import 'package:health_bridge/local/app_localizations.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final ProfileResponse profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _specializationController;
  late TextEditingController _clinicAddressController;
  late TextEditingController _clinicPhoneController;

  File? _profileImage;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;

    _nameController = TextEditingController(text: profile.user.name);
    _emailController = TextEditingController(text: profile.user.email);
    _specializationController =
        TextEditingController(text: profile.doctor?.specialization ?? '');
    _clinicAddressController =
        TextEditingController(text: profile.doctor?.clinicAddress ?? '');
    _clinicPhoneController =
        TextEditingController(text: profile.doctor?.clinicPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    _clinicAddressController.dispose();
    _clinicPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final extraFields = {
      if (_specializationController.text.isNotEmpty)
        'specialization': _specializationController.text,
      if (_clinicAddressController.text.isNotEmpty)
        'clinic_address': _clinicAddressController.text,
      if (_clinicPhoneController.text.isNotEmpty)
        'clinic_phone': _clinicPhoneController.text,
    };

    try {
      await ref.read(profileControllerProvider).updateProfile(
            name: _nameController.text,
            email: _emailController.text,
            profilePicture: _profileImage,
            extraFields: extraFields,
          );

      // إعادة تحميل البروفايل
      ref.invalidate(profileProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.get('save_changes'),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.get('error')}: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.get('edit_profile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // صورة البروفايل
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : profile.user.profilePicture != null
                            ? NetworkImage(profile.user.profilePicture!)
                                as ImageProvider
                            : const AssetImage("assets/images/avatar.png"),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      color: Theme.of(context).primaryColor,
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // الاسم
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.get('name'),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? AppLocalizations.of(context)!.get('required')
                    : null,
              ),
              const SizedBox(height: 16),

              // الايميل
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.get('email'),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? AppLocalizations.of(context)!.get('required')
                    : null,
              ),
              const SizedBox(height: 16),

              // بيانات الطبيب
              if (profile.user.role == 'doctor') ...[
                TextFormField(
                  controller: _specializationController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.get('specialization'),
                    prefixIcon: const Icon(Icons.local_hospital),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clinicAddressController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.get('clinic_address'),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clinicPhoneController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.get('clinic_phone'),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // زر الحفظ
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context)!.get('save_changes')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
