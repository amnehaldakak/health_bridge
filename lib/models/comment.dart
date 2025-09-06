import 'package:timeago/timeago.dart' as timeago;

class Comment {
  final String id;
  final String authorName;
  final String? authorImageUrl;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.authorName,
    this.authorImageUrl,
    required this.content,
    required this.createdAt,
  });

  /// 🟢 الوقت النسبي (حسب اللغة المختارة)
  String timeAgo(String locale) {
    return timeago.format(createdAt, locale: locale);
  }

  /// 🟢 تحويل من JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    String name = 'Unknown';
    String? imageUrl;

    if (json['doctor'] != null && json['doctor']['user'] != null) {
      name = json['doctor']['user']['name'] ?? 'Unknown Doctor';
      imageUrl = json['doctor']['user']['profile_picture'];
    } else if (json['patient'] != null && json['patient']['user'] != null) {
      name = json['patient']['user']['name'] ?? 'Unknown Patient';
      imageUrl = json['patient']['user']['profile_picture'];
    }

    return Comment(
      id: json['id'].toString(),
      authorName: name,
      authorImageUrl: imageUrl,
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// 🟢 تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
