/// Route names. On the web these become the URL (`/projects/dropili`).
abstract final class Routes {
  static const home = '/';
  static const projectDetail = '/projects/:id';
  static const notFound = '/not-found';

  static String project(String id) => '/projects/$id';
}
