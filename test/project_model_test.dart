import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/data/models/localized_text.dart';
import 'package:portfolio/data/models/project.dart';

void main() {
  test('bundled projects.json parses into valid projects', () {
    final json =
        jsonDecode(File('assets/data/projects.json').readAsStringSync())
            as Map<String, dynamic>;
    final projects = (json['projects'] as List)
        .cast<Map<String, dynamic>>()
        .map(Project.fromJson)
        .toList();

    expect(projects, isNotEmpty);
    expect(
      projects.map((p) => p.id).toSet().length,
      projects.length,
      reason: 'project ids must be unique',
    );
    for (final p in projects) {
      for (final lang in ['en', 'fr', 'ar']) {
        expect(
          p.summary.resolve(lang),
          isNotEmpty,
          reason: '${p.id} summary/$lang',
        );
      }
    }
  });

  group('LocalizedText', () {
    test('plain string is used for every language', () {
      final t = LocalizedText.fromJson('Hello');
      expect(t.resolve('fr'), 'Hello');
      expect(t.resolve('ar'), 'Hello');
    });

    test('falls back to English when a language is missing', () {
      final t = LocalizedText.fromJson({'en': 'Hello', 'fr': 'Bonjour'});
      expect(t.resolve('fr'), 'Bonjour');
      expect(t.resolve('ar'), 'Hello');
    });
  });

  test('missing links are null so their buttons are hidden', () {
    final links = ProjectLinks.fromJson({
      'github': 'https://x',
      'appStore': ' ',
    });
    expect(links.github, 'https://x');
    expect(links.appStore, isNull);
    expect(links.playStore, isNull);
    expect(links.isEmpty, isFalse);
  });
}
