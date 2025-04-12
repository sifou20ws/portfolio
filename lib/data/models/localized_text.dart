import 'package:get/get.dart';

/// A piece of user-facing content that may be translated.
///
/// In JSON it can be written either as a plain string (same text in every
/// language) or as a map keyed by language code:
///
/// ```json
/// "summary": "Same text everywhere"
/// "summary": { "en": "Hello", "fr": "Bonjour", "ar": "مرحبا" }
/// ```
///
/// Missing languages fall back to English, then to the first available value.
class LocalizedText {
  const LocalizedText(this.values);

  final Map<String, String> values;

  factory LocalizedText.fromJson(Object? json) {
    if (json is String) return LocalizedText({'en': json});
    if (json is Map) {
      return LocalizedText(
        json.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    return const LocalizedText({});
  }

  /// Text for the current app language.
  String get text => resolve(Get.locale?.languageCode ?? 'en');

  String resolve(String languageCode) {
    return values[languageCode] ??
        values['en'] ??
        (values.isNotEmpty ? values.values.first : '');
  }

  bool get isEmpty => values.values.every((v) => v.trim().isEmpty);

  @override
  String toString() => text;
}
