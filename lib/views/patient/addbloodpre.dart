import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/local/app_localizations.dart';
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
    final loc = AppLocalizations.of(context);

    if (systolic < 90 || diastolic < 60) return loc!.get('low');
    if (systolic <= 120 && diastolic <= 80) return loc!.get('normal');
    if (systolic <= 129 && diastolic <= 84) return loc!.get('elevated');
    if (systolic <= 139 || diastolic <= 89) return loc!.get('high');
    return loc!.get('very_high');
  }

  void _addBloodPressure() async {
    final loc = AppLocalizations.of(context);
    final success =
        await ref.read(healthValueControllerProvider.notifier).addHealthValue(
              1, // diseaseId لضغط الدم
              systolic,
              valuee: diastolic,
              status: calculateBloodPressureStatus(systolic, diastolic),
            );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc!.get('pressure_saved_success'))),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc!.get('failed_save_measurement'))),
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
    final loc = AppLocalizations.of(context);

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 16,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 20),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 50),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Icon(
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
              '${loc!.get('blood_pressure')}: ${systolic.round()}/${diastolic.round()} ${loc.get('mmhg')}',
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
                    GaugeAnnotation(
                      widget: Text(
                        loc.get('systolic'),
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
                    GaugeAnnotation(
                      widget: Text(
                        loc.get('diastolic'),
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
                LegendItem(color: Colors.green, label: loc.get('normal')),
                LegendItem(color: Colors.yellow, label: loc.get('high')),
                LegendItem(color: Colors.orange, label: loc.get('very_high')),
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
