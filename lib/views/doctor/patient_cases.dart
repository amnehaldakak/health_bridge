import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_bridge/config/content/patient_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_bridge/service/api_service.dart';
import 'package:health_bridge/models/case.dart';
import 'package:health_bridge/models/patient.dart';
import 'package:health_bridge/constant/color.dart';

class PatientCases extends StatefulWidget {
  final PatientModel patient;

  const PatientCases({super.key, required this.patient});

  @override
  State<PatientCases> createState() => _PatientCasesState();
}

class _PatientCasesState extends State<PatientCases> {
  late Future<List<Case>> _casesFuture;
  final ApiService _apiService = ApiService();
  String? userRole;
  bool hasApproval = false; // حالة الموافقة للطبيب

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    final prefs = await SharedPreferences.getInstance();
    userRole = prefs.getString('user_role');

    await _checkPendingApproval();

    setState(() {
      _casesFuture =
          _apiService.getPatientCasesByRole(userRole, widget.patient.id);
    });
  }

  Future<void> _checkPendingApproval() async {
    try {
      final pending = await _apiService.getPendingApprovals();
      // تحقق إذا المريض موجود ضمن الطلبات المعلقة
      final hasPending = pending.any((approval) =>
          approval['patient_id'] == widget.patient.id &&
          approval['status'] == 'pending');
      setState(() {
        hasApproval = !hasPending; // إذا لا يوجد طلب معلق، يعني حصلت الموافقة
      });
    } catch (e) {
      // في حالة الخطأ، نفترض أن الموافقة لم تتحصل بعد
      setState(() {
        hasApproval = false;
      });
    }
  }

  Future<void> _refreshCases() async {
    final prefs = await SharedPreferences.getInstance();
    userRole = prefs.getString('user_role');
    final cases =
        await _apiService.getPatientCasesByRole(userRole, widget.patient.id);
    setState(() {
      _casesFuture = Future.value(cases);
    });
  }

  Future<void> _requestPatientApproval() async {
    try {
      // استدعاء API لإرسال طلب الموافقة (يمكنك تعديل هذه الدالة حسب API الفعلي)
      // await _apiService.requestApproval(widget.patient.id);

      // مؤقت: نعتبر أن المريض وافق بعد الضغط
      setState(() {
        hasApproval = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم إرسال طلب الموافقة للمريض"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("فشل في طلب الموافقة: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshCases,
        child: CustomScrollView(
          slivers: [
            /// 🔹 الهيدر
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: theme.colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  patient.user.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, blue3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.onSecondary,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (userRole == "doctor")
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PatientCard(
                    patient: patient,
                  ),
                ),
              ),

            /// 🔹 عرض سجل الحالات فقط إذا حصل الطبيب على الموافقة
            if (userRole == "doctor") ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "سجلات الحالات",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: blue3,
                    ),
                  ),
                ),
              ),
              FutureBuilder<List<Case>>(
                future: _casesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()));
                  } else if (snapshot.hasError) {
                    return SliverFillRemaining(
                        child: Center(
                            child: Text("خطأ: ${snapshot.error}",
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: blue3))));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                        child: Center(
                            child: Text("لا يوجد حالات",
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: blue3))));
                  }

                  final cases = snapshot.data!;

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
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              caseItem.diagnosis ?? "غير محدد",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: blue3,
                              ),
                            ),
                            subtitle: Text(
                              "تم التحديث: ${caseItem.updatedAt?.split("T").first ?? "غير معروف"}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: blue3.withOpacity(0.7),
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: blue3.withOpacity(0.6), size: 18),
                            onTap: () {
                              context.pushNamed('patient_state',
                                  extra: caseItem);
                            },
                          ),
                        );
                      },
                      childCount: cases.length,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),

      /// 🔹 زر إضافة حالة (للطبيب فقط)
      floatingActionButton: userRole == "doctor"
          ? FloatingActionButton.extended(
              onPressed: () {
                context.pushNamed("add_case", extra: patient.id);
              },
              label: Text("إضافة حالة",
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
              icon: const Icon(Icons.add),
              backgroundColor: blue3,
            )
          : null,
    );
  }
}
