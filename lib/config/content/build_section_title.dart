import 'package:flutter/material.dart';

Widget buildSectionTitle(String text, ThemeData theme) {
  return Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: theme.colorScheme.primary,
    ),
  );
}
