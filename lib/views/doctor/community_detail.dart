import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/content/build_post_card.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/community.dart';
import 'package:health_bridge/models/post.dart';
import 'package:health_bridge/providers/CommunityProvider.dart';
import 'package:image_picker/image_picker.dart';

class CommunityDetailPage extends ConsumerStatefulWidget {
  final Community community;

  const CommunityDetailPage({super.key, required this.community});

  @override
  ConsumerState<CommunityDetailPage> createState() =>
      _CommunityDetailPageState();
}

class _CommunityDetailPageState extends ConsumerState<CommunityDetailPage> {
  late Community community;
  late bool isMember;

  @override
  void initState() {
    super.initState();
    community = widget.community;
    isMember = widget.community.isMember;

    Future.microtask(() {
      ref.read(communityProvider).fetchCommunityDetails(community.id);
    });
  }

  // 🟢 دايالوج إنشاء بوست جديد
  void _showCreatePostDialog(String communityId) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final loc = AppLocalizations.of(context);
    bool isPosting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc!.get('create_new_post'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: loc.get('title_optional'),
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: contentController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: loc.get('write_post_content'),
                          alignLabelWithHint: true,
                          prefixIcon: const Icon(Icons.edit_note),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                isPosting ? null : () => Navigator.pop(ctx),
                            child: Text(loc.get('cancel'),
                                style: const TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: isPosting
                                ? null
                                : () async {
                                    if (contentController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                loc.get('content_required'))),
                                      );
                                      return;
                                    }
                                    setState(() => isPosting = true);

                                    await ref
                                        .read(communityProvider)
                                        .createPost(
                                          communityId: communityId,
                                          title: titleController.text,
                                          content:
                                              contentController.text.trim(),
                                        );

                                    setState(() => isPosting = false);

                                    if (ref
                                            .read(communityProvider)
                                            .errorMessage ==
                                        null) {
                                      Navigator.pop(ctx);
                                      await ref
                                          .read(communityProvider)
                                          .fetchCommunityDetails(community.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(loc.get(
                                                'post_published_success'))),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "${loc.get('error')}: ${ref.read(communityProvider).errorMessage}",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: isPosting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.send),
                                      const SizedBox(width: 8),
                                      Text(loc.get('publish')),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🟢 دايالوج تعديل المجتمع لأي عضو
  void _showEditCommunityDialog(BuildContext context) {
    final nameController = TextEditingController(text: community.name);
    final descriptionController =
        TextEditingController(text: community.description);
    final typeController = TextEditingController(text: community.type);
    final specializationController =
        TextEditingController(text: community.specialization ?? "");
    final loc = AppLocalizations.of(context);

    File? selectedImage;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc!.get('edit_community'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // اختيار الصورة
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              selectedImage = File(pickedFile.path);
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                            image: DecorationImage(
                              image: selectedImage != null
                                  ? FileImage(selectedImage!)
                                  : (community.imageUrl.isNotEmpty
                                      ? NetworkImage(community.imageUrl)
                                      : const AssetImage('assets/community.jpg')
                                          as ImageProvider),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Center(
                            child: selectedImage == null
                                ? const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 40)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // الحقول النصية
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: loc.get('community_name'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: loc.get('description'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: typeController,
                        decoration: InputDecoration(
                          labelText: loc.get('type'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: specializationController,
                        decoration: InputDecoration(
                          labelText: loc.get('specialization'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // أزرار الإلغاء والحفظ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                isSaving ? null : () => Navigator.pop(ctx),
                            child: Text(loc.get('cancel'),
                                style: const TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: isSaving
                                ? null
                                : () async {
                                    setState(() => isSaving = true);

                                    await ref
                                        .read(communityProvider)
                                        .updateCommunity(
                                          id: community.id,
                                          name: nameController.text,
                                          description:
                                              descriptionController.text,
                                          type: typeController.text,
                                          specialization:
                                              specializationController.text,
                                          imagePath: selectedImage?.path,
                                        );

                                    setState(() => isSaving = false);

                                    if (ref
                                            .read(communityProvider)
                                            .errorMessage ==
                                        null) {
                                      Navigator.pop(ctx);
                                      await ref
                                          .read(communityProvider)
                                          .fetchCommunityDetails(community.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(loc.get(
                                                'community_updated_success'))),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "${loc.get('error')}: ${ref.read(communityProvider).errorMessage}",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.save),
                                      const SizedBox(width: 8),
                                      Text(loc.get('save')),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // تحويل التاريخ إلى نسبي
  String getRelativeTime(DateTime dateTime, AppLocalizations loc) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes > 1 ? loc.get('minutes_ago') : loc.get('minute_ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours > 1 ? loc.get('hours_ago') : loc.get('hour_ago')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays > 1 ? loc.get('days_ago') : loc.get('day_ago')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(communityProvider);
    final postsData = provider.communityDetails?['posts'] as List<dynamic>?;
    final loc = AppLocalizations.of(context);

    List<Post> posts = [];
    if (postsData != null) {
      posts = postsData
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(community.name),
          actions: [
            // أي عضو يمكنه تعديل المجتمع
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditCommunityDialog(context);
              },
            ),
          ],
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: community.imageUrl.isNotEmpty
                            ? NetworkImage(community.imageUrl)
                            : const AssetImage('assets/community.jpg')
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: community.imageUrl.isNotEmpty
                              ? NetworkImage(community.imageUrl)
                              : null,
                          child: community.imageUrl.isEmpty
                              ? const Icon(Icons.group, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(community.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                community.description.isNotEmpty
                                    ? community.description
                                    : loc!.get('no_description'),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                      '${community.members} ${loc!.get('members')}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  const SizedBox(width: 8),
                                  Text('${community.likes} ${loc.get('likes')}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  if (isMember)
                    Opacity(
                      opacity: 0.9,
                      child: GestureDetector(
                        onTap: () {
                          _showCreatePostDialog(community.id);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 1, color: Color(0xFFE7E8EC)),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 21,
                                top: 13,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const ShapeDecoration(
                                          color: blue3, shape: OvalBorder()),
                                      child: const Icon(Icons.post_add_rounded,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      loc.get('create_post'),
                                      style: const TextStyle(
                                        color: Color(0xFF939393),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (posts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(loc.get('no_posts_yet'),
                          style: TextStyle(color: Colors.grey[600])),
                    )
                  else
                    ...posts
                        .map((post) => buildPostCard(context, post, loc))
                        .toList(),
                ],
              ),
      ),
    );
  }
}
