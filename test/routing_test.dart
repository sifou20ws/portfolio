import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/routes/app_routes.dart';
import 'package:portfolio/app/routes/unknown_route_redirect.dart';

void main() {
  final middleware = ExactHomeMiddleware();

  test('the real home URL is left alone', () {
    expect(middleware.redirect('/'), isNull);
    expect(middleware.redirect(''), isNull);
    expect(middleware.redirect(null), isNull);
    expect(middleware.redirect('/?utm_source=linkedin'), isNull);
  });

  test('any other path is sent to the not-found redirect', () {
    for (final url in ['/some/random/page', '/projects/', '/projects', '/x']) {
      expect(middleware.redirect(url)?.name, Routes.notFound, reason: url);
    }
  });

  test('project URLs are built from the id', () {
    expect(Routes.project('dropili'), '/projects/dropili');
  });
}
