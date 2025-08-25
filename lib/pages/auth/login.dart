import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/get_device_name.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/constant/link.dart';
import 'package:health_bridge/main.dart';
import 'package:health_bridge/pages/auth/signup.dart';
import 'package:health_bridge/service/api_service.dart';

class LoginPage extends StatefulWidget {
  static const route = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // الحصول على اسم الجهاز
        final deviceName = await getDeviceName();

        final loginData = {
          "email": _emailCtrl.text,
          "password": _passwordCtrl.text,
          "device_name": deviceName,
        };

        const apiUrl = '$serverLink$loginLink';
        final response = await ApiService().postRequest(apiUrl, loginData);

        if (response['token'] != null) {
          final token = response['token'];
          final user = response['user'];

          // 🟢 حفظ التوكن
          await prefs.setString('token', token);
          print("${prefs.getString('token')} --------------------------------");

          // 🟢 حفظ كل حقل من user
          await prefs.setInt('user_id', user['id']);
          await prefs.setString('user_name', user['name'] ?? '');
          await prefs.setString('user_email', user['email'] ?? '');
          await prefs.setString('user_role', user['role'] ?? '');
          await prefs.setInt('user_isApproved', user['is_approved'] ?? 0);
          await prefs.setString(
              'user_profilePicture', user['profile_picture'] ?? '');
          await prefs.setString('user_createdAt', user['created_at'] ?? '');
          await prefs.setString('user_updatedAt', user['updated_at'] ?? '');

          // في حالة الطبيب
          if (user['role'] == 'doctor') {
            final doctor = response['doctor'];

            await prefs.setInt('doctor_id', doctor['id']);
            await prefs.setInt('doctor_userId', doctor['user_id']);
            await prefs.setString(
                'doctor_specialization', doctor['specialization'] ?? '');
            await prefs.setString(
                'doctor_certificatePath', doctor['certificate_path'] ?? '');
            await prefs.setString('doctor_verificationStatus',
                doctor['verification_status'] ?? '');
            await prefs.setString(
                'doctor_createdAt', doctor['created_at'] ?? '');
            await prefs.setString(
                'doctor_updatedAt', doctor['updated_at'] ?? '');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تسجيل الدخول كطبيب')),
            );

            context.go('/home_doctor');
          }

          // في حالة المريض
          else if (user['role'] == 'patient') {
            final patient = response['patient'];

            await prefs.setInt('patient_id', patient['id']);
            await prefs.setInt('patient_userId', patient['user_id']);
            await prefs.setString(
                'patient_birthDate', patient['birth_date'] ?? '');
            await prefs.setString('patient_gender', patient['gender'] ?? '');
            await prefs.setString('patient_phone', patient['phone'] ?? '');
            await prefs.setString(
                'patient_chronicDiseases', patient['chronic_diseases'] ?? '');
            await prefs.setString(
                'patient_createdAt', patient['created_at'] ?? '');
            await prefs.setString(
                'patient_updatedAt', patient['updated_at'] ?? '');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تسجيل الدخول كمريض')),
            );

            context.go('/home_patient');
          }

          // أي دور آخر
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تسجيل الدخول بنجاح')),
            );
            context.go('/home');
          }
        } else if (response['is_approved'] != null &&
            response['is_approved'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ??
                    'في انتظار مراجعة شهادتك من الإدارة')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ أثناء تسجيل الدخول')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [blue4, blue3, blue5, blue2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
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
                        "تسجيل الدخول",
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: "البريد الإلكتروني",
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: "كلمة المرور",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: _passwordValidator,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text("دخول"),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
                        child: const Text("نسيت كلمة المرور؟"),
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("لا تملك حساب؟"),
                          TextButton(
                            onPressed: () => context.goNamed('signup'),
                            child: const Text("إنشاء حساب"),
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
      ),
    );
  }
}
