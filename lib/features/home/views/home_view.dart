import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_tokens.dart';
import '../../contact/widgets/contact_section.dart';
import '../../projects/widgets/projects_section.dart';
import '../../skills/widgets/skills_section.dart';
import '../controllers/home_controller.dart';
import '../widgets/app_header.dart';
import '../widgets/footer.dart';
import '../widgets/hero_section.dart';
import '../widgets/mobile_nav_bar.dart';

/// Single-page landing screen. Navigation adapts to the width:
/// * ≥ 840 px: sticky top header with inline section links.
/// * < 840 px: compact app bar + Material 3 bottom [NavigationBar].
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final topNav = context.useTopNav;

    return Scaffold(
      appBar: topNav ? const DesktopHeader() : const MobileAppBar(),
      bottomNavigationBar: topNav ? null : const MobileNavBar(),
      floatingActionButton: topNav ? const _BackToTopButton() : null,
      body: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          children: [
            _section(HomeSection.home, const HeroSection()),
            _section(HomeSection.skills, const SkillsSection()),
            _section(HomeSection.projects, const ProjectsSection()),
            _section(HomeSection.contact, const ContactSection()),
            const Footer(),
          ],
        ),
      ),
    );
  }

  /// Attaches the section's [GlobalKey] so nav items can scroll to it.
  Widget _section(HomeSection section, Widget child) =>
      KeyedSubtree(key: controller.sectionKeys[section], child: child);
}

class _BackToTopButton extends GetView<HomeController> {
  const _BackToTopButton();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedScale(
        scale: controller.showBackToTop.value ? 1 : 0,
        duration: AppDurations.fast,
        child: FloatingActionButton.small(
          heroTag: 'back-to-top',
          onPressed: () => controller.scrollTo(HomeSection.home),
          child: const Icon(Icons.arrow_upward_rounded),
        ),
      ),
    );
  }
}
