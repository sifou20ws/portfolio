import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/i18n/app_translations.dart';

void main() {
  test('every language defines exactly the same keys as English', () {
    final keys = AppTranslations().keys;
    final english = keys['en']!.keys.toSet();

    for (final entry in keys.entries) {
      final lang = entry.value.keys.toSet();
      expect(
        english.difference(lang),
        isEmpty,
        reason: '${entry.key} is missing keys',
      );
      expect(
        lang.difference(english),
        isEmpty,
        reason: '${entry.key} has keys that English lacks',
      );
    }
  });
}
