import 'package:get/get.dart';

import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/projects/bindings/project_detail_binding.dart';
import '../../features/projects/views/project_detail_view.dart';
import 'app_routes.dart';
import 'unknown_route_redirect.dart';

abstract final class AppPages {
  static const initial = Routes.home;

  static final pages = <GetPage>[
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [ExactHomeMiddleware()],
    ),
    GetPage(
      name: Routes.projectDetail,
      page: () => const ProjectDetailView(),
      binding: ProjectDetailBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: Routes.notFound, page: () => const UnknownRouteRedirect()),
  ];

  /// Any unknown URL redirects to the home page (see [UnknownRouteRedirect]).
  static final unknown = GetPage(
    name: Routes.notFound,
    page: () => const UnknownRouteRedirect(),
  );
}
