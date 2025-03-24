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
}

/// Parses `#RRGGBB` / `#AARRGGBB` strings coming from JSON.
Color? colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(parsed);
}
