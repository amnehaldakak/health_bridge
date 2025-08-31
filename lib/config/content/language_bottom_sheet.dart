import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/providers/local_provider.dart';

class LanguageBottomSheet extends ConsumerWidget {
  const LanguageBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "اختر اللغة / Choose Language",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blue),
            title: Text(
              "English",
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              localeNotifier.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
          Divider(color: theme.dividerColor),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.green),
            title: Text(
              "العربية",
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              localeNotifier.setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
