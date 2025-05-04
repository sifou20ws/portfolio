import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/i18n/locale_keys.dart';
import '../../../core/utils/link_launcher.dart';

/// Contact form state + submission.
///
/// There is no backend: on submit the user's mail client opens with the
/// message pre-filled. To send directly instead, replace [submit]'s body with
/// a call to your API / Formspree / EmailJS / Firebase function.
class ContactController extends GetxController {
  static const minMessageLength = 10;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  final isSubmitting = false.obs;

  /// Validate on every keystroke only after the first submit attempt, so users
  /// are not shouted at while typing for the first time.
  final autovalidate = AutovalidateMode.disabled.obs;

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) {
      autovalidate.value = AutovalidateMode.onUserInteraction;
      return;
    }

    isSubmitting.value = true;
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final message = messageController.text.trim();

    final opened = await LinkLauncher.email(
      AppConfig.email,
      subject: 'Portfolio contact — $name',
      body: '$message\n\n— $name <$email>',
    );
    isSubmitting.value = false;

    if (opened) {
      formKey.currentState?.reset();
      nameController.clear();
      emailController.clear();
      messageController.clear();
      autovalidate.value = AutovalidateMode.disabled;
      AppSnackbar.show(
        LocaleKeys.contactSuccess.tr,
        title: LocaleKeys.contactSuccessTitle.tr,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
