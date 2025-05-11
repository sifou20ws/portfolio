import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'core/services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local key-value storage for theme/language preferences.
  await GetStorage.init();

  // Settings must be ready before the first frame so the app starts with the
  // right theme and language (no flash of the wrong one).
  await Get.putAsync(() => SettingsService().init(), permanent: true);

  runApp(const PortfolioApp());
}
