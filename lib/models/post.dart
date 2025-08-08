class Post {
  final String id;
  final String title;
  final String date;
  final String content;
  final String author;
  final int likes;
  final int comments;
  final int shares;
  final String? imageUrl;

  Post({
    required this.id,
    required this.title,
    required this.date,
    required this.content,
    required this.author,
    required this.likes,
    required this.comments,
    required this.shares,
    this.imageUrl,
  });
}
