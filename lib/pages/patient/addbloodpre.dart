import 'package:flutter/material.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class AddBloodPre extends StatefulWidget {
  const AddBloodPre({super.key});

  @override
  State<AddBloodPre> createState() => _AddBloodPreState();
}

class _AddBloodPreState extends State<AddBloodPre> {
  double systolic = 110; // upper value
  double diastolic = 70; // lower value

  @override
  Widget build(BuildContext context) {
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
                color: blue4,
                border: Border.all(),
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                highlightColor: blue4,
                color: blue1,
                onPressed: () {
                  // handle save/submit action
                },
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  axisLineStyle: const AxisLineStyle(
                    cornerStyle: CornerStyle.bothCurve,
                  ),
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
                      value: systolic,
                      cornerStyle: CornerStyle.bothCurve,
                      width: 12,
                      sizeUnit: GaugeSizeUnit.logicalPixel,
                      color: Colors.white54,
                    ),
                    MarkerPointer(
                      value: systolic,
                      enableDragging: true,
                      onValueChanged: (value) {
                        setState(() {
                          systolic = value;
                        });
                      },
                      markerHeight: 20,
                      markerWidth: 20,
                      markerType: MarkerType.circle,
                      borderWidth: 2,
                      color: blue1,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: const Text(
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
                  axisLineStyle: const AxisLineStyle(
                    cornerStyle: CornerStyle.bothCurve,
                  ),
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
                      value: diastolic,
                      cornerStyle: CornerStyle.bothCurve,
                      width: 12,
                      sizeUnit: GaugeSizeUnit.logicalPixel,
                      color: Colors.white54,
                    ),
                    MarkerPointer(
                      value: diastolic,
                      enableDragging: true,
                      onValueChanged: (value) {
                        setState(() {
                          diastolic = value;
                        });
                      },
                      markerHeight: 20,
                      markerWidth: 20,
                      markerType: MarkerType.circle,
                      borderWidth: 2,
                      color: blue1,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: const Text(
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
              children: const [
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
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          color: color,
          height: 20,
          width: 20,
        ),
        Text(label),
      ],
    );
  }
}
