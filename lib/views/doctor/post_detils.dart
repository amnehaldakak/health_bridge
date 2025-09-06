import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/comment.dart';
import 'package:health_bridge/models/post.dart';
import 'package:health_bridge/providers/CommunityProvider.dart';
import 'package:health_bridge/providers/case_provider.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  List<Comment> comments = [];
  bool isLoading = true;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
    // 🟢 إذا المنشور يحتوي على حالة، جلب تفاصيل الحالة
    if (widget.post.caseId != null) {
      Future.microtask(() {
        ref.read(caseProvider).fetchCaseDetails(widget.post.caseId!);
      });
    }
  }

  Future<void> _loadComments() async {
    final provider = ref.read(communityProvider);
    setState(() => isLoading = true);

    final postData =
        await provider.fetchPostWithComments(widget.post.id.toString());
    if (postData != null && postData['comments'] != null) {
      comments = (postData['comments'] as List)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    setState(() => isLoading = false);
  }

  // 🟢 إضافة تعليق
  Future<void> _addComment(String content) async {
    if (content.trim().isEmpty) return;

    final provider = ref.read(communityProvider);
    await provider.addComment(
        postId: widget.post.id.toString(), content: content);

    commentController.clear();
    await _loadComments(); // إعادة تحميل التعليقات بعد الإضافة
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeCode = loc!.locale.languageCode; // "ar" أو "en"

    final caseState = ref.watch(caseProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title ?? loc.get('post'))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🟢 معلومات الناشر
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: widget.post.authorImageUrl !=
                                      null
                                  ? NetworkImage(widget.post.authorImageUrl!)
                                  : null,
                              child: widget.post.authorImageUrl == null
                                  ? Text(widget.post.authorName.substring(0, 1))
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.authorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                Text(
                                  widget
                                      .post.timeAgo, // حسب اللغة من Post model
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 🟢 محتوى البوست
                        Text(
                          widget.post.content ?? '',
                          style: const TextStyle(fontSize: 15),
                        ),

                        const SizedBox(height: 16),

                        // 🔹 إذا هناك حالة مرتبطة، عرض معلوماتها بدون زر
                        if (widget.post.caseId != null)
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: Colors.grey.shade100,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: caseState.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : caseState.medicalCase == null
                                      ? Text(loc.get('case_not_found'))
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              loc.get('case_details'),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${loc.get('main_complaint')}: ${caseState.medicalCase!.chiefComplaint ?? loc.get('not_specified')}",
                                            ),
                                            Text(
                                              "${loc.get('symptoms')}: ${caseState.medicalCase!.symptoms ?? loc.get('not_specified')}",
                                            ),
                                            Text(
                                              "${loc.get('diagnosis')}: ${caseState.medicalCase!.diagnosis ?? loc.get('not_specified')}",
                                            ),
                                          ],
                                        ),
                            ),
                          ),

                        const Divider(),
                        Text(
                          loc.get('comments'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  // 🟢 قائمة التعليقات
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return _buildCommentCard(comment, localeCode);
                    },
                  ),
                ],
              ),
            ),

      // 🟢 حقل إضافة تعليق
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: loc.get('write_comment'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _addComment(commentController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment, String localeCode) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: comment.authorImageUrl != null
                      ? NetworkImage(comment.authorImageUrl!)
                      : null,
                  child: comment.authorImageUrl == null
                      ? Text(comment.authorName.substring(0, 1))
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  comment.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  comment.timeAgo(localeCode), // الوقت حسب اللغة المختارة
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }
}
