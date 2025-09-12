import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/views/admin/controllers/menu_app_controller.dart';
import 'package:health_bridge/views/admin/responsive.dart';

import '../../../constants.dart';

// تعريف Provider للـ MenuAppController
final menuAppControllerProvider = Provider<MenuAppController>((ref) {
  return MenuAppController();
});

class Header extends ConsumerWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              ref.read(menuAppControllerProvider).controlMenu();
            },
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Dashboard",
            style: theme.textTheme.titleLarge,
          ),
        // if (!Responsive.isMobile(context))
        //   Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        // const Expanded(child: SearchField()),
        // const ProfileCard(),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor, // خلفية من Theme
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: theme.dividerColor), // خط حدود ديناميكي
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/images/profile_pic.png",
            height: 38,
          ),
          if (!Responsive.isMobile(context))
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text(
                "Angelina Jolie",
                style: theme.textTheme.bodyMedium,
              ),
            ),
          Icon(Icons.keyboard_arrow_down, color: theme.iconTheme.color),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 0.75),
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: theme.primaryColor, // لون رئيسي من Theme
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset(
              "assets/icons/Search.svg",
              colorFilter:
                  ColorFilter.mode(theme.iconTheme.color!, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
