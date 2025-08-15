import 'package:flutter/material.dart';

Widget buildInfoRow(String label, String value, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
        Text(value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
            )),
      ],
    ),
  );
}
