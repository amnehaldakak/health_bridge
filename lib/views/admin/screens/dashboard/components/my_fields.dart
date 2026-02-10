import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/providers/dashboard_providers.dart';
import 'package:health_bridge/views/admin/responsive.dart';
import '../../../constants.dart';
import 'file_info_card.dart';

class MyFiles extends ConsumerWidget {
  const MyFiles({Key? key}) : super(key: key);

  final Map<String, String> icons = const {
    'الأطباء المعتمدون': 'assets/icons/noun-doctors-8036395.svg',
    'المرضى': 'assets/icons/noun-patient-7440406.svg',
    'المجتمعات العامة': 'assets/icons/noun-public-service-7042512.svg',
    'المجتمعات الخاصة': 'assets/icons/noun-community-7884611.svg',
  };

  final Map<String, Color> colors = const {
    'الأطباء المعتمدون': Colors.blue,
    'المرضى': Colors.green,
    'المجتمعات العامة': Colors.orange,
    'المجتمعات الخاصة': Colors.red,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size _size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      data: (data) {
        // تحويل البيانات إلى قائمة كروت
        final dashboardItems = data.entries.map((entry) {
          return {
            'title': entry.key,
            'numOfFiles': entry.value,
            'svgSrc': icons[entry.key],
            'color': colors[entry.key],
            'totalStorage': '', // يمكن حذف أو تعديل إذا لا يوجد
            'percentage': 100, // يمكن تعديل حسب حاجتك
          };
        }).toList();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dashboard",
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Responsive(
              mobile: FileInfoCardGridView(
                data: dashboardItems,
                crossAxisCount: _size.width < 650 ? 2 : 4,
                childAspectRatio:
                    _size.width < 650 && _size.width > 350 ? 1.3 : 1,
              ),
              tablet: FileInfoCardGridView(data: dashboardItems),
              desktop: FileInfoCardGridView(
                data: dashboardItems,
                childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("حدث خطأ: $e")),
    );
  }
}

// ------------------------
// FileInfoCardGridView
// ------------------------
class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    required this.data,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final List<Map<String, dynamic>> data;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => FileInfoCard(
        info: data[index],
      ),
    );
  }
}
