import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

/// Material 3 bottom navigation for phones and portrait tablets. Tapping an
/// item scrolls to its section; the selection follows the scroll position.
class MobileNavBar extends GetView<HomeController> {
  const MobileNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => NavigationBar(
        selectedIndex: controller.activeSection.value.index,
        onDestinationSelected: (i) =>
            controller.scrollTo(HomeSection.values[i]),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final s in HomeSection.values)
            NavigationDestination(
              icon: Icon(s.icon),
              selectedIcon: Icon(s.selectedIcon),
              label: s.labelKey.tr,
            ),
        ],
      ),
    );
  }
}
