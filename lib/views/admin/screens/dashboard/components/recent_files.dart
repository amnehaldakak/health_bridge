import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/models/doctor.dart';
import 'package:health_bridge/providers/dashboard_providers.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../constants.dart';

class PendingDoctorsTable extends ConsumerWidget {
  const PendingDoctorsTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(pendingDoctorsProvider);

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pending Doctors",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: defaultPadding),
          doctorsAsync.when(
            data: (doctors) {
              if (doctors.isEmpty) {
                return const Center(
                  child: Text("لا يوجد أطباء بانتظار الموافقة"),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: defaultPadding,
                  columns: const [
                    DataColumn(label: Text("#")),
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Specialization")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: doctors.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final doc = entry.value;

                    return DataRow(
                      cells: [
                        DataCell(Text('${idx + 1}')),
                        DataCell(Text(doc.user?.name ?? "-")),
                        DataCell(Text(doc.specialization ?? "-")),
                        DataCell(Text(doc.user?.email ?? "-")),
                        DataCell(Row(
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  showCertificateDialog(context, ref, doc.id!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                foregroundColor: Colors.blue,
                              ),
                              child: const Text("View Certificate"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(pendingDoctorsProvider.notifier)
                                  .approveOrRejectDoctor(doc.id!, 'approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[50],
                                foregroundColor: Colors.green[800],
                              ),
                              child: const Text("Approve"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(pendingDoctorsProvider.notifier)
                                  .approveOrRejectDoctor(doc.id!, 'reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[50],
                                foregroundColor: Colors.red[800],
                              ),
                              child: const Text("Reject"),
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err")),
          ),
        ],
      ),
    );
  }

  // عرض شهادة الطبيب داخل Dialog
  void showCertificateDialog(
      BuildContext context, WidgetRef ref, int doctorId) {
    showDialog(
      context: context,
      builder: (_) {
        final certAsync = ref.watch(certificateProvider(doctorId));
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.7,
            child: certAsync.when(
              data: (bytes) {
                if (_isPdf(bytes)) {
                  return SfPdfViewer.memory(bytes);
                } else {
                  return Image.memory(bytes, fit: BoxFit.contain);
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text("Failed to load certificate: $err")),
            ),
          ),
        );
      },
    );
  }

  /// يتحقق إذا الملف PDF عبر أول 4 بايت (صيغة PDF تبدأ بـ "%PDF")
  bool _isPdf(Uint8List bytes) {
    const pdfHeader = [0x25, 0x50, 0x44, 0x46]; // %PDF
    if (bytes.length < 4) return false;
    for (int i = 0; i < 4; i++) {
      if (bytes[i] != pdfHeader[i]) return false;
    }
    return true;
  }
}
