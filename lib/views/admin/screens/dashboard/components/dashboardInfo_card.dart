import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';

class DashboardInfoCard extends StatelessWidget {
  const DashboardInfoCard({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.counts,
  }) : super(key: key);

  final String title, svgSrc;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(Radius.circular(defaultPadding)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                height: 30,
                width: 30,
                child: SvgPicture.asset(svgSrc),
              ),
              const SizedBox(width: defaultPadding),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // عرض كل قيمة مع مربع اللون الخاص بها
          ...counts.entries.map(
            (entry) {
              final color = _getColor(entry.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${entry.key}: ${entry.value}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.grey[300]),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getColor(String key) {
    switch (key) {
      case "الأطباء المعتمدون":
        return Colors.blue;
      case "المرضى":
        return Colors.green;
      case "المجتمعات العامة":
        return Colors.orange;
      case "المجتمعات الخاصة":
        return Colors.red;
      default:
        return primaryColor;
    }
  }
}
