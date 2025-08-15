import 'package:flutter/material.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';

class MedicineCard extends StatefulWidget {
  const MedicineCard({super.key, required this.medication, this.onTap});
  final MedicationTime medication;
  final void Function()? onTap;

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: widget.onTap,
        child: Card(
          color: blue5,
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: blue3,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Icon(
                    MyFlutterApp.pills,
                    size: 50,
                    color: blue3,
                  ),
                ),
                ListTile(
                  title: Text(
                    widget.medication.medicationName,
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    widget.medication.amount,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
