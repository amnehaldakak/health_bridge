import 'package:flutter/material.dart';

class AddCommunityController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();

  String selectedType = "public"; // القيمة الافتراضية
  String? imagePath;

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    specializationController.dispose();
  }
}
