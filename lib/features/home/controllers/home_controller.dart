import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/i18n/locale_keys.dart';

/// Sections of the single-page home screen, in scroll order.
enum HomeSection {
  home(LocaleKeys.navHome, Icons.home_outlined, Icons.home_rounded),
  skills(LocaleKeys.navSkills, Icons.auto_awesome_outlined, Icons.auto_awesome),
  projects(
    LocaleKeys.navProjects,
    Icons.work_outline_rounded,
    Icons.work_rounded,
  ),
  contact(
    LocaleKeys.navContact,
    Icons.mail_outline_rounded,
    Icons.mail_rounded,
  );

  const HomeSection(this.labelKey, this.icon, this.selectedIcon);

  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;
}

/// Owns the home scroll view: smooth scrolling to a section when a nav item
/// is tapped, and "scroll-spy" to highlight the section currently in view.
class HomeController extends GetxController {
  final scrollController = ScrollController();
  final sectionKeys = {for (final s in HomeSection.values) s: GlobalKey()};

  final activeSection = HomeSection.home.obs;
  final showBackToTop = false.obs;

  bool _isAutoScrolling = false;
  bool _spyScheduled = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  Future<void> scrollTo(HomeSection section) async {
    final context = sectionKeys[section]?.currentContext;
    if (context == null) return;
    activeSection.value = section;
    _isAutoScrolling = true;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
    _isAutoScrolling = false;
  }

  void _onScroll() {
    showBackToTop.value = scrollController.position.pixels > 600;
    if (_isAutoScrolling || _spyScheduled) return;

    // Section positions are only up to date after the next layout.
    _spyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spyScheduled = false;
      if (scrollController.hasClients) _updateActiveSection();
    });
  }

  void _updateActiveSection() {
    final position = scrollController.position;

    // At the very bottom the last section wins even if it is short.
    if (position.pixels >= position.maxScrollExtent - 8) {
      activeSection.value = HomeSection.values.last;
      return;
    }

    // Otherwise the last section whose top has passed ~35 % of the viewport.
    final threshold = position.viewportDimension * 0.35;
    for (final section in HomeSection.values.reversed) {
      final box =
          sectionKeys[section]?.currentContext?.findRenderObject()
              as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= threshold) {
        activeSection.value = section;
        return;
      }
    }
    activeSection.value = HomeSection.home;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
