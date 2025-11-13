import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/i18n/locale_keys.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/link_launcher.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/hover_lift.dart';
import '../../../core/widgets/reveal.dart';
import '../../../core/widgets/section_header.dart';
import '../controllers/contact_controller.dart';

/// Contact info + social links on one side, validated form on the other
/// (side-by-side on desktop, stacked on smaller screens).
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: LocaleKeys.contactEyebrow.tr,
          title: LocaleKeys.contactTitle.tr,
          subtitle: LocaleKeys.contactSubtitle.tr,
        ),
        const SizedBox(height: AppSpacing.xl),
        Reveal(
          delay: const Duration(milliseconds: 100),
          child: Text(
            LocaleKeys.contactFindMe.tr,
            style: context.text.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Reveal(delay: Duration(milliseconds: 150), child: _SocialLinks()),
      ],
    );

    return Container(
      color: context.palette.subtleSurface.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: MaxWidthContainer(
        child: context.isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: info),
                  const SizedBox(width: AppSpacing.xxl),
                  const Expanded(
                    child: Reveal(
                      delay: Duration(milliseconds: 150),
                      child: _ContactForm(),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  info,
                  const SizedBox(height: AppSpacing.xl),
                  const Reveal(child: _ContactForm()),
                ],
              ),
      ),
    );
  }
}

class _SocialLinks extends StatelessWidget {
  const _SocialLinks();

  @override
  Widget build(BuildContext context) {
    final links =
        <({FaIconData icon, String label, String value, VoidCallback onTap})>[
          (
            icon: FontAwesomeIcons.envelope,
            label: 'Email',
            value: AppConfig.email,
            onTap: () => LinkLauncher.email(AppConfig.email),
          ),
          if (AppConfig.whatsappNumber != null)
            (
              icon: FontAwesomeIcons.whatsapp,
              label: 'WhatsApp',
              value: AppConfig.whatsappNumber!,
              onTap: () => LinkLauncher.open(AppConfig.whatsappUrl!),
            ),
          if (AppConfig.githubUrl != null)
            (
              icon: FontAwesomeIcons.github,
              label: 'GitHub',
              value: _pretty(AppConfig.githubUrl!),
              onTap: () => LinkLauncher.open(AppConfig.githubUrl!),
            ),
          if (AppConfig.linkedInUrl != null)
            (
              icon: FontAwesomeIcons.linkedinIn,
              label: 'LinkedIn',
              value: _pretty(AppConfig.linkedInUrl!),
              onTap: () => LinkLauncher.open(AppConfig.linkedInUrl!),
            ),
        ];

    return Column(
      children: [
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: HoverLift(
              lift: 3,
              borderRadius: AppRadii.mdAll,
              builder: (context, hovered) => Material(
                color: context.colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.mdAll,
                  side: BorderSide(
                    color: hovered
                        ? context.colors.primary
                        : context.palette.cardBorder,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: link.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer,
                            borderRadius: AppRadii.smAll,
                          ),
                          child: FaIcon(
                            link.icon,
                            size: 18,
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(link.label, style: context.text.labelLarge),
                              Text(
                                link.value,
                                // URLs/emails stay LTR inside Arabic text.
                                textDirection: TextDirection.ltr,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall?.copyWith(
                                  color: context.palette.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedSlide(
                          duration: AppDurations.fast,
                          offset:
                              Offset(hovered ? 0.2 : 0, 0) *
                              (context.isRtl ? -1 : 1),
                          child: Icon(
                            Icons.arrow_outward_rounded,
                            size: 18,
                            color: context.palette.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  static String _pretty(String url) =>
      url.replaceFirst(RegExp(r'^https?://(www\.)?'), '');
}

class _ContactForm extends GetView<ContactController> {
  const _ContactForm();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        context.responsive(AppSpacing.lg, desktop: AppSpacing.xl),
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: context.palette.cardBorder),
        boxShadow: [
          BoxShadow(
            color: context.palette.glow.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Obx(
        () => Form(
          key: controller.formKey,
          autovalidateMode: controller.autovalidate.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: controller.nameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: LocaleKeys.formName.tr,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: Validators.required,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: LocaleKeys.formEmail.tr,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: controller.messageController,
                minLines: 5,
                maxLines: 8,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: LocaleKeys.formMessage.tr,
                  alignLabelWithHint: true,
                ),
                validator: Validators.minLength(
                  ContactController.minMessageLength,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.submit,
                icon: controller.isSubmitting.value
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(LocaleKeys.formSend.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
