import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class Chart extends StatelessWidget {
  final int firstValue; // عدد القسم الأول
  final int secondValue; // عدد القسم الثاني
  final Color firstColor;
  final Color secondColor;
  final String centerText;
  final String centerSubText;

  const Chart({
    Key? key,
    required this.firstValue,
    required this.secondValue,
    required this.firstColor,
    required this.secondColor,
    this.centerText = '',
    this.centerSubText = '',
  }) : super(key: key);

  // تابع لحساب النسبة (double) من القيمة الإجمالية
  double calculatePercent(int value, int total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final total = firstValue + secondValue;

    final firstPercent = calculatePercent(firstValue, total);
    final secondPercent = calculatePercent(secondValue, total);

    return SizedBox(
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 70,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    color: firstColor,
                    value: firstPercent.toDouble(), // تحويل إلى double
                    showTitle: false,
                    radius: 25,
                  ),
                  PieChartSectionData(
                    color: secondColor,
                    value: secondPercent.toDouble(), // تحويل إلى double
                    showTitle: false,
                    radius: 25,
                  ),
                ],
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(enabled: true),
              ),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    centerText,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 0.5,
                        ),
                  ),
                  Text(
                    centerSubText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
