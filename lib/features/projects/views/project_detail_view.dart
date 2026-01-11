import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/i18n/locale_keys.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/project_image.dart';
import '../../../core/widgets/reveal.dart';
import '../../../core/widgets/settings_controls.dart';
import '../../../core/widgets/tech_chip.dart';
import '../../../data/models/project.dart';
import '../controllers/project_detail_controller.dart';
import '../controllers/projects_controller.dart';
import '../widgets/project_links.dart';
import '../widgets/screenshot_gallery.dart';

/// Dedicated project page (`/projects/:id`).
///
/// Layout: collapsing banner → header (title, summary, meta, links) →
/// screenshot carousel → write-up + tech stack (two columns on desktop,
/// stacked on mobile).
class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final project = controller.project.value;
        switch (controller.status.value) {
          case LoadStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case LoadStatus.error:
            return _NotFound(onBack: () => controller.back(context));
          case LoadStatus.success:
            // Browser tab title for this project (a Title deeper in the tree
            // wins over the app-level one on every rebuild).
            return Title(
              title: AppConfig.projectTitle(project!.title.text),
              color: context.colors.primary,
              child: _DetailBody(project: project),
            );
        }
      }),
    );
  }
}

class _DetailBody extends GetView<ProjectDetailController> {
  const _DetailBody({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final wide = context.isDesktop;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: context.responsive(240, tablet: 320, desktop: 380),
          backgroundColor: context.themeData.scaffoldBackgroundColor,
          leading: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: IconButton.filledTonal(
              tooltip: LocaleKeys.detailBack.tr,
              onPressed: () => controller.back(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          actions: const [
            _HeaderActions(),
            SizedBox(width: AppSpacing.xs),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: project.heroTag,
                  child: ProjectImage(
                    path: project.headerImage,
                    accent: project.accentColor,
                    icon: project.icon,
                    label: project.title.text,
                  ),
                ),
                // Fade into the page background for a seamless transition.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.55, 1],
                      colors: [
                        Colors.transparent,
                        context.themeData.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidthContainer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(project: project),
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionTitle(
                    LocaleKeys.detailGallery.tr,
                    Icons.photo_library_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Reveal(child: ScreenshotGallery(project: project)),
                  const SizedBox(height: AppSpacing.xxl),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _WriteUp(project: project)),
                        const SizedBox(width: AppSpacing.xxl),
                        Expanded(
                          flex: 2,
                          child: _TechStackPanel(project: project),
                        ),
                      ],
                    )
                  else ...[
                    _WriteUp(project: project),
                    const SizedBox(height: AppSpacing.xl),
                    _TechStackPanel(project: project),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Language + theme buttons in a filled pill, styled like the back button so
/// they stay legible over any banner (a bright yellow one included).
class _HeaderActions extends StatelessWidget {
  const _HeaderActions();

  @override
  Widget build(BuildContext context) {
    final background = context.colors.secondaryContainer;
    final foreground = context.colors.onSecondaryContainer;
    return Material(
      color: background,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconTheme(
        data: IconThemeData(color: foreground),
        child: IconButtonTheme(
          data: IconButtonThemeData(
            style: IconButton.styleFrom(foregroundColor: foreground),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foreground),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [LanguageMenuButton(), ThemeToggleButton()],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final meta = <({IconData icon, String label, String value})>[
      if (!project.role.isEmpty)
        (
          icon: Icons.person_outline_rounded,
          label: LocaleKeys.detailRole.tr,
          value: project.role.text,
        ),
      if (project.year != null)
        (
          icon: Icons.event_outlined,
          label: LocaleKeys.detailYear.tr,
          value: '${project.year}',
        ),
      if (project.platforms.isNotEmpty)
        (
          icon: Icons.devices_other_rounded,
          label: LocaleKeys.detailPlatforms.tr,
          value: project.platforms.map(_platformName).join(' · '),
        ),
    ];

    final children = <Widget>[
      TechChip(project.category.text, color: project.accentColor),
      const SizedBox(height: AppSpacing.sm),
      Text(
        project.title.text,
        style: context.responsive(
          context.text.displaySmall,
          desktop: context.text.displayMedium,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Text(
          project.summary.text,
          style: context.text.titleMedium?.copyWith(
            color: context.palette.mutedText,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.md,
        children: [
          for (final m in meta)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  m.icon,
                  size: 20,
                  color: context.readable(project.accentColor),
                ),
                const SizedBox(width: AppSpacing.xs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.label,
                      style: context.text.labelSmall?.copyWith(
                        color: context.palette.mutedText,
                      ),
                    ),
                    Text(m.value, style: context.text.labelLarge),
                  ],
                ),
              ],
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      ProjectLinksBar(links: project.links, accent: project.accentColor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .animate(interval: 60.ms)
          .fadeIn(duration: AppDurations.slow)
          .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
    );
  }

  static String _platformName(String key) => switch (key.toLowerCase()) {
    'android' => 'Android',
    'ios' => 'iOS',
    'web' => 'Web',
    'macos' => 'macOS',
    'windows' => 'Windows',
    'linux' => 'Linux',
    _ => key,
  };
}

/// Problem → architecture → key features.
class _WriteUp extends StatelessWidget {
  const _WriteUp({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final body = context.text.bodyLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!project.problem.isEmpty) ...[
          _SectionTitle(
            LocaleKeys.detailProblem.tr,
            Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.sm),
          Reveal(
            id: '${project.id}-problem',
            child: Text(project.problem.text, style: body),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (!project.architecture.isEmpty) ...[
          _SectionTitle(
            LocaleKeys.detailArchitecture.tr,
            Icons.account_tree_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          Reveal(
            id: '${project.id}-architecture',
            child: Text(project.architecture.text, style: body),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (project.features.isNotEmpty) ...[
          _SectionTitle(
            LocaleKeys.detailFeatures.tr,
            Icons.star_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < project.features.length; i++)
            Reveal(
              id: '${project.id}-feature-$i',
              delay: (i * 60).ms,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: context.readable(project.accentColor),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(project.features[i].text, style: body),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Frameworks / libraries / tools, grouped in a card.
class _TechStackPanel extends StatelessWidget {
  const _TechStackPanel({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final stack = project.stack;
    final groups = [
      (LocaleKeys.stackFrameworks.tr, stack.frameworks),
      (LocaleKeys.stackLibraries.tr, stack.libraries),
      (LocaleKeys.stackTools.tr, stack.tools),
    ].where((g) => g.$2.isNotEmpty);

    return Reveal(
      id: '${project.id}-stack',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: context.palette.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(LocaleKeys.detailTechStack.tr, Icons.layers_outlined),
            for (final (title, items) in groups) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: context.text.labelLarge?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final item in items)
                    TechChip(item, color: project.accentColor),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: context.colors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(title, style: context.text.titleLarge),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: context.palette.mutedText,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              LocaleKeys.detailNotFound.tr,
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.home_rounded),
              label: Text(LocaleKeys.detailBackHome.tr),
            ),
          ],
        ),
      ),
    );
  }
}
