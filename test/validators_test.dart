import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:portfolio/core/i18n/app_translations.dart';
import 'package:portfolio/core/utils/validators.dart';

void main() {
  setUpAll(() {
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en');
  });

  group('required', () {
    test('rejects empty and whitespace-only input', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
    });
    test('accepts text', () => expect(Validators.required('Ada'), isNull));
  });

  group('email', () {
    for (final ok in ['a@b.co', 'first.last+tag@mail.example.com']) {
      test('accepts $ok', () => expect(Validators.email(ok), isNull));
    }
    for (final bad in [
      '',
      'not-an-email',
      'a@b',
      'a@b.',
      '@b.co',
      'a b@c.co',
    ]) {
      test('rejects "$bad"', () => expect(Validators.email(bad), isNotNull));
    }
    test('ignores surrounding spaces', () {
      expect(Validators.email('  a@b.co  '), isNull);
    });
  });

  group('minLength', () {
    final min2 = Validators.minLength(2);
    test('rejects too-short input, counting trimmed length', () {
      expect(min2('a'), isNotNull);
      expect(min2(' a '), isNotNull);
    });
    test('accepts input at the minimum', () => expect(min2('ab'), isNull));
    test('message includes the minimum', () {
      expect(Validators.minLength(10)('short'), contains('10'));
    });
  });
}
