import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/views/admin/controllers/menu_app_controller.dart';
import 'package:health_bridge/views/admin/responsive.dart';
import 'package:health_bridge/views/admin/screens/dashboard/dashboard_screen.dart';
import 'components/side_menu.dart';

// تأكد من تعريف هذا الـ Provider
final menuAppControllerProvider = Provider<MenuAppController>((ref) {
  return MenuAppController();
});

class MainScreen extends ConsumerWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuController = ref.read(menuAppControllerProvider);

    return Scaffold(
      key: menuController.scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              const Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: DashboardScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
