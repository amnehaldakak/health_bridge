import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:health_bridge/local/app_localizations.dart';

class DoctorInfoPage extends StatefulWidget {
  static const route = '/doctor-info';
  final User user;
  const DoctorInfoPage({super.key, required this.user});

  @override
  State<DoctorInfoPage> createState() => _DoctorInfoPageState();
}

class _DoctorInfoPageState extends State<DoctorInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _specializationCtrl = TextEditingController();
  final _clinicAddressCtrl = TextEditingController();
  final _clinicPhoneCtrl = TextEditingController();

  File? _certificateFile;

  @override
  void dispose() {
    _specializationCtrl.dispose();
    _clinicAddressCtrl.dispose();
    _clinicPhoneCtrl.dispose();
    super.dispose();
  }

  // Validators
  String? _requiredValidator(String? v, String field, AppLocalizations loc) {
    if (v == null || v.isEmpty) {
      return loc.get('enter_field').replaceAll('{0}', field);
    }
    return null;
  }

  String? _phoneValidator(String? v, AppLocalizations loc) {
    if (v == null || v.isEmpty) return loc.get('enter_clinic_phone');
    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(v)) {
      return loc.get('invalid_phone');
    }
    return null;
  }

  String? _certificateValidator(AppLocalizations loc) {
    if (_certificateFile == null) return loc.get('upload_certificate');
    return null;
  }

  Future<void> _pickCertificate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _certificateFile = File(result.files.single.path!);
      });
    }
  }

  void _submit(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate() || _certificateFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(loc.get('fill_required_fields_and_attach_certificate'))),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.registerDoctor(
        name: widget.user.name ?? '',
        email: widget.user.email ?? '',
        password: widget.user.password ?? '',
        passwordConfirmation: widget.user.passwordConfirmation ?? '',
        specialization: _specializationCtrl.text,
        clinicAddress: _clinicAddressCtrl.text,
        clinicPhone: _clinicPhoneCtrl.text,
        certificateFile: _certificateFile!,
        profilePhoto: widget.user.profileImage,
      );

      Navigator.of(context).pop(); // close loading indicator

      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.get('doctor_registered_success'))),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("${loc.get('registration_failed')}: $respStr")),
        );
      }
    } catch (e) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${loc.get('error_occurred')}: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(loc!.get('doctor_info'))),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        loc.get('enter_professional_info'),
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Specialization
                      TextFormField(
                        controller: _specializationCtrl,
                        decoration: InputDecoration(
                          labelText: loc.get('specialization'),
                          prefixIcon: const Icon(Icons.medical_services),
                        ),
                        validator: (v) => _requiredValidator(
                            v, loc.get('specialization'), loc),
                      ),
                      const SizedBox(height: 16),

                      // Clinic Address
                      TextFormField(
                        controller: _clinicAddressCtrl,
                        decoration: InputDecoration(
                          labelText: loc.get('clinic_address'),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        validator: (v) => _requiredValidator(
                            v, loc.get('clinic_address'), loc),
                      ),
                      const SizedBox(height: 16),

                      // Clinic Phone
                      TextFormField(
                        controller: _clinicPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: loc.get('clinic_phone'),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        validator: (v) => _phoneValidator(v, loc),
                      ),
                      const SizedBox(height: 16),

                      // Upload Certificate
                      InkWell(
                        onTap: _pickCertificate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: loc.get('certificate_file'),
                            prefixIcon: const Icon(Icons.upload_file),
                            errorText: _certificateValidator(loc),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _certificateFile != null
                                      ? _certificateFile!.path.split('/').last
                                      : loc.get('tap_to_select_file'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.attach_file),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () => _submit(loc),
                        child: Text(loc.get('save_info')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
