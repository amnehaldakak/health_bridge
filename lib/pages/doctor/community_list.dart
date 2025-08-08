import 'package:flutter/material.dart';
import 'package:health_bridge/models/community.dart';
import 'package:health_bridge/pages/doctor/community_detail.dart';

class CommunitiesPage extends StatelessWidget {
  final List<Community> communities = [
    Community(
      id: '1',
      name: 'Vkontakte',
      description: 'Community',
      isMember: true,
      members: 795,
      likes: 270,
      imageUrl: 'assets/vkontakte.png',
    ),
    Community(
      id: '2',
      name: 'Figma community',
      description: 'Design community',
      isMember: false,
      members: 1200,
      likes: 540,
      imageUrl: 'assets/figma.png',
    ),
    // Add more communities
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
      ),
      body: ListView.builder(
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final community = communities[index];
          return _buildCommunityCard(context, community);
        },
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context, Community community) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityDetailPage(community: community),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(community.imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      community.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${community.members} Members',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${community.likes} Likes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (community.isMember)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
