import 'package:flutter/material.dart';
import 'package:health_bridge/models/community.dart';
import 'package:health_bridge/models/post.dart';
import 'package:health_bridge/views/doctor/post_detils.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;

  const CommunityDetailPage({super.key, required this.community});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  final List<Post> posts = [
    Post(
      id: '1',
      title: 'مجتمع فِيغما',
      date: '10 أغسطس الساعة 14:00',
      content:
          'عند فتح الملف عبر رابط عرض فقط، لن يتم تعيين صلاحية "عرض" تلقائياً. هذا يقلل من التعقيد عند إدارة الأذونات.',
      author: 'أليسيا كورنيفيتس',
      likes: 21,
      comments: 1,
      shares: 2,
      imageUrl: null,
    ),
    Post(
      id: '2',
      title: 'أيقونات وواجهات',
      date: '11 أغسطس الساعة 11:00',
      content:
          'مجتمع فِيغما أصبح متاحاً للجميع. يمكنك استكشاف أنظمة تصميم، أيقونات، ألعاب، والمزيد...',
      author: 'فريق فِيغما',
      likes: 45,
      comments: 5,
      shares: 3,
      imageUrl:
          'https://media.istockphoto.com/id/1572436997/ro/fotografie/diversitate-%C8%99i-incluziune-la-locul-de-munc%C4%83-conducerea-lgbt.jpg?s=1024x1024&w=is&k=20&c=e53J4O5_NlzOH1yK3j8asFGbiPRd9amQC5AB_hL_Av8=',
    ),
  ];

  String dropdownValue = 'عضو';
  bool isMember = false;

  @override
  Widget build(BuildContext context) {
    final community = widget.community;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(community.name),
        ),
        body: ListView(
          children: [
            // صورة الغلاف
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1522071820081-009f0129c71c?fit=crop&w=800&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // معلومات المجتمع
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?fit=crop&w=200&q=80'),
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
                          community.description,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('${community.members} عضو',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('${community.likes} إعجاب',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (!isMember)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isMember = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text('اشترك'),
                        ),
                      if (isMember)
                        DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_drop_down),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'عضو', child: Text('عضو')),
                            DropdownMenuItem(
                                value: 'مغادرة', child: Text('مغادرة')),
                          ],
                          onChanged: (value) {
                            if (value == 'مغادرة') {
                              setState(() {
                                isMember = false;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // قائمة المنشورات
            ...posts.map((post) => _buildPostCard(context, post)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
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
              // العنوان والتاريخ
              Row(
                children: [
                  Expanded(
                    child: Text(post.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  Text(post.date,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),

              // محتوى المنشور
              Text(
                post.content,
                style: const TextStyle(fontSize: 14),
              ),

              // صورة مرفقة (إن وجدت)
              if (post.imageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // المؤلف
              Text('الناشر: ${post.author}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),

              const Divider(height: 24),

              // الإعجابات والتعليقات والمشاركة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                      Icons.favorite_border, 'إعجاب', post.likes),
                  _buildActionButton(Icons.comment, 'تعليق', post.comments),
                  _buildActionButton(Icons.share, 'مشاركة', post.shares),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, int count) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          '$count $label',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}
