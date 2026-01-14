import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/i18n/locale_keys.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/hover_lift.dart';
import '../../../core/widgets/responsive_grid.dart';
import '../../../core/widgets/reveal.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/tech_chip.dart';
import '../../../data/static/skills_data.dart';

/// Skills grid: one card per category (1 / 2 / 3 columns).
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.palette.subtleSurface.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              eyebrow: LocaleKeys.skillsEyebrow.tr,
              title: LocaleKeys.skillsTitle.tr,
              subtitle: LocaleKeys.skillsSubtitle.tr,
            ),
            const SizedBox(height: AppSpacing.xl),
            ResponsiveGrid(
              columns: context.responsive(1, tablet: 2, desktop: 3),
              children: [
                for (var i = 0; i < skillCategories.length; i++)
                  Reveal(
                    id: 'skill-${skillCategories[i].titleKey}',
                    delay: (i % 3 * 90).ms,
                    child: _SkillCategoryCard(category: skillCategories[i]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillCategoryCard extends StatelessWidget {
  const _SkillCategoryCard({required this.category});

  final SkillCategory category;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return HoverLift(
      builder: (context, hovered) => AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(
            color: hovered
                ? color.withValues(alpha: 0.5)
                : context.palette.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: hovered ? 1 : 0.14),
                    borderRadius: AppRadii.mdAll,
                  ),
                  child: Icon(
                    category.icon,
                    color: hovered ? Colors.white : color,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    category.titleKey.tr,
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              category.descriptionKey.tr,
              style: context.text.bodyMedium?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final skill in category.skills)
                  TechChip(skill, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
