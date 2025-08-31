import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'profile': 'Profile',
      'status': 'Status',
      'active': 'Active ✅',
      'pending': 'Pending ⏳',
      'specialization': 'Specialization',
      'clinic_address': 'Clinic Address',
      'clinic_phone': 'Clinic Phone',
      'verification_status': 'Verification Status',
      'edit': 'Edit',
      'delete_account': 'Delete Account',
      'confirm_delete': 'Confirm Delete',
      'delete_warning':
          'Are you sure you want to delete your account? This action cannot be undone.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'error': 'Error',
      'edit_profile': 'Edit Profile',
      'name': 'Name',
      'email': 'Email',
      'save_changes': 'Save Changes',
    },
    'ar': {
      'profile': 'الملف الشخصي',
      'status': 'الحالة',
      'active': 'مفعل ✅',
      'pending': 'بانتظار التفعيل ⏳',
      'specialization': 'التخصص',
      'clinic_address': 'عنوان العيادة',
      'clinic_phone': 'هاتف العيادة',
      'verification_status': 'حالة التحقق',
      'edit': 'تعديل',
      'delete_account': 'حذف الحساب',
      'confirm_delete': 'تأكيد الحذف',
      'delete_warning': 'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع.',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'error': 'حدث خطأ',
      'edit_profile': 'تعديل الملف الشخصي',
      'name': 'الاسم',
      'email': 'البريد الإلكتروني',
      'save_changes': 'حفظ التغييرات',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
