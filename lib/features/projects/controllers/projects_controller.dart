import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/project.dart';
import '../../../data/repositories/project_repository.dart';

enum LoadStatus { loading, success, error }

/// Loads the featured projects for the home page.
class ProjectsController extends GetxController {
  ProjectsController(this._repository);

  final ProjectRepository _repository;

  final status = LoadStatus.loading.obs;
  final projects = <Project>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status.value = LoadStatus.loading;
    try {
      final all = await _repository.getAll();
      projects.assignAll(all.where((p) => p.featured));
      status.value = LoadStatus.success;
    } catch (e, st) {
      Get.log('Failed to load projects: $e\n$st', isError: true);
      status.value = LoadStatus.error;
    }
  }

  void openDetails(Project project) =>
      Get.toNamed(Routes.project(project.id), arguments: project);
}
