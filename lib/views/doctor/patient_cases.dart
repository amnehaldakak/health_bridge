import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/patient_card.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/providers/patient_cases_provider.dart';
import 'package:health_bridge/constant/color.dart';

class PatientCasesPage extends ConsumerWidget {
  final PatientModel patient;

  const PatientCasesPage({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesAsync = ref.watch(patientCasesProvider(patient));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(patientCasesProvider(patient).notifier).refreshCases();
        },
        child: CustomScrollView(
          slivers: [
            /// 🔹 الهيدر
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.blue,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(patient.user.name),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ),

            /// 🔹 Patient Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PatientCard(patient: patient),
              ),
            ),

            /// 🔹 عرض سجل الحالات
            casesAsync.when(
              data: (cases) {
                if (cases.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("لا يوجد حالات")),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final caseItem = cases[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: blue3,
                            child: Text(
                              caseItem.id.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(caseItem.diagnosis ?? "غير محدد",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: blue3)),
                          subtitle: Text(
                            "تم التحديث: ${caseItem.updatedAt?.split("T").first ?? "غير معروف"}",
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: blue3.withOpacity(0.6), size: 18),
                          onTap: () {
                            context.pushNamed('patient_state', extra: caseItem);
                          },
                        ),
                      );
                    },
                    childCount: cases.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator())),
              error: (err, _) =>
                  SliverFillRemaining(child: Center(child: Text("خطأ: $err"))),
            ),
          ],
        ),
      ),
    );
  }
}
