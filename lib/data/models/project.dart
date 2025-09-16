import 'package:flutter/material.dart';

import '../../core/utils/context_ext.dart';
import 'localized_text.dart';

/// A portfolio project, deserialized from `assets/data/projects.json`.
///
/// JSON schema (all [LocalizedText] fields accept a string or an
/// `{ "en": …, "fr": …, "ar": … }` map):
///
/// | key            | type                  | notes                                   |
/// |----------------|-----------------------|-----------------------------------------|
/// | id             | string (required)     | URL slug: `/projects/<id>`              |
/// | title          | LocalizedText         |                                         |
/// | category       | LocalizedText         | e.g. "E-commerce"                       |
/// | summary        | LocalizedText         | 1–2 sentences, shown on the card        |
/// | role           | LocalizedText         | your role on the project                |
/// | year           | int                   |                                         |
/// | platforms      | string[]              | android, ios, web, macos, windows, linux|
/// | featured       | bool                  | shown on the home page when true        |
/// | accentColor    | "#RRGGBB"             | tints placeholder art and chips         |
/// | icon           | string                | key of [Project.iconMap] (placeholder)  |
/// | thumbnail      | string?               | card image, 16:10 (asset or https URL)  |
/// | banner         | string?               | wide detail header; falls back to thumbnail |
/// | screenshots    | string[]              | portrait phone shots (assets or URLs)   |
/// | screenshotsFramed | bool               | true if shots already include a device frame |
/// | tags           | string[]              | 3–5 key technologies for the card       |
/// | problem        | LocalizedText         | detail page write-up                    |
/// | architecture   | LocalizedText         | detail page write-up                    |
/// | features       | LocalizedText[]       | bullet list                             |
/// | stack          | {frameworks, libraries, tools}: string[] |                      |
/// | links          | {playStore, appStore, webDemo, github}: string? | null = hidden |
class Project {
  const Project({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.role,
    required this.year,
    required this.platforms,
    required this.featured,
    required this.accentColor,
    required this.icon,
    required this.thumbnail,
    required this.banner,
    required this.screenshots,
    this.screenshotsFramed = false,
    required this.tags,
    required this.problem,
    required this.architecture,
    required this.features,
    required this.stack,
    required this.links,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText category;
  final LocalizedText summary;
  final LocalizedText role;
  final int? year;
  final List<String> platforms;
  final bool featured;
  final Color accentColor;
  final IconData icon;
  final String? thumbnail;
  final String? banner;
  final List<String> screenshots;

  /// `true` when screenshots are finished device mockups (phone frame already
  /// drawn, transparent background). The gallery then shows them whole instead
  /// of cropping them into its own phone frame.
  final bool screenshotsFramed;

  /// Image for the detail page header: the landscape [banner] if provided,
  /// otherwise the card [thumbnail].
  String? get headerImage => banner ?? thumbnail;
  final List<String> tags;
  final LocalizedText problem;
  final LocalizedText architecture;
  final List<LocalizedText> features;
  final TechStack stack;
  final ProjectLinks links;

  /// Hero animation tag shared by the card thumbnail and the detail banner.
  String get heroTag => 'project-banner-$id';

  /// Icons available for placeholder art, referenced by name in JSON.
  static const Map<String, IconData> iconMap = {
    'shopping': Icons.shopping_bag_rounded,
    'fitness': Icons.fitness_center_rounded,
    'finance': Icons.account_balance_wallet_rounded,
    'chat': Icons.forum_rounded,
    'food': Icons.restaurant_rounded,
    'travel': Icons.flight_takeoff_rounded,
    'health': Icons.favorite_rounded,
    'education': Icons.school_rounded,
    'music': Icons.headphones_rounded,
    'dashboard': Icons.dashboard_rounded,
    'gift': Icons.card_giftcard_rounded,
  };

  factory Project.fromJson(Map<String, dynamic> json) {
    List<String> strings(Object? v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? const [];
    String? path(String key) {
      final v = (json[key] as String?)?.trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    return Project(
      id: json['id'] as String,
      title: LocalizedText.fromJson(json['title']),
      category: LocalizedText.fromJson(json['category']),
      summary: LocalizedText.fromJson(json['summary']),
      role: LocalizedText.fromJson(json['role']),
      year: json['year'] as int?,
      platforms: strings(json['platforms']),
      featured: json['featured'] as bool? ?? true,
      accentColor:
          colorFromHex(json['accentColor'] as String?) ??
          const Color(0xFF5B5BF7),
      icon: iconMap[json['icon']] ?? Icons.phone_iphone_rounded,
      thumbnail: path('thumbnail'),
      banner: path('banner'),
      screenshots: strings(json['screenshots']),
      screenshotsFramed: json['screenshotsFramed'] as bool? ?? false,
      tags: strings(json['tags']),
      problem: LocalizedText.fromJson(json['problem']),
      architecture: LocalizedText.fromJson(json['architecture']),
      features: ((json['features'] as List?) ?? const [])
          .map(LocalizedText.fromJson)
          .toList(),
      stack: TechStack.fromJson(json['stack'] as Map<String, dynamic>? ?? {}),
      links: ProjectLinks.fromJson(
        json['links'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class TechStack {
  const TechStack({
    this.frameworks = const [],
    this.libraries = const [],
    this.tools = const [],
  });

  final List<String> frameworks;
  final List<String> libraries;
  final List<String> tools;

  bool get isEmpty => frameworks.isEmpty && libraries.isEmpty && tools.isEmpty;

  factory TechStack.fromJson(Map<String, dynamic> json) {
    List<String> list(String key) =>
        (json[key] as List?)?.map((e) => e.toString()).toList() ?? const [];
    return TechStack(
      frameworks: list('frameworks'),
      libraries: list('libraries'),
      tools: list('tools'),
    );
  }
}

/// External links. Any `null`/empty value is simply not rendered.
class ProjectLinks {
  const ProjectLinks({
    this.playStore,
    this.appStore,
    this.webDemo,
    this.github,
  });

  final String? playStore;
  final String? appStore;
  final String? webDemo;
  final String? github;

  bool get isEmpty => [
    playStore,
    appStore,
    webDemo,
    github,
  ].every((l) => l == null || l.isEmpty);

  factory ProjectLinks.fromJson(Map<String, dynamic> json) {
    String? read(String key) {
      final v = json[key] as String?;
      return (v == null || v.trim().isEmpty) ? null : v.trim();
    }

    return ProjectLinks(
      playStore: read('playStore'),
      appStore: read('appStore'),
      webDemo: read('webDemo'),
      github: read('github'),
    );
  }
}
