import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../i18n/app_translations.dart';
import '../i18n/locale_keys.dart';
import '../services/settings_service.dart';
import '../theme/app_tokens.dart';
import '../utils/context_ext.dart';

/// Theme picker: Light / Dark / System. The icon shows the current mode
/// (sun, moon, or "auto" when following the operating system).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  static const _options = [
    (ThemeMode.light, Icons.light_mode_rounded, LocaleKeys.themeLight),
    (ThemeMode.dark, Icons.dark_mode_rounded, LocaleKeys.themeDark),
    (ThemeMode.system, Icons.brightness_auto_rounded, LocaleKeys.themeSystem),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.to;
    return Obx(() {
      final current = settings.themeMode.value;
      final icon = _options.firstWhere((o) => o.$1 == current).$2;
      return PopupMenuButton<ThemeMode>(
        tooltip: LocaleKeys.toggleTheme.tr,
        initialValue: current,
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        onSelected: settings.setThemeMode,
        itemBuilder: (_) => [
          for (final (mode, optionIcon, labelKey) in _options)
            PopupMenuItem(
              value: mode,
              child: Row(
                children: [
                  Icon(optionIcon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(labelKey.tr),
                  const Spacer(),
                  if (mode == current)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: context.colors.primary,
                    ),
                ],
              ),
            ),
        ],
        icon: AnimatedSwitcher(
          duration: AppDurations.medium,
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween(begin: 0.6, end: 1.0).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(icon, key: ValueKey(current)),
        ),
      );
    });
  }
}

/// Language picker. Shows the short label (EN / FR / ع) and a menu of native
/// language names.
class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.to;
    return Obx(() {
      final current = settings.language;
      return PopupMenuButton<AppLanguage>(
        tooltip: LocaleKeys.language.tr,
        initialValue: current,
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        onSelected: (lang) => settings.setLocale(lang.locale),
        itemBuilder: (_) => [
          for (final lang in AppLocales.all)
            PopupMenuItem(
              value: lang,
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      lang.shortLabel,
                      style: context.text.labelLarge?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  Text(lang.nativeName),
                  const Spacer(),
                  if (lang == current)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: context.colors.primary,
                    ),
                ],
              ),
            ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.translate_rounded, size: 20),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                current.shortLabel,
                // Follow the surrounding icon colour so it matches the icon.
                style: context.text.labelLarge?.copyWith(
                  color: IconTheme.of(context).color,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
