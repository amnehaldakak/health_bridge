import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/link.dart';
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
  String? _birthValidator(String? v) {
    if (v == null || v.isEmpty) return "الرجاء إدخال تاريخ الميلاد";
    try {
      DateFormat("yyyy-MM-dd").parse(v);
    } catch (_) {
      return "صيغة التاريخ غير صحيحة (yyyy-MM-dd)";
    }
    return null;
  }

  String? _genderValidator(String? v) {
    if (v == null || v.isEmpty) return "الرجاء اختيار الجنس";
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.isEmpty) return "الرجاء إدخال رقم الهاتف";
    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(v)) return "أدخل رقم هاتف صحيح";
    return null;
  }

  String? _chronicValidator(String? v) {
    if (v == null || v.isEmpty)
      return "الرجاء إدخال الأمراض المزمنة أو كتابة لا يوجد";
    return null;
  }

  void _submit() async {
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
          const SnackBar(
              content: Text(" تم تسجيل المريض بنجاح الرجاء تسجيل الدخول")),
        );
        context.goNamed('login');
      } else {
        final respStr = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ فشل التسجيل: $respStr")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    }
  }

  Future<void> _pickDate() async {
    try {
      DateTime initialDate =
          DateTime.tryParse(_birthDateCtrl.text) ?? DateTime(2000, 1, 1);
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        locale: const Locale("en", "US"), // اللغة العربية
      );

      if (picked != null) {
        setState(() {
          _birthDateCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في اختيار التاريخ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("معلومات المريض")),
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
                      "الرجاء إدخال معلوماتك",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // تاريخ الميلاد
                    TextFormField(
                      controller: _birthDateCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "تاريخ الميلاد",
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: _pickDate,
                        ),
                      ),
                      validator: _birthValidator,
                    ),
                    const SizedBox(height: 16),

                    // الجنس
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: "الجنس",
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "ذكر",
                          child: Text("ذكر"),
                        ),
                        DropdownMenuItem(
                          value: "أنثى",
                          child: Text("أنثى"),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedGender = val),
                      validator: _genderValidator,
                    ),
                    const SizedBox(height: 16),

                    // رقم الهاتف
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "رقم الهاتف",
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: _phoneValidator,
                    ),
                    const SizedBox(height: 16),

                    // الأمراض المزمنة
                    TextFormField(
                      controller: _chronicCtrl,
                      decoration: const InputDecoration(
                        labelText: "الأمراض المزمنة",
                        hintText: "مثال: السكري, الضغط",
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      validator: _chronicValidator,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text("حفظ البيانات"),
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
