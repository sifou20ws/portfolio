import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'core/services/settings_service.dart';

Future<void> main() async {
  // Clean URLs on the web (/projects/dropili instead of /#/projects/dropili).
  // No-op on other platforms.
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();

  // Local key-value storage for theme/language preferences.
  await GetStorage.init();

  // Settings must be ready before the first frame so the app starts with the
  // right theme and language (no flash of the wrong one).
  await Get.putAsync(() => SettingsService().init(), permanent: true);

  runApp(const PortfolioApp());
}
