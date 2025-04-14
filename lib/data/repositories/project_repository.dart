import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/config/app_config.dart';
import '../models/project.dart';

/// Abstraction over where projects come from. Swap [AssetProjectRepository]
/// for an HTTP / Firestore implementation without touching the UI.
abstract interface class ProjectRepository {
  Future<List<Project>> getAll();
  Future<Project?> getById(String id);
}

/// Reads projects from the bundled JSON file and caches them in memory.
class AssetProjectRepository implements ProjectRepository {
  AssetProjectRepository({this.assetPath = AppConfig.projectsAsset});

  final String assetPath;
  Future<List<Project>>? _cache;

  @override
  Future<List<Project>> getAll() => _cache ??= _load();

  @override
  Future<Project?> getById(String id) async {
    final projects = await getAll();
    for (final p in projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<List<Project>> _load() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return (decoded['projects'] as List)
          .cast<Map<String, dynamic>>()
          .map(Project.fromJson)
          .toList(growable: false);
    } catch (_) {
      _cache = null; // allow a retry after a failure
      rethrow;
    }
  }
}
