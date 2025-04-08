import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/app_tokens.dart';
import '../utils/context_ext.dart';
import 'reveal.dart';

/// Eyebrow + title + subtitle block used at the top of every home section.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: context.palette.heroGradient.createShader,
            child: Text(
              eyebrow.toUpperCase(),
              style: context.text.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: context.isRtl ? 0 : 2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: context.responsive(
              context.text.headlineMedium,
              desktop: context.text.displaySmall,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                subtitle!,
                style: context.text.bodyLarge?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
