import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/link.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:intl/intl.dart';

class PatientInfoPage extends StatefulWidget {
  static const route = '/patient-info';
  final User user;

  PatientInfoPage({super.key, required this.user});

  @override
  State<PatientInfoPage> createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _phoneCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _chronicCtrl = TextEditingController(); // حقل الأمراض المزمنة

  String? _selectedGender;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _birthDateCtrl.dispose();
    _chronicCtrl.dispose();
    super.dispose();
  }

  // Validators
  String? _birthValidator(String? v, AppLocalizations loc) {
    if (v == null || v.isEmpty) return loc.get('enter_birth_date');
    try {
      DateFormat("yyyy-MM-dd").parse(v);
    } catch (_) {
      return loc.get('invalid_date_format');
    }
    return null;
  }

  String? _genderValidator(String? v, AppLocalizations loc) {
    if (v == null || v.isEmpty) return loc.get('select_gender');
    return null;
  }

  String? _phoneValidator(String? v, AppLocalizations loc) {
    if (v == null || v.isEmpty) return loc.get('enter_phone');
    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(v)) return loc.get('invalid_phone');
    return null;
  }

  String? _chronicValidator(String? v, AppLocalizations loc) {
    if (v == null || v.isEmpty) return loc.get('enter_chronic_diseases');
    return null;
  }

  void _submit() async {
    final loc = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await ApiService.registerPatient(
        name: widget.user.name ?? '',
        email: widget.user.email ?? '',
        password: widget.user.password ?? '',
        passwordConfirmation: widget.user.passwordConfirmation ?? '',
        birthDate: _birthDateCtrl.text,
        gender: _selectedGender ?? '',
        phone: _phoneCtrl.text,
        chronicDiseases: _chronicCtrl.text,
        profilePhoto: widget.user.profileImage, // اختياري
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc!.get('patient_registered_success'))),
        );
        context.goNamed('login');
      } else {
        final respStr = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("${loc!.get('registration_failed')}: $respStr")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${loc!.get('error_occurred')}: $e")),
      );
    }
  }

  Future<void> _pickDate() async {
    final loc = AppLocalizations.of(context);

    try {
      DateTime initialDate =
          DateTime.tryParse(_birthDateCtrl.text) ?? DateTime(2000, 1, 1);
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        locale: Locale(loc!.locale.languageCode), // استخدام لغة التطبيق
      );

      if (picked != null) {
        setState(() {
          _birthDateCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${loc!.get('date_selection_error')}: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc!.get('patient_info'))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.get('enter_your_info'),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // تاريخ الميلاد
                    TextFormField(
                      controller: _birthDateCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: loc.get('birth_date'),
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: _pickDate,
                        ),
                      ),
                      validator: (v) => _birthValidator(v, loc),
                    ),
                    const SizedBox(height: 16),

                    // الجنس
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: loc.get('gender'),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "male",
                          child: Text(loc.get('male')),
                        ),
                        DropdownMenuItem(
                          value: "female",
                          child: Text(loc.get('female')),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedGender = val),
                      validator: (v) => _genderValidator(v, loc),
                    ),
                    const SizedBox(height: 16),

                    // رقم الهاتف
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: loc.get('phone_number'),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (v) => _phoneValidator(v, loc),
                    ),
                    const SizedBox(height: 16),

                    // الأمراض المزمنة
                    TextFormField(
                      controller: _chronicCtrl,
                      decoration: InputDecoration(
                        labelText: loc.get('chronic_diseases'),
                        hintText: loc.get('chronic_diseases_example'),
                        prefixIcon: const Icon(Icons.medical_services),
                      ),
                      validator: (v) => _chronicValidator(v, loc),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(loc.get('save_data')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
