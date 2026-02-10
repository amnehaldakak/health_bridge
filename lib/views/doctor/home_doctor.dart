import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/content/build_post_card.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/post.dart';
import 'package:health_bridge/providers/random_post_provider.dart';
import 'package:health_bridge/views/doctor/post_detils.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeDoctor extends ConsumerWidget {
  const HomeDoctor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);

    final postsState = ref.watch(randomPostsProvider);

    return Scaffold(
      body: postsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text(err.toString())),
        data: (posts) {
          if (posts.isEmpty) {
            return Center(
                child: Text(loc?.get('no_posts') ?? 'No posts found'));
          }

          // هنا نستخدم RefreshIndicator
          return RefreshIndicator(
            onRefresh: () async {
              // إعادة تحميل المنشورات
              ref.refresh(randomPostsProvider);
              // انتظار حتى يتم تحميل البيانات مرة أخرى
              await ref.read(randomPostsProvider.notifier).fetchRandomPosts();
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return buildPostCard(context, post, loc!);
              },
            ),
          );
        },
      ),
    );
  }
}
