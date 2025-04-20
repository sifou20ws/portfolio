import 'package:get/get.dart';

import '../../contact/controllers/contact_controller.dart';
import '../../projects/controllers/projects_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ProjectsController(Get.find()));
    Get.lazyPut(() => ContactController());
  }
}
