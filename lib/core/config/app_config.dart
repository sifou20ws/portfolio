// Nullable on purpose: set a link to `null` to hide its button.
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

/// Single place for everything personal about the portfolio owner.
///
/// Replace these placeholders with your real details. Text that should change
/// with the language (title, bio…) lives in the translation files under
/// `lib/core/i18n/` instead.
abstract final class AppConfig {
  static const String fullName = 'Seifeddine Rezrazi';

  /// Short initials used by the logo mark and the hero avatar.
  static const String initials = 'SR';

  /// Optional profile photo (asset path or https URL). When `null` the hero
  /// shows a gradient avatar with your [initials].
  static const String? avatar = null;

  // ---------------------------------------------------------------------------
  // Links — set any of them to `null` to hide the corresponding button.
  // ---------------------------------------------------------------------------
  static const String email = 'rezrazi.seif@gmail.com';
  static const String? githubUrl = 'https://github.com/sifou20ws';
  static const String? linkedInUrl =
      'https://www.linkedin.com/in/rezrazi-seif/';

  /// WhatsApp number in international format (with `+` and country code).
  static const String? whatsappNumber = '+213556909574';

  /// `wa.me` link that opens a chat in WhatsApp (app or web).
  static String? get whatsappUrl => whatsappNumber == null
      ? null
      : 'https://wa.me/${whatsappNumber!.replaceAll(RegExp(r'[^0-9]'), '')}';

  /// Hosted CV (Google Drive, GitHub raw, your own domain…). A remote URL
  /// works identically on mobile, desktop and web.
  static const String? cvUrl = 'https://example.com/cv.pdf';

  /// Hero statistics. Values are shown as-is; labels are translation keys.
  /// Update them to reflect your real track record.
  static const List<({String value, String labelKey})> stats = [
    (value: '5+', labelKey: 'hero_stat_years'),
    (value: '20+', labelKey: 'hero_stat_apps'),
    (value: '1M+', labelKey: 'hero_stat_users'),
  ];

  /// Local JSON file that holds all projects. See `assets/data/projects.json`.
  static const String projectsAsset = 'assets/data/projects.json';
}
