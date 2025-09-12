import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/controller/communities_page_controller.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/providers/communities_page_provider.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:health_bridge/models/post.dart';
import 'package:health_bridge/models/community.dart';

class RandomPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final Ref ref;

  RandomPostsNotifier(this.ref) : super(const AsyncValue.loading()) {
    Future.microtask(fetchRandomPosts);
  }

  Future<void> fetchRandomPosts() async {
    try {
      state = const AsyncValue.loading();

      final controller = ref.read(communitiesPageControllerProvider);
      await controller.fetchCommunities();
      final communities = controller.communities;

      List<Post> allPosts = [];

      final memberCommunities =
          communities.where((c) => c['is_member'] == true).toList();

      for (var communityJson in memberCommunities) {
        final communityId = communityJson['id'].toString();
        final community =
            Community.fromJson(communityJson); // 🟢 تحويل كامل الكائن

        final postsData =
            await ref.read(apiServiceProvider).getCommunityDetails(communityId);

        if (postsData != null &&
            postsData['community'] != null &&
            postsData['community']['posts'] != null) {
          final posts = (postsData['community']['posts'] as List)
              .map((p) => Post.fromJson(
                    p as Map<String, dynamic>,
                    community: community, // 🟢 تمرير الكائن بالكامل
                  ))
              .toList();
          allPosts.addAll(posts);
        }
      }

      allPosts.shuffle();
      state = AsyncValue.data(allPosts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final randomPostsProvider =
    StateNotifierProvider<RandomPostsNotifier, AsyncValue<List<Post>>>(
  (ref) => RandomPostsNotifier(ref),
);
