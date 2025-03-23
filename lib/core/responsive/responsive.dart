import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Width breakpoints (logical pixels), aligned with Material 3 window classes.
abstract final class Breakpoints {
  /// < 600: phones.
  static const double tablet = 600;

  /// ≥ 840: enough room for the top header with inline nav links.
  /// Below this, navigation moves to a bottom [NavigationBar].
  static const double topNav = 840;

  /// ≥ 1024: desktop / wide web.
  static const double desktop = 1024;

  /// Content never grows wider than this on huge screens.
  static const double maxContentWidth = 1200;
}

enum ScreenType { mobile, tablet, desktop }

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenType get screenType {
    final w = screenWidth;
    if (w >= Breakpoints.desktop) return ScreenType.desktop;
    if (w >= Breakpoints.tablet) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;

  /// Top header navigation (web/desktop/landscape tablet) vs bottom nav bar.
  bool get useTopNav => screenWidth >= Breakpoints.topNav;

  /// Pick a value per screen type; missing values fall back to the next
  /// smaller size (desktop → tablet → mobile).
  T responsive<T>(T mobile, {T? tablet, T? desktop}) {
    return switch (screenType) {
      ScreenType.desktop => desktop ?? tablet ?? mobile,
      ScreenType.tablet => tablet ?? mobile,
      ScreenType.mobile => mobile,
    };
  }

  /// Horizontal page gutter for the current screen size.
  double get pageGutter =>
      responsive(AppSpacing.md, tablet: AppSpacing.xl, desktop: AppSpacing.xxl);
}

/// Swaps whole widget trees per screen type. Uses the *parent's* constraints,
/// so it also works inside split panes and dialogs.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w >= Breakpoints.desktop) {
          return (desktop ?? tablet ?? mobile)(context);
        }
        if (w >= Breakpoints.tablet) return (tablet ?? mobile)(context);
        return mobile(context);
      },
    );
  }
}

/// Centers [child], caps it at [Breakpoints.maxContentWidth] and applies the
/// responsive page gutter. Wrap every page section in this.
class MaxWidthContainer extends StatelessWidget {
  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: context.pageGutter),
          child: child,
        ),
      ),
    );
  }
}
