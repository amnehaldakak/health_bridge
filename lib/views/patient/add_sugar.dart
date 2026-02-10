import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/providers/health_value_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Addsugar extends ConsumerStatefulWidget {
  const Addsugar({super.key});

  @override
  ConsumerState<Addsugar> createState() => _AddsugarState();
}

class _AddsugarState extends ConsumerState<Addsugar> {
  double sliderValue = 90;
  bool isFasting = false;

  /// حساب حالة السكر (ترجع القيم الثابتة: low, normal, prediabetes, high)
  String calculateSugarStatus(double value, bool fasting) {
    if (fasting) {
      if (value < 70) return 'low';
      if (value <= 100) return 'normal';
      if (value <= 125) return 'prediabetes';
      return 'high';
    } else {
      if (value < 90) return 'low';
      if (value <= 139) return 'normal';
      if (value <= 199) return 'prediabetes';
      return 'high';
    }
  }

  /// حفظ القيمة باستخدام HealthValueController
  Future<void> addValue() async {
    final loc = AppLocalizations.of(context);
    final status = calculateSugarStatus(sliderValue, isFasting);

    final success =
        await ref.read(healthValueControllerProvider.notifier).addHealthValue(
              2, // diseaseId للسكر
              sliderValue.round(),
              valuee: 0,
              status: status,
            );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc!.get('sugar_saved_success'))),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc!.get('failed_save_measurement'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Icon(
          MyFlutterApp.noun_diabetes_test_7357853,
          color: primaryColor,
          size: 40,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: primaryColor,
              border: Border.all(),
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              highlightColor: primaryColor.withOpacity(0.5),
              color: Colors.white,
              onPressed: addValue,
              icon: const Icon(
                Icons.check_outlined,
                weight: 3,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${loc!.get('blood_sugar_value')}: ${sliderValue.round()} ${loc.get('mgdl')}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: isFasting,
                    onChanged: (value) {
                      setState(() {
                        isFasting = value;
                      });
                    },
                    activeColor: primaryColor,
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                  ),
                  Text(
                    loc.get('fasting'),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _getStatusColor(sliderValue, isFasting).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _getStatusColor(sliderValue, isFasting)),
                ),
                child: Text(
                  '${loc.get('status')}: ${_getStatusText(sliderValue, isFasting, loc)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(sliderValue, isFasting),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    radiusFactor: 0.8,
                    minimum: 0,
                    maximum: isFasting ? 170 : 250,
                    startAngle: 130,
                    endAngle: 45,
                    showLabels: true,
                    labelsPosition: ElementsPosition.inside,
                    showTicks: true,
                    interval: isFasting ? 10 : 20,
                    showFirstLabel: false,
                    axisLineStyle:
                        const AxisLineStyle(cornerStyle: CornerStyle.bothCurve),
                    ranges: _getSugarRanges(isFasting),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: sliderValue,
                        cornerStyle: CornerStyle.bothCurve,
                        width: 12,
                        sizeUnit: GaugeSizeUnit.logicalPixel,
                        color: textColor.withOpacity(0.5),
                      ),
                      MarkerPointer(
                        value: sliderValue,
                        enableDragging: true,
                        onValueChanged: (value) {
                          setState(() {
                            sliderValue = value;
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
                          '${sliderValue.round()} ${loc.get('mgdl')}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: _getLegendItems(isFasting, loc),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(double value, bool fasting) {
    final status = calculateSugarStatus(value, fasting);
    switch (status) {
      case 'low':
        return Colors.blue;
      case 'normal':
        return Colors.green;
      case 'prediabetes':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(double value, bool fasting, AppLocalizations loc) {
    final status = calculateSugarStatus(value, fasting);
    switch (status) {
      case 'low':
        return loc.get('low');
      case 'normal':
        return loc.get('normal');
      case 'prediabetes':
        return loc.get('prediabetes');
      case 'high':
        return loc.get('high');
      default:
        return loc.get('unknown');
    }
  }

  List<GaugeRange> _getSugarRanges(bool fasting) {
    if (fasting) {
      return [
        GaugeRange(startValue: 0, endValue: 70, color: Colors.blue),
        GaugeRange(startValue: 70, endValue: 100, color: Colors.green),
        GaugeRange(startValue: 100, endValue: 126, color: Colors.orange),
        GaugeRange(startValue: 126, endValue: 170, color: Colors.red),
      ];
    } else {
      return [
        GaugeRange(startValue: 0, endValue: 90, color: Colors.blue),
        GaugeRange(startValue: 90, endValue: 140, color: Colors.green),
        GaugeRange(startValue: 140, endValue: 200, color: Colors.orange),
        GaugeRange(startValue: 200, endValue: 250, color: Colors.red),
      ];
    }
  }

  List<Widget> _getLegendItems(bool fasting, AppLocalizations loc) {
    return [
      LegendItem(color: Colors.blue, label: loc.get('low')),
      LegendItem(color: Colors.green, label: loc.get('normal')),
      if (fasting)
        LegendItem(color: Colors.orange, label: loc.get('prediabetes'))
      else
        LegendItem(color: Colors.orange, label: loc.get('slightly_high')),
      LegendItem(color: Colors.red, label: loc.get('high')),
    ];
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({required this.color, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.all(4),
          color: color,
          height: 16,
          width: 16,
        ),
        Text(label),
      ],
    );
  }
}
