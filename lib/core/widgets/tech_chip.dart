import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../utils/context_ext.dart';

/// Small rounded label for a technology / tag.
class TechChip extends StatelessWidget {
  const TechChip(this.label, {super.key, this.color, this.dense = false});

  final String label;

  /// Optional accent (e.g. the project's colour). Defaults to primary.
  final Color? color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colors.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
        vertical: dense ? 3 : AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: context.isDark ? 0.16 : 0.09),
        borderRadius: AppRadii.smAll,
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: (dense ? context.text.labelSmall : context.text.labelMedium)
            ?.copyWith(
              color: context.readable(
                context.isDark
                    ? Color.lerp(accent, Colors.white, 0.45)!
                    : Color.lerp(accent, Colors.black, 0.25)!,
              ),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
