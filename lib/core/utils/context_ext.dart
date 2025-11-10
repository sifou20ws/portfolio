import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Short-hands for the most common theme lookups.
///
/// Names deliberately differ from GetX's own `context.theme` /
/// `context.isDarkMode` extensions to avoid ambiguous-member errors.
extension ThemeContext on BuildContext {
  ThemeData get themeData => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// [accent] adjusted to stay legible as a text/icon colour on the current
  /// surface: darkened in light mode, lightened in dark mode, until it reaches
  /// a 4.5:1 contrast ratio (WCAG AA). Light brand colours such as yellow
  /// would otherwise be unreadable on white.
  Color readable(Color accent) {
    final surface = colors.surface;
    final darken = !isDark;
    var hsl = HSLColor.fromColor(accent);
    var color = accent;
    while (_contrast(color, surface) < 4.5) {
      final l = hsl.lightness + (darken ? -0.03 : 0.03);
      if (l <= 0 || l >= 1) break;
      hsl = hsl.withLightness(l);
      color = hsl.toColor();
    }
    return color;
  }
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Black or white, whichever reads better on a [background] fill.
Color onColor(Color background) =>
    background.computeLuminance() > 0.45 ? Colors.black87 : Colors.white;

/// Parses `#RRGGBB` / `#AARRGGBB` strings coming from JSON.
Color? colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(parsed);
}
