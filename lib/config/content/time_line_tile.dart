import 'package:flutter/material.dart';
import 'package:health_bridge/config/content/event_carde.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimeLineTile1 extends StatelessWidget {
  const TimeLineTile1(
      {super.key,
      required this.isFirst,
      required this.isPast,
      required this.isLast,
      required this.evenCard});
  final bool isFirst;
  final bool isPast;
  final bool isLast;
  final Widget evenCard;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        beforeLineStyle: LineStyle(color: isPast ? blue3 : blue4),
        indicatorStyle: IndicatorStyle(
            color: isPast ? blue3 : blue4,
            width: 40,
            iconStyle: isPast ? IconStyle(iconData: Icons.done) : null),
        endChild: EventCarde(isPast: isPast, child: evenCard),
      ),
    );
  }
}
