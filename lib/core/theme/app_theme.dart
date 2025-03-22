import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Builds the light and dark [ThemeData] from the shared design tokens.
///
/// The typeface depends on the active language: Arabic glyphs are rendered
/// with Cairo, everything else with Plus Jakarta Sans.
abstract final class AppTheme {
  static ThemeData light(Locale locale) => _build(Brightness.light, locale);
  static ThemeData dark(Locale locale) => _build(Brightness.dark, locale);

  static ThemeData _build(Brightness brightness, Locale locale) {
    final isDark = brightness == Brightness.dark;

    var scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
      secondary: AppColors.accent,
    );
    if (isDark) {
      scheme = scheme.copyWith(
        surface: AppColors.darkSurface,
        surfaceContainerLowest: AppColors.darkBackground,
      );
    }

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );

    final textTheme = _textTheme(
      base.textTheme,
      locale,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final outlineColor = isDark
        ? AppPalette.dark.cardBorder
        : AppPalette.light.cardBorder;

    return base.copyWith(
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      textTheme: textTheme,
      extensions: [isDark ? AppPalette.dark : AppPalette.light],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.none,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(color: outlineColor),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: outlineColor),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.smAll),
        labelStyle: textTheme.labelMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.smAll),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppPalette.dark.subtleSurface
            : AppPalette.light.subtleSurface,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        elevation: AppElevation.mid,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
      dividerTheme: DividerThemeData(color: outlineColor, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: AppRadii.smAll,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),
    );
  }

  /// Typography scale: headings are tighter and bolder than Material defaults.
  static TextTheme _textTheme(TextTheme base, Locale locale) {
    final themed = locale.languageCode == 'ar'
        ? GoogleFonts.cairoTextTheme(base)
        : GoogleFonts.plusJakartaSansTextTheme(base);

    TextStyle? heading(TextStyle? s, {double spacing = -0.5}) =>
        s?.copyWith(fontWeight: FontWeight.w800, letterSpacing: spacing);

    return themed.copyWith(
      displayLarge: heading(themed.displayLarge, spacing: -1.5),
      displayMedium: heading(themed.displayMedium, spacing: -1.2),
      displaySmall: heading(themed.displaySmall, spacing: -1),
      headlineLarge: heading(themed.headlineLarge),
      headlineMedium: heading(themed.headlineMedium),
      headlineSmall: heading(themed.headlineSmall, spacing: -0.2),
      titleLarge: themed.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: themed.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: themed.bodyLarge?.copyWith(height: 1.6),
      bodyMedium: themed.bodyMedium?.copyWith(height: 1.55),
    );
  }
}
