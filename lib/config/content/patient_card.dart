import 'package:flutter/material.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:go_router/go_router.dart';

class PatientCard extends StatelessWidget {
  final PatientModel patient;

  const PatientCard({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoRow(
                context, Icons.email, "البريد الإلكتروني", patient.user!.email),
            _divider(),
            _infoRow(context, Icons.phone, "الهاتف", patient.phone),
            _divider(),
            _infoRow(context, Icons.cake, "تاريخ الميلاد", patient.birthDate),
            _divider(),
            _infoRow(context, Icons.transgender, "الجنس", patient.gender),
            if (patient.chronicDiseases.isNotEmpty) ...[
              _divider(),
              _infoRow(context, Icons.local_hospital, "أمراض مزمنة",
                  patient.chronicDiseases),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: blue3, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(color: blue3),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Divider(
      color: blue3.withOpacity(0.2),
      height: 20,
      thickness: 1,
    );
  }
}
