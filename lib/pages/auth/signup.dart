// ---------------- صفحة إنشاء حساب -----------------
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/pages/auth/doctor_info.dart';
import 'package:health_bridge/pages/auth/login.dart';
import 'package:health_bridge/pages/auth/patient_info.dart';
import 'package:health_bridge/service/api_service.dart';

class SignUpPage extends StatefulWidget {
  static const route = '/signup';
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _selectedRole;

  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _nameValidator(String? v) {
    if (v == null || v.trim().length < 2) return 'أدخل اسماً صحيحاً';
    return null;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'أدخل البريد الإلكتروني';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(v.trim())) return 'البريد غير صالح';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
    if (v.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    return null;
  }

  String? _confirmValidator(String? v) {
    if (v != _passwordCtrl.text) return 'كلمة المرور غير متطابقة';
    return null;
  }

  String? _roleValidator(String? v) {
    if (v == null || v.isEmpty) return 'اختر الدور';
    return null;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الدور')),
      );
      return;
    }

    // عرض مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    User user = User(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      passwordConfirmation: _confirmCtrl.text,
    );

    try {
      if (_selectedRole == 'patient') {
        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PatientInfoPage(user: user), // 👈 مريض → PatientInfoPage
          ),
        );
        print('✅ patient account is created successfully');
      } else {
        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        context.goNamed(
          'doctor_info',
          extra: user, // 👈 تمرير البيانات عبر extra
        );
        print('✅ doctor account is created successfully');
      }
    } catch (e) {
      Navigator.of(context).pop(); // إخفاء مؤشر التحميل عند الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إنشاء الحساب: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "إنشاء حساب",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // الاسم
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "الاسم الكامل",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: _nameValidator,
                    ),
                    const SizedBox(height: 16),

                    // البريد
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "البريد الإلكتروني",
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 16),

                    // كلمة المرور
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure1,
                      decoration: InputDecoration(
                        labelText: "كلمة المرور",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure1 = !_obscure1),
                          icon: Icon(
                            _obscure1 ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: _passwordValidator,
                    ),
                    const SizedBox(height: 16),

                    // تأكيد كلمة المرور
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscure2,
                      decoration: InputDecoration(
                        labelText: "تأكيد كلمة المرور",
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2 ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: _confirmValidator,
                    ),
                    const SizedBox(height: 16),

                    // الدور (Role)
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: "الدور",
                        prefixIcon: Icon(Icons.badge),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "patient",
                          child: Text("مريض"),
                        ),
                        DropdownMenuItem(
                          value: "doctor",
                          child: Text("طبيب"),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedRole = val),
                      validator: _roleValidator,
                    ),
                    const SizedBox(height: 24),

                    // زر إنشاء الحساب
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text("إنشاء حساب"),
                    ),
                    const Divider(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("لديك حساب بالفعل؟"),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, LoginPage.route),
                          child: const Text("تسجيل الدخول"),
                        ),
                      ],
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
