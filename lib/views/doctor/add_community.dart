import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/controller/add_community_controller.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/providers/CommunityProvider.dart';
import 'package:image_picker/image_picker.dart';

class AddCommunity extends ConsumerStatefulWidget {
  const AddCommunity({super.key});

  @override
  ConsumerState<AddCommunity> createState() => _AddCommunityState();
}

class _AddCommunityState extends ConsumerState<AddCommunity> {
  final _controller = AddCommunityController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _controller.imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(communityProvider);
    final notifier = ref.read(communityProvider.notifier);
    final width = MediaQuery.of(context).size.width;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc!.get('create_community'))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // صورة الغلاف
            GestureDetector(
              onTap: _pickImage,
              child: _controller.imagePath != null
                  ? Image.file(
                      File(_controller.imagePath!),
                      width: width,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: width,
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.camera_alt, size: 50),
                    ),
            ),
            const SizedBox(height: 20),
            // الفورم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    controller: _controller.nameController,
                    decoration:
                        InputDecoration(labelText: loc.get('community_name')),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller.descriptionController,
                    decoration:
                        InputDecoration(labelText: loc.get('description')),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller.specializationController,
                    decoration:
                        InputDecoration(labelText: loc.get('specialization')),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _controller.selectedType,
                    items: [
                      DropdownMenuItem(
                          value: "public", child: Text(loc.get('public'))),
                      DropdownMenuItem(
                          value: "private", child: Text(loc.get('private'))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _controller.selectedType = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  provider.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            String token =
                                "USER_TOKEN"; // جيبه من SharedPreferences أو AuthProvider
                            await notifier.createCommunity(
                              name: _controller.nameController.text,
                              description:
                                  _controller.descriptionController.text,
                              type: _controller.selectedType,
                              specialization:
                                  _controller.specializationController.text,
                              imagePath: _controller.imagePath,
                            );

                            if (provider.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.errorMessage!)),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text(loc.get('community_created'))),
                              );
                              context.pop();
                            }
                          },
                          child: Text(loc.get('create')),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
