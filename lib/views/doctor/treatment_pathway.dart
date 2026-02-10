import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/content/buildMedicationItem.dart';
import 'package:health_bridge/constant/color.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/models/medication_time.dart';
import 'package:health_bridge/models/medication_group.dart';
import 'package:health_bridge/models/treatment_plan.dart';
import 'package:health_bridge/my_flutter_app_icons.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/providers/treatment_pathway_provider.dart';
import 'package:health_bridge/views/doctor/add_treatment_pathway.dart';

class TreatmentPathway extends ConsumerWidget {
  final int caseId;

  const TreatmentPathway({super.key, required this.caseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final role = ref.watch(currentUserProvider)?.role ?? '';
    final loc = AppLocalizations.of(context);

    final medicationGroupAsync = ref.watch(medicationGroupProvider(caseId));

    return Scaffold(
      appBar: AppBar(
        title: Text(loc!.get('treatment_pathway'),
            style: const TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      floatingActionButton: role == "doctor"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTreatmentPathway(caseId: caseId),
                  ),
                );
              },
              child: const Icon(MyFlutterApp.add, size: 24),
            )
          : null,
      body: medicationGroupAsync.when(
        data: (group) {
          // إذا البيانات فاضية
          if (group.medications.isEmpty &&
              (group.description?.isEmpty ?? true)) {
            return _buildEmptyState(theme, loc, role, context);
          }

          // إذا فيه بيانات لمسار علاجي
          final treatmentPlans = [
            TreatmentPlan(
              name: loc.get('treatment_plan'),
              description: group.description,
              medications: group.medications,
            ),
          ];

          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: treatmentPlans.length,
              itemBuilder: (context, index) {
                final plan = treatmentPlans[index];
                return _buildTreatmentPlanCard(
                    theme, plan, index, role, ref, loc);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          if (e.toString().contains("404")) {
            return _buildEmptyState(theme, loc, role, context);
          }
          return Center(child: Text('${loc.get('error_occurred')}: $e'));
        },
      ),
    );
  }

  /// شاشة عند عدم وجود مسار علاجي
  Widget _buildEmptyState(ThemeData theme, AppLocalizations loc, String role,
      BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            loc.get('no_treatment_pathway'),
            style: theme.textTheme.bodyLarge,
          ),
          if (role == "doctor") ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(loc.get('add_treatment_pathway')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTreatmentPathway(caseId: caseId),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTreatmentPlanCard(ThemeData theme, TreatmentPlan plan, int index,
      String role, WidgetRef ref, AppLocalizations loc) {
    void _editTreatmentPlan() async {
      String input = plan.description;
      final newPlan = await showDialog<String>(
        context: ref.context,
        builder: (context) {
          return AlertDialog(
            title: Text('${loc.get('edit')} ${plan.name}'),
            content: TextField(
              onChanged: (value) => input = value,
              controller: TextEditingController(text: input),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.get('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, input),
                child: Text(loc.get('save')),
              ),
            ],
          );
        },
      );

      if (newPlan != null && newPlan.trim().isNotEmpty) {
        plan.description = newPlan;
      }
    }

    void _editMedication(MedicationTime medication,
        {required int planIndex}) async {
      String amount = medication.dosage;
      int? timesPerDay = medication.frequency;

      final result = await showDialog<MedicationTime>(
        context: ref.context,
        builder: (context) {
          return AlertDialog(
            title: Text('${loc.get('edit')} ${medication.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: loc.get('dosage')),
                  controller: TextEditingController(text: amount),
                  onChanged: (val) => amount = val,
                ),
                TextField(
                  decoration:
                      InputDecoration(labelText: loc.get('daily_usage_times')),
                  keyboardType: TextInputType.number,
                  controller:
                      TextEditingController(text: timesPerDay.toString()),
                  onChanged: (val) =>
                      timesPerDay = int.tryParse(val) ?? timesPerDay,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.get('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    medication.copyWith(dosage: amount, frequency: timesPerDay),
                  );
                },
                child: Text(loc.get('save')),
              ),
            ],
          );
        },
      );

      if (result != null) {
        final indexMed = plan.medications
            .indexWhere((m) => m.medicationId == medication.medicationId);
        if (indexMed != -1) {
          plan.medications[indexMed] = result;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.healing, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    plan.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (role == "doctor")
                  IconButton(
                    icon: const Icon(Icons.edit_note, size: 20),
                    onPressed: _editTreatmentPlan,
                  ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              plan.description,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plan.medications.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, medIndex) {
                final med = plan.medications[medIndex];
                return MedicationItem(
                  medication: med,
                  theme: theme,
                  onEdit: role == "doctor"
                      ? () => _editMedication(med, planIndex: medIndex)
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
