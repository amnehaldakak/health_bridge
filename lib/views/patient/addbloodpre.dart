import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/providers/health_value_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class AddBloodPre extends ConsumerStatefulWidget {
  const AddBloodPre({super.key});

  @override
  ConsumerState<AddBloodPre> createState() => _AddBloodPreState();
}

class _AddBloodPreState extends ConsumerState<AddBloodPre> {
  int systolic = 110;
  int diastolic = 70;

  /// تابع لحساب حالة ضغط الدم
  String calculateBloodPressureStatus(int systolic, int diastolic) {
    if (systolic < 90 || diastolic < 60) return 'Low';
    if (systolic <= 120 && diastolic <= 80) return 'Normal';
    if (systolic <= 129 && diastolic <= 84) return 'Elevated';
    if (systolic <= 139 || diastolic <= 89) return 'High';
    return 'Very High';
  }

  void _addBloodPressure() async {
    final success =
        await ref.read(healthValueControllerProvider.notifier).addHealthValue(
              1, // diseaseId لضغط الدم
              systolic,
              valuee: diastolic,
              status: calculateBloodPressureStatus(systolic, diastolic),
            );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ قياس الضغط بنجاح')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في حفظ القياس')),
      );
    }
  }

  void saveBloodPressure() {
    _addBloodPressure();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 16,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 20),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 50),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Icon(
            MyFlutterApp.noun_blood_pressure_7315638,
            size: 50,
          ),
          centerTitle: true,
          actions: [
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.7),
                border: Border.all(),
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                highlightColor: primaryColor.withOpacity(0.5),
                color: textColor,
                onPressed: saveBloodPressure,
                icon: const Icon(Icons.check_outlined),
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Blood Pressure: ${systolic.round()}/${diastolic.round()} mmHg',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  radiusFactor: 1,
                  minimum: 70,
                  maximum: 140,
                  startAngle: 130,
                  endAngle: 45,
                  showLabels: true,
                  labelsPosition: ElementsPosition.inside,
                  showTicks: true,
                  interval: 5,
                  showFirstLabel: false,
                  axisLineStyle:
                      const AxisLineStyle(cornerStyle: CornerStyle.bothCurve),
                  ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 70, endValue: 90, color: Colors.amber),
                    GaugeRange(
                        startValue: 90, endValue: 120, color: Colors.green),
                    GaugeRange(
                        startValue: 120, endValue: 129, color: Colors.yellow),
                    GaugeRange(
                        startValue: 129, endValue: 139, color: Colors.orange),
                    GaugeRange(
                        startValue: 139, endValue: 150, color: Colors.red),
                  ],
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: systolic.toDouble(),
                      cornerStyle: CornerStyle.bothCurve,
                      width: 12,
                      sizeUnit: GaugeSizeUnit.logicalPixel,
                      color: Colors.white54,
                    ),
                    MarkerPointer(
                      value: systolic.toDouble(),
                      enableDragging: true,
                      onValueChanged: (value) {
                        setState(() {
                          systolic = value.round();
                        });
                      },
                      markerHeight: 20,
                      markerWidth: 20,
                      markerType: MarkerType.circle,
                      borderWidth: 2,
                      color: primaryColor,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    const GaugeAnnotation(
                      widget: Text(
                        'Systolic',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      angle: 90,
                      positionFactor: 0.8,
                    ),
                  ],
                ),
                RadialAxis(
                  radiusFactor: 0.6,
                  minimum: 40,
                  maximum: 100,
                  startAngle: 130,
                  endAngle: 45,
                  showLabels: true,
                  labelsPosition: ElementsPosition.inside,
                  showTicks: true,
                  interval: 5,
                  showFirstLabel: false,
                  axisLineStyle:
                      const AxisLineStyle(cornerStyle: CornerStyle.bothCurve),
                  ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 40, endValue: 60, color: Colors.amber),
                    GaugeRange(
                        startValue: 60, endValue: 80, color: Colors.green),
                    GaugeRange(
                        startValue: 80, endValue: 89, color: Colors.yellow),
                    GaugeRange(
                        startValue: 89, endValue: 100, color: Colors.orange),
                  ],
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: diastolic.toDouble(),
                      cornerStyle: CornerStyle.bothCurve,
                      width: 12,
                      sizeUnit: GaugeSizeUnit.logicalPixel,
                      color: Colors.white54,
                    ),
                    MarkerPointer(
                      value: diastolic.toDouble(),
                      enableDragging: true,
                      onValueChanged: (value) {
                        setState(() {
                          diastolic = value.round();
                        });
                      },
                      markerHeight: 20,
                      markerWidth: 20,
                      markerType: MarkerType.circle,
                      borderWidth: 2,
                      color: primaryColor,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    const GaugeAnnotation(
                      widget: Text(
                        'Diastolic',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      angle: 90,
                      positionFactor: 0.7,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendItem(color: Colors.green, label: 'Normal'),
                LegendItem(color: Colors.yellow, label: 'High'),
                LegendItem(color: Colors.orange, label: 'Very high'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({required this.color, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            color: color,
            height: 16,
            width: 16,
          ),
          Text(label),
        ],
      ),
    );
  }
}
