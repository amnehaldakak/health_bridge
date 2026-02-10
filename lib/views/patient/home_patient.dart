import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/content/build_post_card.dart';
import 'package:health_bridge/config/content/health_value_card.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/providers/health_value_provider.dart';
import 'package:health_bridge/providers/random_post_provider.dart';
import 'package:health_bridge/models/post.dart';

class HomePatient extends ConsumerStatefulWidget {
  const HomePatient({super.key});

  @override
  ConsumerState<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends ConsumerState<HomePatient> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // جلب آخر القيم لليوم
    final latestBP = ref.watch(latestBloodPressureTodayProvider);
    final latestSugar = ref.watch(latestSugarTodayProvider);

    // ✅ جلب البوستات العشوائية
    final randomPosts = ref.watch(randomPostsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // ✅ استدعاء الفنكشن من StateNotifier
          await ref.read(randomPostsProvider.notifier).fetchRandomPosts();
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // عنوان القسم
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                loc!.get('last_measurement'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // بطاقات القيم الصحية
            Row(
              children: [
                Expanded(
                  child: HealthValueCard(
                    cardColor: Colors.red.shade100,
                    borderColor: Colors.red,
                    iconColor: Colors.red,
                    icon: MyFlutterApp.noun_blood_pressure_7315638,
                    text: latestBP != null
                        ? "${loc.get('blood_pressure')}: ${latestBP.value}"
                        : "${loc.get('blood_pressure')}: -- / ${latestBP?.valuee ?? '--'}",
                  ),
                ),
                Expanded(
                  child: HealthValueCard(
                    cardColor: Colors.blue.shade100,
                    borderColor: Colors.blue,
                    iconColor: Colors.blue,
                    icon: MyFlutterApp.noun_diabetes_test_7357853,
                    text: latestSugar != null
                        ? "${loc.get('blood_sugar')}: ${latestSugar.value}"
                        : "${loc.get('blood_sugar')}: --",
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            randomPosts.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return Text(
                    loc.get('no_posts'),
                    style: const TextStyle(color: Colors.grey),
                  );
                }
                return Column(
                  children: posts.take(5).map((Post post) {
                    // 🟢 استخدام الكرت المخصص
                    return buildPostCard(context, post, loc);
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text(
                "خطأ أثناء تحميل البوستات: $err",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
