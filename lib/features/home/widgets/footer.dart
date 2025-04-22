import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/i18n/locale_keys.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/logo_mark.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = context.text.bodySmall?.copyWith(
      color: context.palette.mutedText,
    );
    final rights = Text(
      LocaleKeys.footerRights.trParams({
        'year': '${DateTime.now().year}',
        'name': AppConfig.fullName,
      }),
      style: muted,
    );
    final builtWith = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const FlutterLogo(size: 14),
        const SizedBox(width: AppSpacing.xs),
        Text(LocaleKeys.footerBuiltWith.tr, style: muted),
      ],
    );

    return Column(
      children: [
        const Divider(),
        MaxWidthContainer(
          padding: EdgeInsets.symmetric(
            horizontal: context.pageGutter,
            vertical: AppSpacing.lg,
          ),
          child: context.isMobile
              ? Column(
                  children: [
                    const LogoMark(showName: false),
                    const SizedBox(height: AppSpacing.sm),
                    rights,
                    const SizedBox(height: AppSpacing.xxs),
                    builtWith,
                  ],
                )
              : Row(
                  children: [
                    const LogoMark(showName: false),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: rights),
                    builtWith,
                  ],
                ),
        ),
      ],
    );
  }
}
