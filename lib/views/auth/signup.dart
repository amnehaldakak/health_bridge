import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/user.dart';
import 'package:health_bridge/views/auth/doctor_info.dart';
import 'package:health_bridge/views/auth/login.dart';
import 'package:health_bridge/views/auth/patient_info.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _profileImage;

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

  String? _nameValidator(String? v, AppLocalizations loc) {
    if (v == null || v.trim().length < 2) return loc.get('enter_valid_name');
    return null;
  }

  String? _emailValidator(String? v, AppLocalizations loc) {
    if (v == null || v.trim().isEmpty) return loc.get('enter_email');
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(v.trim())) return loc.get('invalid_email');
    return null;
  }

  String? _passwordValidator(String? v, AppLocalizations loc) {
    if (v == null || v.isEmpty) return loc.get('enter_password');
    if (v.length < 8) return loc.get('password_min_length');
    return null;
  }

  String? _confirmValidator(String? v, AppLocalizations loc) {
    if (v != _passwordCtrl.text) return loc.get('password_mismatch');
    return null;
  }

  String? _roleValidator(String? v, AppLocalizations loc) {
    if (v == null || v.isEmpty) return loc.get('select_role');
    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(loc.get('choose_from_gallery')),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(loc.get('take_photo')),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    final loc = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc!.get('select_role'))),
      );
      return;
    }

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
      profileImage: _profileImage,
      role: _selectedRole ?? '',
    );

    try {
      if (_selectedRole == 'patient') {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientInfoPage(user: user),
          ),
        );
      } else {
        Navigator.of(context).pop();
        context.goNamed(
          'doctor_info',
          extra: user,
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc!.get('account_creation_error')}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

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
                      loc!.get('create_account'),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // الصورة الشخصية بشكل احترافي
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage('assets/profile.jpg')
                                    as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: GestureDetector(
                              onTap: () =>
                                  _showImagePickerOptions(context, loc),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: loc.get('full_name'),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (v) => _nameValidator(v, loc),
                    ),
                    const SizedBox(height: 16),

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
                      obscureText: _obscure1,
                      decoration: InputDecoration(
                        labelText: loc.get('password'),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure1 = !_obscure1),
                          icon: Icon(
                            _obscure1 ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) => _passwordValidator(v, loc),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscure2,
                      decoration: InputDecoration(
                        labelText: loc.get('confirm_password'),
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2 ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) => _confirmValidator(v, loc),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: loc.get('role'),
                        prefixIcon: const Icon(Icons.badge),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "patient",
                          child: Text(loc.get('patient')),
                        ),
                        DropdownMenuItem(
                          value: "doctor",
                          child: Text(loc.get('doctor')),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedRole = val),
                      validator: (v) => _roleValidator(v, loc),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(loc.get('create_account')),
                    ),
                    const Divider(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(loc.get('already_have_account')),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, LoginPage.route),
                          child: Text(loc.get('login')),
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
