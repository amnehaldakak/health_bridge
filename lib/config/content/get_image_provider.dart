import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider getImageProvider(String? pathOrUrl) {
  if (pathOrUrl == null || pathOrUrl.isEmpty) {
    return const AssetImage('assets/default_cover.png');
  } else if (pathOrUrl.startsWith('http')) {
    return NetworkImage(pathOrUrl);
  } else {
    return FileImage(File(pathOrUrl));
  }
}
