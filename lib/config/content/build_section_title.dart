import 'package:flutter/material.dart';

Widget buildSectionTitle(String title, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.all(10.0), // Padding ثابت من كل الجهات بقيمة 10
    child: Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    ),
  );
}
