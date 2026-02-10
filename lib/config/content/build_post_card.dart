import 'package:flutter/material.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/post.dart';
import 'package:health_bridge/views/doctor/community_detail.dart';
import 'package:health_bridge/views/doctor/post_detils.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget buildPostCard(BuildContext context, Post post, AppLocalizations loc) {
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
            // معلومات الكاتب والوقت + اسم المجتمع
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.authorImageUrl != null
                      ? NetworkImage(post.authorImageUrl!)
                      : const AssetImage("assets/profile.jpg") as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          // ✅ عرض اسم المجتمع فقط إذا كان موجودًا
                          if (post.community != null) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 16,
                              color: blue3,
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CommunityDetailPage(
                                        community: post.community!),
                                  ),
                                );
                              },
                              child: Text(
                                post.community!.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: blue3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.createdAt != null
                            ? timeago.format(
                                post.createdAt!,
                                locale: loc.locale.languageCode,
                              )
                            : '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

            // زر عرض تفاصيل الحالة الطبية إذا كان موجود
            if (post.caseId != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailPage(post: post),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.medical_services,
                    size: 20,
                    color: blue5,
                  ),
                  label: Text(
                    loc.get('view_case'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: blue5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue3,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 1,
                  ),
                ),
              ),

            const Divider(height: 24),

            // أزرار التفاعل
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildActionButton(Icons.comment, loc.get('comment'), loc),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildActionButton(IconData icon, String label, AppLocalizations loc) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Text(
        ' $label',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    ],
  );
}
