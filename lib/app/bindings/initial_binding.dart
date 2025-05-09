import 'package:get/get.dart';

import '../../data/repositories/project_repository.dart';

/// App-wide dependencies available to every route.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // `fenix` recreates the repository if it was disposed and requested again.
    Get.lazyPut<ProjectRepository>(() => AssetProjectRepository(), fenix: true);
  }
}
