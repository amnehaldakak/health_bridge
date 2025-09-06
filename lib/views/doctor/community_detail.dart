import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/community.dart';
import 'package:health_bridge/models/post.dart';
import 'package:health_bridge/providers/CommunityProvider.dart';
import 'package:health_bridge/views/doctor/patient_state.dart';
import 'package:health_bridge/views/doctor/post_detils.dart';

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
  String dropdownValue = 'Member';

  @override
  void initState() {
    super.initState();
    community = widget.community;
    isMember = widget.community.isMember;

    // جلب تفاصيل المجتمع والمنشورات
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
                borderRadius: BorderRadius.circular(20),
              ),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                isPosting ? null : () => Navigator.pop(ctx),
                            child: Text(
                              loc.get('cancel'),
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                          content:
                                              Text(loc.get('content_required')),
                                        ),
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

                                      // تحديث الصفحة لإظهار المنشور الجديد
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
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.send),
                                      SizedBox(width: 8),
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

  // 🟢 تحويل التاريخ إلى نسبي
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

  // 🟢 كرت المنشور
  Widget _buildPostCard(BuildContext context, Post post, AppLocalizations loc) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الكاتب والوقت
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: post.authorImageUrl != null
                        ? NetworkImage(post.authorImageUrl!)
                        : const AssetImage("assets/profile.jpg")
                            as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          post.createdAt != null
                              ? getRelativeTime(post.createdAt!, loc)
                              : '',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // عنوان المنشور
              if (post.title != null && post.title!.isNotEmpty)
                Text(post.title!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              if (post.title != null && post.title!.isNotEmpty)
                const SizedBox(height: 8),

              // محتوى المنشور
              Text(
                post.content ?? '',
                style: const TextStyle(fontSize: 14),
              ),

              const Divider(height: 24),

              // أزرار التفاعل
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildActionButton(Icons.comment, loc.get('comment'), 0, loc),
                ],
              ),

              // 🔹 زر عرض تفاصيل الحالة الطبية إذا كان موجود
              if (post.caseId != null) const SizedBox(height: 12),
              if (post.caseId != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailPage(
                            post: post,
                            // يجب أن يحتوي post على medicalCase
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.medical_services, size: 18),
                    label: Text(loc.get('view_case')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, int count, AppLocalizations loc) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
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
                              Text(
                                community.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
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
                                        color: blue3,
                                        shape: OvalBorder(),
                                      ),
                                      child: const Icon(
                                        Icons.post_add_rounded,
                                        color: Colors.white,
                                      ),
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
                        .map((post) => _buildPostCard(context, post, loc))
                        .toList(),
                ],
              ),
      ),
    );
  }
}
