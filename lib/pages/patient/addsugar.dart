// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:supcar/constent/color.dart';
// import 'package:supcar/constent/stringtodata.dart';
// import 'package:supcar/content/convert_time.dart';
// import 'package:supcar/controller/Addsugarcontroller.dart';
// import 'package:supcar/controller/addmedicinecontroller.dart';
// import 'package:supcar/fonts/my_flutter_app_icons.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

// // ignore: must_be_immutable
// class Addsugar extends StatelessWidget {
//   Addsugar({super.key});
//   Addsugarcontroller controller = Get.put(Addsugarcontroller());
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: Icon(
//             MyFlutterApp.nounDiabetesTest,
//             color: lightPink,
//           ),
//           backgroundColor: deepPurple,
//           centerTitle: true,
//           actions: [
//             Container(
//               decoration: BoxDecoration(
//                   color: lightPink,
//                   border: Border.all(),
//                   borderRadius: BorderRadius.circular(30)),
//               child: IconButton(
//                   highlightColor: lightPink,
//                   color: deepPurple,
//                   onPressed: controller.addValue,
//                   icon: Icon(
//                     Icons.check_outlined,
//                     weight: 3,
//                   )),
//             ),
//           ]),
//       body: Column(
//         children: [
//           Obx(
//             () => Text(
//               'The blood sugar value is ${controller.sliderValue.value.round()} mg/dL',
//               style: TextStyle(
//                   color: deepPurple, fontSize: 25, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Obx(
//             () => Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Switch(
//                   value: controller.status.value,
//                   onChanged: (value) {
//                     controller.updateStatus(value);
//                   },
//                 ),
//                 Text(
//                   'Fasting',
//                   style: TextStyle(
//                       color: deepPurple,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20),
//                 ),
//               ],
//             ),
//           ),
//           Obx(() => SfRadialGauge(
//                 axes: <RadialAxis>[
//                   RadialAxis(
//                     radiusFactor: 0.8, // تصغير حجم المحور
//                     minimum: 0,
//                     maximum: 170,
//                     startAngle: 130,
//                     endAngle: 45,
//                     showLabels: true,
//                     labelsPosition: ElementsPosition.inside,
//                     showTicks: true,
//                     interval: 10,
//                     showFirstLabel: false,
//                     axisLineStyle:
//                         const AxisLineStyle(cornerStyle: CornerStyle.bothCurve),
//                     ranges: <GaugeRange>[
//                       controller.status.value
//                           ? GaugeRange(
//                               startValue: 70,
//                               endValue: 100,
//                               color: Colors.green,
//                             )
//                           : GaugeRange(
//                               startValue: 70,
//                               endValue: 139,
//                               color: Colors.green,
//                             ),
//                       controller.status.value
//                           ? GaugeRange(
//                               startValue: 100,
//                               endValue: 126,
//                               color: Colors.orange,
//                             )
//                           : GaugeRange(
//                               startValue: 139,
//                               endValue: 170,
//                               color: Colors.red,
//                             ),
//                       controller.status.value
//                           ? GaugeRange(
//                               startValue: 126,
//                               endValue: 170,
//                               color: Colors.red,
//                             )
//                           : GaugeRange(
//                               startValue: 0,
//                               endValue: 1,
//                             ),
//                       GaugeRange(
//                         startValue: 0,
//                         endValue: 70,
//                         color: Colors.yellow,
//                       )
//                     ],
//                     pointers: <GaugePointer>[
//                       RangePointer(
//                         value: controller.sliderValue.value,
//                         cornerStyle: CornerStyle.bothCurve,
//                         width: 12,
//                         sizeUnit: GaugeSizeUnit.logicalPixel,
//                         color: Colors.white54,
//                       ),
//                       MarkerPointer(
//                         value: controller.sliderValue.value,
//                         enableDragging: true,
//                         onValueChanged: (value) {
//                           controller.sliderValue(value);
//                         },
//                         markerHeight: 20,
//                         markerWidth: 20,
//                         markerType: MarkerType.circle,
//                         borderWidth: 2,
//                         color: deepPurple,
//                       )
//                     ],
//                     annotations: <GaugeAnnotation>[
//                       GaugeAnnotation(
//                         widget: Text(
//                           '${controller.sliderValue.value.round()} mg/dL',
//                           style: TextStyle(
//                               color: deepPurple,
//                               fontSize: 25,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         angle: 90,
//                         positionFactor: 0,
//                       ),
//                     ],
//                   )
//                 ],
//               )),
//           Obx(
//             () => Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   margin: EdgeInsets.all(10),
//                   color: Colors.green,
//                   height: 20,
//                   width: 20,
//                 ),
//                 Text('Normal'),
//                 Container(
//                   margin: EdgeInsets.all(10),
//                   color: Colors.yellow,
//                   height: 20,
//                   width: 20,
//                 ),
//                 Text('Low'),
//                 controller.status.value
//                     ? Container(
//                         margin: EdgeInsets.all(10),
//                         color: Colors.orange,
//                         height: 20,
//                         width: 20,
//                       )
//                     : Container(),
//                 controller.status.value ? Text('Prediabetes') : Container(),
//                 Container(
//                   margin: EdgeInsets.all(10),
//                   color: Colors.red,
//                   height: 20,
//                   width: 20,
//                 ),
//                 Text('High')
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
