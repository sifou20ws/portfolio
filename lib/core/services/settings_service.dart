import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../i18n/app_translations.dart';

/// App-wide, persisted user preferences: theme mode and language.
///
/// Registered once at startup as a permanent [GetxService]; the root
/// `GetMaterialApp` rebuilds reactively whenever either value changes.
class SettingsService extends GetxService {
  static SettingsService get to => Get.find();

  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  final _box = GetStorage();

  final themeMode = ThemeMode.system.obs;
  final locale = AppLocales.fallback.locale.obs;

  AppLanguage get language => AppLocales.of(locale.value);

  Future<SettingsService> init() async {
    themeMode.value = ThemeMode.values.firstWhere(
      (m) => m.name == _box.read<String>(_themeKey),
      orElse: () => ThemeMode.system,
    );

    // Saved choice → device language (if supported) → English.
    final saved = _box.read<String>(_localeKey);
    final device = Get.deviceLocale;
    locale.value = saved != null
        ? Locale(saved)
        : AppLocales.of(device ?? AppLocales.fallback.locale).locale;
    return this;
  }

  /// Flips between light and dark based on what is *currently visible*, so the
  /// first tap always does something even when following the system theme.
  void toggleTheme(Brightness current) {
    setThemeMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _box.write(_themeKey, mode.name);
  }

  Future<void> setLocale(Locale value) async {
    if (value == locale.value) return;
    locale.value = value;
    await Get.updateLocale(value);
    await _box.write(_localeKey, value.languageCode);
  }
}
