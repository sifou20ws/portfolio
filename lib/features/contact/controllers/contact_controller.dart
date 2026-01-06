import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/i18n/locale_keys.dart';
import '../../../core/utils/link_launcher.dart';
import '../../../data/repositories/formspree_client.dart';

/// Contact form state + submission.
///
/// With [AppConfig.formspreeId] set, messages are delivered straight to the
/// owner's inbox through Formspree. Without it, the visitor's email app opens
/// with the message pre-filled; the form is kept as-is in that case because
/// we can't know whether the email was actually sent.
class ContactController extends GetxController {
  static const minNameLength = 2;
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

    try {
      final formId = AppConfig.formspreeId;
      if (formId != null) {
        await _sendDirectly(formId, name: name, email: email, message: message);
      } else {
        await _openEmailApp(name: name, email: email, message: message);
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _sendDirectly(
    String formId, {
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      await FormspreeClient(
        formId,
      ).send(name: name, email: email, message: message);
    } on FormspreeException catch (e) {
      Get.log(e.toString(), isError: true);
      // Keep what the visitor typed so nothing is lost.
      AppSnackbar.show(
        LocaleKeys.contactSendFailed.trParams({'email': AppConfig.email}),
        isError: true,
      );
      return;
    }
    _resetForm();
    AppSnackbar.show(
      LocaleKeys.contactSent.tr,
      title: LocaleKeys.contactSentTitle.tr,
    );
  }

  Future<void> _openEmailApp({
    required String name,
    required String email,
    required String message,
  }) async {
    final opened = await LinkLauncher.email(
      AppConfig.email,
      subject: 'Portfolio contact — $name',
      body: '$message\n\n— $name <$email>',
    );
    // On the web this reports success even without a mail app, so the form
    // is not cleared and the message tells the visitor how to reach out.
    if (opened) {
      AppSnackbar.show(
        LocaleKeys.contactSuccess.trParams({'email': AppConfig.email}),
        title: LocaleKeys.contactSuccessTitle.tr,
      );
    }
  }

  void _resetForm() {
    formKey.currentState?.reset();
    nameController.clear();
    emailController.clear();
    messageController.clear();
    autovalidate.value = AutovalidateMode.disabled;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
