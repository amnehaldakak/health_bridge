import 'package:flutter/material.dart';
import 'package:health_bridge/models/medication_time.dart';

class MedicationItem extends StatelessWidget {
  final MedicationTime medication;
  final ThemeData theme;
  final VoidCallback? onEdit;

  const MedicationItem({
    Key? key,
    required this.medication,
    required this.theme,
    this.onEdit,
  }) : super(key: key);

  Widget _buildInfoRow(String title, String value, ThemeData theme) {
    return Row(
      children: [
        Text(title,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Flexible(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        width: 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: theme.colorScheme.primary,
                onPressed: onEdit,
              ),
            ),
            Center(
              child: Icon(
                Icons.medication,
                color: medication.isActive ? Colors.green : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(height: 6.0),
            Center(
              child: Text(
                medication.medicationName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8.0),
            Divider(height: 1, thickness: 1, color: Colors.grey[400]),
            const SizedBox(height: 6.0),
            _buildInfoRow('الجرعة:', medication.amount, theme),
            const SizedBox(height: 6.0),
            Divider(height: 1, thickness: 1, color: Colors.grey[400]),
            const SizedBox(height: 6.0),
            Center(
              child: Text(
                '${medication.timePerDay} مرات يومياً',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
