import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';

class MedicineCard extends StatefulWidget {
  const MedicineCard({
    super.key,
    required this.medication,
    required this.selectedDate,
  });
  final MedicationTime medication;
  final DateTime selectedDate;

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          'medicine_details',
          extra: {
            'medication': widget.medication,
            'selectedDate': widget.selectedDate,
          },
        );
      },
      child: Card(
        color: blue5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // مهم جداً: يخلي البطاقة تتكيف مع محتواها
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: blue3),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  MyFlutterApp.pills,
                  size: 40,
                  color: blue3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.medication.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.medication.dosage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
