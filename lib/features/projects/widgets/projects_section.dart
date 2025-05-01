import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/i18n/locale_keys.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/responsive_grid.dart';
import '../../../core/widgets/reveal.dart';
import '../../../core/widgets/section_header.dart';
import '../controllers/projects_controller.dart';
import 'project_card.dart';

/// Featured projects grid (1 / 2 / 3 columns) with loading & error states.
class ProjectsSection extends GetView<ProjectsController> {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              eyebrow: LocaleKeys.projectsEyebrow.tr,
              title: LocaleKeys.projectsTitle.tr,
              subtitle: LocaleKeys.projectsSubtitle.tr,
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(() {
              switch (controller.status.value) {
                case LoadStatus.loading:
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                case LoadStatus.error:
                  return _Message(
                    icon: Icons.cloud_off_rounded,
                    text: LocaleKeys.projectsError.tr,
                    action: OutlinedButton(
                      onPressed: controller.load,
                      child: Text(LocaleKeys.retry.tr),
                    ),
                  );
                case LoadStatus.success:
                  final projects = controller.projects;
                  if (projects.isEmpty) {
                    return _Message(
                      icon: Icons.inbox_rounded,
                      text: LocaleKeys.projectsEmpty.tr,
                    );
                  }
                  final columns = context.responsive(1, tablet: 2, desktop: 3);
                  return ResponsiveGrid(
                    columns: columns,
                    children: [
                      for (var i = 0; i < projects.length; i++)
                        Reveal(
                          delay: (i % columns * 100).ms,
                          child: ProjectCard(
                            project: projects[i],
                            onTap: () => controller.openDetails(projects[i]),
                          ),
                        ),
                    ],
                  );
              }
            }),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(icon, size: 48, color: context.palette.mutedText),
            const SizedBox(height: AppSpacing.sm),
            Text(text, style: context.text.bodyLarge),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
