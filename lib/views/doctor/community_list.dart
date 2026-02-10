import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/controller/auth_controller.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/community.dart';
import 'package:health_bridge/providers/CommunityProvider.dart';
import 'package:health_bridge/providers/communities_page_provider.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/views/doctor/community_detail.dart';

class CommunitiesPage extends ConsumerStatefulWidget {
  const CommunitiesPage({super.key});

  @override
  ConsumerState<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends ConsumerState<CommunitiesPage> {
  @override
  void initState() {
    super.initState();
    // جلب المجتمعات عند فتح الصفحة
    Future.microtask(() {
      ref.read(communitiesPageControllerProvider.notifier).fetchCommunities();
    });
  }

  // اختيار صورة المجتمع مع التوكن
  ImageProvider getImageProvider(WidgetRef ref, String? url) {
    if (url == null || url.isEmpty) {
      return const AssetImage('assets/community.jpg');
    }

    final authState = ref.watch(authControllerProvider);
    final api = ref.watch(apiServiceProvider);

    final token = api.headers;

    return NetworkImage(
      url,
      headers: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(communitiesPageControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final loc = AppLocalizations.of(context);

    if (loc == null) return const SizedBox();

    final isDoctor =
        authState is Authenticated && authState.user.role == 'doctor';

    return Scaffold(
      floatingActionButton: isDoctor
          ? FloatingActionButton(
              onPressed: () {
                context.pushNamed('add_community');
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(communitiesPageControllerProvider.notifier)
                        .fetchCommunities();
                  },
                  child: ListView.builder(
                    itemCount: provider.communities.length,
                    itemBuilder: (context, index) {
                      final data = provider.communities[index];
                      final community = Community(
                        id: data['id'].toString(),
                        name: data['name'] ?? '',
                        description: data['description'] ?? '',
                        isMember: data['is_member'] ?? false,
                        members: data['members_count'] ?? 0,
                        likes: data['likes_count'] ?? 0,
                        imageUrl: data['image'] ?? '',
                        specialization: data['specialization'] ?? '',
                        type: data['type'] ?? '',
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CommunityDetailPage(community: community),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage:
                                      getImageProvider(ref, community.imageUrl),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            community.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              community.type.toLowerCase() ==
                                                      'private'
                                                  ? Icons.lock
                                                  : Icons.public,
                                              size: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
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
                                            '${community.members} ${loc.get('members')}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            '${community.likes} ${loc.get('likes')}',
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
                                community.isMember
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          loc.get('member'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () async {
                                          await ref
                                              .read(communityProvider.notifier)
                                              .joinCommunity(community.id);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "${loc.get('joining')} ${community.name}"),
                                            ),
                                          );

                                          // تحديث القائمة بعد الانضمام
                                          await ref
                                              .read(
                                                  communitiesPageControllerProvider
                                                      .notifier)
                                              .fetchCommunities();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          loc.get('join'),
                                          style: const TextStyle(
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
                    },
                  ),
                ),
    );
  }
}
