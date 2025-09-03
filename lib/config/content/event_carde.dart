import 'package:flutter/material.dart';
import 'package:health_bridge/constant/color.dart';

class EventCarde extends StatelessWidget {
  const EventCarde({super.key, required this.isPast, required this.child});
  final bool isPast;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: isPast ? blue3 : blue4,
          border: Border.all(color: blue2),
          borderRadius: BorderRadius.circular(15)),
      child: child,
    );
  }
}
