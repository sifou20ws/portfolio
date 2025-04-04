import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_tokens.dart';
import '../utils/context_ext.dart';

/// Gradient initials badge + optional name, used in headers and the footer.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.showName = true, this.onTap});

  final bool showName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.mdAll,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: context.palette.heroGradient,
                borderRadius: AppRadii.mdAll,
              ),
              child: Text(
                AppConfig.initials,
                // Initials are Latin, keep them LTR even in Arabic.
                textDirection: TextDirection.ltr,
                style: context.text.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (showName) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(AppConfig.fullName, style: context.text.titleMedium),
            ],
          ],
        ),
      ),
    );
  }
}
