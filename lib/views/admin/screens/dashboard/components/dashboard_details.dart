import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/providers/dashboard_providers.dart';
import 'package:health_bridge/views/admin/screens/dashboard/components/dashboardInfo_card.dart';
import '../../../constants.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardDetails extends ConsumerWidget {
  const DashboardDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: defaultPadding),
          dashboardAsync.when(
            data: (counts) {
              return Column(
                children: [
                  _buildDashboardCard(
                    title: "المستخدمين",
                    svgSrc: "assets/icons/users.svg",
                    counts: {
                      "الأطباء المعتمدون": counts["الأطباء المعتمدون"] ?? 0,
                      "المرضى": counts["المرضى"] ?? 0,
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                  _buildDashboardCard(
                    title: "المجتمعات",
                    svgSrc: "assets/icons/community.svg",
                    counts: {
                      "المجتمعات العامة": counts["المجتمعات العامة"] ?? 0,
                      "المجتمعات الخاصة": counts["المجتمعات الخاصة"] ?? 0,
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error: $e")),
          ),
        ],
      ),
    );
  }

  /// تابع لبناء البطاقة مع مخطط دائري
  Widget _buildDashboardCard({
    required String title,
    required String svgSrc,
    required Map<String, int> counts,
  }) {
    final total = counts.values.fold<int>(0, (sum, val) => sum + val);
    final sections = counts.entries.map((entry) {
      final percent = total > 0 ? (entry.value / total * 100) : 0;
      return PieChartSectionData(
        color: _getColor(entry.key),
        value: percent.toDouble(),
        showTitle: true,
        title: '${entry.value}',
        radius: 25,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardInfoCard(title: title, svgSrc: svgSrc, counts: counts),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  /// اختيار اللون لكل عنصر بناءً على الاسم
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
