import 'package:get/get.dart';

import '../i18n/locale_keys.dart';

/// Localized `TextFormField` validators.
abstract final class Validators {
  static final _emailRegex = RegExp(
    r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[a-zA-Z]{2,}$',
  );

  static String? required(String? value) =>
      (value == null || value.trim().isEmpty)
      ? LocaleKeys.errRequired.tr
      : null;

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    return _emailRegex.hasMatch(value!.trim()) ? null : LocaleKeys.errEmail.tr;
  }

  static String? Function(String?) minLength(int min) => (value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    return value!.trim().length < min
        ? LocaleKeys.errMessageShort.trParams({'min': '$min'})
        : null;
  };
}
