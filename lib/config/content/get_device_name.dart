import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<String> getDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return "${androidInfo.manufacturer} ${androidInfo.model}";
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return "${iosInfo.name}"; // اسم الجهاز على iOS
  } else {
    return "Unknown Device";
  }
}
