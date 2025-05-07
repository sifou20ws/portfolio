/// Route names. On the web these become the URL (`/#/projects/shopsphere`).
abstract final class Routes {
  static const home = '/';
  static const projectDetail = '/projects/:id';

  static String project(String id) => '/projects/$id';
}
