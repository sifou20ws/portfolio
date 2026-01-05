import 'package:flutter/material.dart';

import '../../core/i18n/locale_keys.dart';

/// A group of related skills shown as one card in the Skills section.
class SkillCategory {
  const SkillCategory({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    required this.skills,
  });

  /// Translation keys (see `LocaleKeys`).
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;

  /// Technology names are proper nouns, so they are not translated.
  final List<String> skills;
}

/// Built from the technologies used across the projects in
/// `assets/data/projects.json`. Edit this list to match your own toolbox.
const List<SkillCategory> skillCategories = [
  SkillCategory(
    titleKey: LocaleKeys.skillCatCrossPlatform,
    descriptionKey: LocaleKeys.skillCatCrossPlatformDesc,
    icon: Icons.devices_rounded,
    color: Color(0xFF3D8BFD),
    skills: [
      'Flutter',
      'Dart',
      'Material 3',
      'Responsive UI',
      'Animations',
      'Flutter Web',
      'i18n & RTL',
    ],
  ),
  SkillCategory(
    titleKey: LocaleKeys.skillCatNative,
    descriptionKey: LocaleKeys.skillCatNativeDesc,
    icon: Icons.memory_rounded,
    color: Color(0xFFF76B1C),
    skills: ['Kotlin', 'Swift', 'NFC', 'QR code scanning', 'Google Maps'],
  ),
  SkillCategory(
    titleKey: LocaleKeys.skillCatState,
    descriptionKey: LocaleKeys.skillCatStateDesc,
    icon: Icons.account_tree_rounded,
    color: Color(0xFF8B5CF6),
    skills: ['GetX', 'BLoC', 'Clean Architecture', 'Feature-first modules'],
  ),
  SkillCategory(
    titleKey: LocaleKeys.skillCatBackend,
    descriptionKey: LocaleKeys.skillCatBackendDesc,
    icon: Icons.cloud_sync_rounded,
    color: Color(0xFF14B8A6),
    skills: [
      'REST APIs',
      'Dio',
      'Firebase',
      'Cloud Firestore',
      'Firebase Storage',
      'FCM push notifications',
      'Token-based auth',
    ],
  ),
  SkillCategory(
    titleKey: LocaleKeys.skillCatTesting,
    descriptionKey: LocaleKeys.skillCatTestingDesc,
    icon: Icons.verified_rounded,
    color: Color(0xFF22C55E),
    skills: ['Unit tests', 'Static analysis', 'Firebase Crashlytics'],
  ),
  SkillCategory(
    titleKey: LocaleKeys.skillCatCicd,
    descriptionKey: LocaleKeys.skillCatCicdDesc,
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFFEC4899),
    skills: [
      'Git',
      'GitHub Actions',
      'GitHub Pages',
      'Google Play Console',
      'App Store Connect',
    ],
  ),
];
