import 'package:flutter/material.dart';

/// Design tokens shared by both themes. Widgets should read spacing, radii and
/// durations from here rather than hard-coding magic numbers.

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 72;
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
}

/// Elevation scale (Material 3 tonal elevation levels).
abstract final class AppElevation {
  static const double none = 0;
  static const double low = 1;
  static const double mid = 3;
  static const double high = 8;
}

/// Brand colours. Everything else is derived from [seed] by Material 3.
abstract final class AppColors {
  static const Color seed = Color(0xFF5B5BF7); // Indigo-violet
  static const Color accent = Color(0xFF14C8B4); // Teal

  static const Color darkBackground = Color(0xFF0B0D17);
  static const Color darkSurface = Color(0xFF12152A);
  static const Color lightBackground = Color(0xFFF7F8FC);
}

/// Theme-dependent tokens that Material's [ColorScheme] doesn't cover.
/// Access with `context.palette` (see `context_ext.dart`).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.heroGradient,
    required this.cardBorder,
    required this.subtleSurface,
    required this.mutedText,
    required this.glow,
  });

  final Gradient heroGradient;
  final Color cardBorder;
  final Color subtleSurface;
  final Color mutedText;
  final Color glow;

  static const light = AppPalette(
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.seed, AppColors.accent],
    ),
    cardBorder: Color(0x1A0B0D17),
    subtleSurface: Color(0xFFEEF0FA),
    mutedText: Color(0xFF5C6078),
    glow: Color(0x335B5BF7),
  );

  static const dark = AppPalette(
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF7B7BFF), AppColors.accent],
    ),
    cardBorder: Color(0x1FFFFFFF),
    subtleSurface: Color(0xFF181C36),
    mutedText: Color(0xFFA2A7C3),
    glow: Color(0x407B7BFF),
  );

  @override
  AppPalette copyWith({
    Gradient? heroGradient,
    Color? cardBorder,
    Color? subtleSurface,
    Color? mutedText,
    Color? glow,
  }) {
    return AppPalette(
      heroGradient: heroGradient ?? this.heroGradient,
      cardBorder: cardBorder ?? this.cardBorder,
      subtleSurface: subtleSurface ?? this.subtleSurface,
      mutedText: mutedText ?? this.mutedText,
      glow: glow ?? this.glow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}
