import 'package:get/get.dart';

import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/projects/bindings/project_detail_binding.dart';
import '../../features/projects/views/project_detail_view.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static const initial = Routes.home;

  static final pages = <GetPage>[
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.projectDetail,
      page: () => const ProjectDetailView(),
      binding: ProjectDetailBinding(),
      transition: Transition.fadeIn,
    ),
  ];

  /// Any unknown URL falls back to the home page.
  static final unknown = GetPage(
    name: '/not-found',
    page: () => const HomeView(),
    binding: HomeBinding(),
  );
}
