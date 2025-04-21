import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/i18n/locale_keys.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/settings_controls.dart';
import '../controllers/home_controller.dart';

const double _headerHeight = 72;

/// Frosted-glass sticky header with section links (web / desktop / tablet).
class DesktopHeader extends GetView<HomeController>
    implements PreferredSizeWidget {
  const DesktopHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(_headerHeight);

  @override
  Widget build(BuildContext context) {
    return _Frosted(
      child: MaxWidthContainer(
        child: SizedBox(
          height: _headerHeight,
          child: Row(
            children: [
              LogoMark(
                showName: context.isDesktop,
                onTap: () => controller.scrollTo(HomeSection.home),
              ),
              const Spacer(),
              for (final section in HomeSection.values)
                _NavLink(section: section),
              const SizedBox(width: AppSpacing.sm),
              const LanguageMenuButton(),
              const ThemeToggleButton(),
              if (context.isDesktop) ...[
                const SizedBox(width: AppSpacing.xs),
                FilledButton(
                  onPressed: () => controller.scrollTo(HomeSection.contact),
                  child: Text(LocaleKeys.hireMe.tr),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppDurations.slow).slideY(begin: -0.4, end: 0);
  }
}

class _NavLink extends GetView<HomeController> {
  const _NavLink({required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.activeSection.value == section;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        child: TextButton(
          onPressed: () => controller.scrollTo(section),
          style: TextButton.styleFrom(
            foregroundColor: active
                ? context.colors.primary
                : context.colors.onSurface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(section.labelKey.tr),
              const SizedBox(height: 4),
              // Animated underline for the active section.
              AnimatedContainer(
                duration: AppDurations.medium,
                curve: Curves.easeOutCubic,
                height: 2,
                width: active ? 20 : 0,
                decoration: BoxDecoration(
                  gradient: context.palette.heroGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Compact app bar for phones: logo + language + theme.
class MobileAppBar extends GetView<HomeController>
    implements PreferredSizeWidget {
  const MobileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return _Frosted(
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.sm,
              end: AppSpacing.xxs,
            ),
            child: Row(
              children: [
                LogoMark(
                  showName: false,
                  onTap: () => controller.scrollTo(HomeSection.home),
                ),
                const Spacer(),
                const LanguageMenuButton(),
                const ThemeToggleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Blurred translucent background with a hairline bottom border.
class _Frosted extends StatelessWidget {
  const _Frosted({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.themeData.scaffoldBackgroundColor.withValues(
              alpha: 0.8,
            ),
            border: Border(
              bottom: BorderSide(color: context.palette.cardBorder),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
