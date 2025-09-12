import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/language_bottom_sheet.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/controller/auth_controller.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/local/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const route = '/login';
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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

  String? _emailValidator(String? v, AppLocalizations loc) {
    if (v == null || v.trim().isEmpty) return loc.get('enter_email');
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(v.trim())) return loc.get('invalid_email');
    return null;
  }

  String? _passwordValidator(String? v, AppLocalizations loc) {
    if (v == null || v.isEmpty) return loc.get('enter_password');
    if (v.length < 8) return loc.get('password_length');
    return null;
  }

  void _submit(AppLocalizations loc) async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).login(
            _emailCtrl.text,
            _passwordCtrl.text,
          );

      final authState = ref.read(authControllerProvider);

      if (authState is Authenticated) {
        final user = authState.user;

        if (user.role == 'doctor') {
          context.go('/home_doctor');
        } else if (user.role == 'patient') {
          context.go('/home_patient');
        } else {
          context.go('/admin_dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
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
                              loc!.get('login'),
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (authState is AuthError)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  authState.message,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: InputDecoration(
                                labelText: loc.get('email'),
                                prefixIcon: const Icon(Icons.email),
                              ),
                              validator: (v) => _emailValidator(v, loc),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: loc.get('password'),
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
                              validator: (v) => _passwordValidator(v, loc),
                            ),
                            const SizedBox(height: 24),
                            authState is AuthLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: () => _submit(loc),
                                    child: Text(loc.get('login')),
                                  ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {},
                              child: Text(loc.get('forgot_password')),
                            ),
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(loc.get('no_account')),
                                TextButton(
                                  onPressed: () => context.goNamed('signup'),
                                  child: Text(loc.get('sign_up')),
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
            // زر اللغة في الزاوية العليا اليسرى
            Positioned(
              top: 40,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                child: const Icon(Icons.language, color: Colors.blue),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => const LanguageBottomSheet(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
