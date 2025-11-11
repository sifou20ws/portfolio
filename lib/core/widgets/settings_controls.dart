import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../i18n/app_translations.dart';
import '../i18n/locale_keys.dart';
import '../services/settings_service.dart';
import '../theme/app_tokens.dart';
import '../utils/context_ext.dart';

/// Sun/moon button that switches between light and dark with a rotation.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return IconButton(
      tooltip: LocaleKeys.toggleTheme.tr,
      onPressed: () =>
          SettingsService.to.toggleTheme(context.themeData.brightness),
      icon: AnimatedSwitcher(
        duration: AppDurations.medium,
        transitionBuilder: (child, anim) => RotationTransition(
          turns: Tween(begin: 0.6, end: 1.0).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
        ),
      ),
    );
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
