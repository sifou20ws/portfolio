import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../data/models/project.dart';
import '../../../data/repositories/project_repository.dart';
import 'projects_controller.dart';

/// Resolves the project for `/projects/:id`.
///
/// When navigating from a card the [Project] arrives via `Get.arguments`
/// (instant, keeps the Hero animation smooth). When the URL is opened
/// directly — e.g. a shared web link — it is looked up by id instead.
class ProjectDetailController extends GetxController {
  ProjectDetailController(this._repository);

  final ProjectRepository _repository;

  final project = Rxn<Project>();
  final status = LoadStatus.loading.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Project) {
      project.value = args;
      status.value = LoadStatus.success;
    } else {
      _loadById(Get.parameters['id']);
    }
  }

  Future<void> _loadById(String? id) async {
    if (id == null) {
      status.value = LoadStatus.error;
      return;
    }
    try {
      project.value = await _repository.getById(id);
      status.value = project.value == null
          ? LoadStatus.error
          : LoadStatus.success;
    } catch (_) {
      status.value = LoadStatus.error;
    }
  }

  @override
  void onClose() {
    // Leaving the project page: restore the site title.
    SystemChrome.setApplicationSwitcherDescription(
      const ApplicationSwitcherDescription(label: AppConfig.siteTitle),
    );
    super.onClose();
  }

  /// Pops back to the list, or replaces the stack with home if this page was
  /// the entry point (deep link) and there is nothing to pop.
  void back(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      Get.offAllNamed(Routes.home);
    }
  }
}
