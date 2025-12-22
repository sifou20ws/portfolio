import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../core/config/app_config.dart';
import '../core/i18n/app_translations.dart';
import '../core/services/settings_service.dart';
import '../core/theme/app_theme.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.to;

    // Rebuilds when the theme mode or language changes. The theme depends on
    // the locale too, because Arabic uses a different font family.
    return Obx(() {
      final locale = settings.locale.value;
      return GetMaterialApp(
        title: AppConfig.siteTitle,
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.light(locale),
        darkTheme: AppTheme.dark(locale),
        themeMode: settings.themeMode.value,

        // i18n — GlobalWidgetsLocalizations flips Directionality to RTL for
        // Arabic automatically; GetX `Translations` provides our own strings.
        translations: AppTranslations(),
        locale: locale,
        fallbackLocale: AppLocales.fallback.locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Routing & DI
        initialBinding: InitialBinding(),
        initialRoute: AppPages.initial,
        getPages: AppPages.pages,
        unknownRoute: AppPages.unknown,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 350),
      );
    });
  }
}
