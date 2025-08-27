import 'package:flutter/material.dart';
import 'package:health_bridge/models/comment.dart';
import 'package:health_bridge/models/post.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  final List<Comment> comments = const [
    Comment(
      id: '1',
      author: 'Jackson Allen',
      content:
          'Great idea, the app gets better and better every time. You can immediately see that it was made "for people"',
      date: '5 Sep at 10:49',
      replies: 0,
    ),
    Comment(
      id: '2',
      author: 'Evan Phillips',
      content: 'How does it work with raster?',
      date: '5 Sep at 10:49',
      replies: 0,
    ),
    Comment(
      id: '3',
      author: 'Jackson Allen',
      content: 'Cool',
      date: '5 Sep at 10:49',
      replies: 0,
    ),
    Comment(
      id: '4',
      author: 'Camila Reed',
      content: 'I\'ll leave this comment here',
      date: '5 Sep at 10:49',
      replies: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Post content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        post.date,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Source: ${post.author}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite_border,
                              size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${post.likes}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.comment,
                              size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${post.comments}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.share, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${post.shares}'),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Comments list
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _buildCommentCard(comment);
              },
            ),

            // Show more comments button
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Show more comments'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
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
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    comment.author.substring(0, 1),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  comment.author,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  comment.date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('Reply'),
            ),
          ],
        ),
      ),
    );
  }
}
