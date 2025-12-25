import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

/// Sends any address that isn't exactly `/` to [Routes.notFound].
///
/// GetX matches every prefix of a path, so `/` matches *all* URLs:
/// `/some/random/page` would silently render a second home page. Attach this
/// to the home route so only the real `/` renders it.
class ExactHomeMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final path = Uri.tryParse(route ?? '/')?.path ?? '/';
    return (path.isEmpty || path == Routes.home)
        ? null
        : const RouteSettings(name: Routes.notFound);
  }
}

/// Shown for any unknown URL; immediately sends the visitor home.
///
/// Rather than rendering a *second* home page (which would share the existing
/// `HomeController`, its scroll controller and section keys), it returns to
/// the home page already in the stack, or replaces itself with a fresh one
/// when there is none (e.g. a mistyped link opened directly). Either way the
/// address bar ends up on `/`.
class UnknownRouteRedirect extends StatefulWidget {
  const UnknownRouteRedirect({super.key});

  @override
  State<UnknownRouteRedirect> createState() => _UnknownRouteRedirectState();
}

class _UnknownRouteRedirectState extends State<UnknownRouteRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  void _redirect() {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final self = ModalRoute.of(context);

    // Go back to the home page already in the stack (in-app URL change).
    if (navigator.canPop()) {
      navigator.popUntil(
        (route) => route.settings.name == Routes.home || route.isFirst,
      );
    }

    // Still here? Nothing to go back to (a bad link opened directly), so
    // replace this page with a fresh home page.
    if (self?.isActive ?? false) Get.offNamed(Routes.home);

    // The engine keeps showing the URL the visitor typed; replace it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigator.routeInformationUpdated(
        uri: Uri.parse(Routes.home),
        replace: true,
      );
    });
  }

  // Plain background for the single frame before the redirect.
  @override
  Widget build(BuildContext context) => const Scaffold();
}
