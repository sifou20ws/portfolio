import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'ar.dart';
import 'en.dart';
import 'fr.dart';

/// Registers the UI string tables with GetX. Lookup is done by language code,
/// so `Locale('fr')` and `Locale('fr', 'CA')` both resolve to [fr].
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en': en, 'fr': fr, 'ar': ar};
}

/// Metadata for the language picker.
class AppLanguage {
  const AppLanguage(this.locale, this.nativeName, this.shortLabel);

  final Locale locale;
  final String nativeName;
  final String shortLabel;

  bool get isRtl => locale.languageCode == 'ar';
}

abstract final class AppLocales {
  static const english = AppLanguage(Locale('en'), 'English', 'EN');
  static const french = AppLanguage(Locale('fr'), 'Français', 'FR');
  static const arabic = AppLanguage(Locale('ar'), 'العربية', 'ع');

  static const all = [english, french, arabic];
  static const fallback = english;

  static List<Locale> get supported => all.map((l) => l.locale).toList();

  static AppLanguage of(Locale locale) => all.firstWhere(
    (l) => l.locale.languageCode == locale.languageCode,
    orElse: () => fallback,
  );
}
