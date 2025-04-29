import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/i18n/locale_keys.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/hover_lift.dart';
import '../../../core/widgets/project_image.dart';
import '../../../core/widgets/tech_chip.dart';
import '../../../data/models/project.dart';

/// Project summary card: thumbnail, title, summary, key tags, CTA.
/// On hover (web/desktop) it lifts, zooms the thumbnail and nudges the arrow.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});

  final Project project;
  final VoidCallback onTap;

  static const _maxTags = 4;

  @override
  Widget build(BuildContext context) {
    final accent = project.accentColor;

    return HoverLift(
      builder: (context, hovered) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(
            color: hovered
                ? accent.withValues(alpha: 0.6)
                : context.palette.cardBorder,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail (shared with the detail page via Hero).
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: project.heroTag,
                      child: ClipRect(
                        child: AnimatedScale(
                          scale: hovered ? 1.06 : 1,
                          duration: AppDurations.medium,
                          curve: Curves.easeOutCubic,
                          child: ProjectImage(
                            path: project.thumbnail,
                            accent: accent,
                            icon: project.icon,
                            label: project.title.text,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: AppSpacing.sm,
                      start: AppSpacing.sm,
                      child: _GlassLabel(project.category.text),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.title.text,
                        style: context.text.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (project.year != null)
                      Text(
                        '${project.year}',
                        style: context.text.labelMedium?.copyWith(
                          color: context.palette.mutedText,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Text(
                  project.summary.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final tag in project.tags.take(_maxTags))
                      TechChip(tag, color: accent, dense: true),
                    if (project.tags.length > _maxTags)
                      TechChip(
                        '+${project.tags.length - _maxTags}',
                        dense: true,
                      ),
                  ],
                ),
              ),
              // Pushes the CTA to the bottom so cards in a row line up.
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(foregroundColor: accent),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(LocaleKeys.viewDetails.tr),
                        AnimatedPadding(
                          duration: AppDurations.fast,
                          padding: EdgeInsetsDirectional.only(
                            start: hovered ? AppSpacing.sm : AppSpacing.xs,
                          ),
                          // arrow_forward mirrors automatically in RTL.
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassLabel extends StatelessWidget {
  const _GlassLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text,
        style: context.text.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
