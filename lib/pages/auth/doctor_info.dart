import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/service/api_service.dart';

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
  String? _requiredValidator(String? v, String field) {
    if (v == null || v.isEmpty) return "الرجاء إدخال $field";
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.isEmpty) return "الرجاء إدخال رقم العيادة";
    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(v)) {
      return "أدخل رقم هاتف صحيح";
    }
    return null;
  }

  String? _certificateValidator() {
    if (_certificateFile == null) return "الرجاء رفع الشهادة";
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

  void _submit() async {
    if (!_formKey.currentState!.validate() || _certificateFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("⚠️ يرجى تعبئة جميع الحقول المطلوبة وإرفاق الشهادة")),
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
        profilePhoto: widget.user.profileImage, // 👈 صورة البروفايل (اختيارية)
      );

      Navigator.of(context).pop(); // إغلاق مؤشر التحميل

      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(" تم تسجيل الطبيب بنجاح الرجاء تسجيل الدخول")),
        );
        Navigator.pop(context); // رجوع أو انتقال لصفحة أخرى
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ فشل التسجيل: $respStr")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("معلومات الطبيب")),
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
                      "الرجاء إدخال بياناتك المهنية",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // التخصص
                    TextFormField(
                      controller: _specializationCtrl,
                      decoration: const InputDecoration(
                        labelText: "التخصص",
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      validator: (v) => _requiredValidator(v, "التخصص"),
                    ),
                    const SizedBox(height: 16),

                    // عنوان العيادة
                    TextFormField(
                      controller: _clinicAddressCtrl,
                      decoration: const InputDecoration(
                        labelText: "عنوان العيادة",
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (v) => _requiredValidator(v, "عنوان العيادة"),
                    ),
                    const SizedBox(height: 16),

                    // رقم العيادة
                    TextFormField(
                      controller: _clinicPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "رقم العيادة",
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: _phoneValidator,
                    ),
                    const SizedBox(height: 16),

                    // رفع الشهادة
                    InkWell(
                      onTap: _pickCertificate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "الشهادة (JPG, PNG, PDF)",
                          prefixIcon: const Icon(Icons.upload_file),
                          errorText: _certificateValidator(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _certificateFile != null
                                    ? _certificateFile!.path.split('/').last
                                    : "اضغط لاختيار ملف",
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
