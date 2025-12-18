import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/i18n/locale_keys.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/link_launcher.dart';
import '../../../core/widgets/interactive_background.dart';
import '../../../core/widgets/project_image.dart';
import '../controllers/home_controller.dart';

/// Landing hero: name, title, bio, call-to-action buttons and stats, with an
/// animated avatar on the side (desktop) or on top (mobile).
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = context.screenWidth >= Breakpoints.topNav;

    return Stack(
      children: [
        const Positioned.fill(child: _BackgroundGlow()),
        MaxWidthContainer(
          child: ConstrainedBox(
            // Fill most of the first screen on large displays.
            constraints: BoxConstraints(
              minHeight: wide ? size.height * 0.82 : 0,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: context.responsive(
                  AppSpacing.xl,
                  desktop: AppSpacing.xxl,
                ),
              ),
              child: wide
                  ? const Row(
                      children: [
                        Expanded(flex: 6, child: _HeroText()),
                        SizedBox(width: AppSpacing.xxl),
                        Expanded(flex: 4, child: _HeroVisual(size: 380)),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: _HeroVisual(size: 240)),
                        SizedBox(height: AppSpacing.xl),
                        _HeroText(),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final muted = context.palette.mutedText;

    final children = <Widget>[
      const _AvailabilityPill(),
      const SizedBox(height: AppSpacing.lg),
      Text(
        LocaleKeys.heroGreeting.tr,
        style: context.text.titleLarge?.copyWith(color: muted),
      ),
      const SizedBox(height: AppSpacing.xxs),
      Text(
        AppConfig.fullName,
        style: context.responsive(
          context.text.displaySmall,
          tablet: context.text.displayMedium,
          desktop: context.text.displayLarge,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${LocaleKeys.heroTitle.tr} · '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: context.palette.heroGradient.createShader,
                child: Text(
                  LocaleKeys.heroSubtitle.tr,
                  style: context.text.headlineSmall,
                ),
              ),
            ),
          ],
        ),
        style: context.text.headlineSmall?.copyWith(color: muted),
      ),
      const SizedBox(height: AppSpacing.lg),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Text(LocaleKeys.heroBio.tr, style: context.text.bodyLarge),
      ),
      const SizedBox(height: AppSpacing.xl),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          FilledButton.icon(
            onPressed: () => home.scrollTo(HomeSection.projects),
            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
            label: Text(LocaleKeys.btnViewProjects.tr),
          ),
          OutlinedButton.icon(
            onPressed: () => home.scrollTo(HomeSection.contact),
            icon: const Icon(Icons.mail_outline_rounded, size: 18),
            label: Text(LocaleKeys.btnContactMe.tr),
          ),
          if (AppConfig.cvUrl != null)
            TextButton.icon(
              onPressed: () => LinkLauncher.open(AppConfig.cvUrl!),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(LocaleKeys.btnDownloadCv.tr),
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.xl),
      const _Stats(),
    ];

    // Staggered entrance: each line fades & slides in 70 ms after the last.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .animate(interval: 70.ms)
          .fadeIn(duration: AppDurations.slow, curve: Curves.easeOut)
          .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill();

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs - 2,
      ),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: green.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.7, end: 1.2, duration: 900.ms)
              .fade(begin: 0.5, end: 1),
          const SizedBox(width: AppSpacing.xs),
          Text(
            LocaleKeys.heroAvailable.tr,
            style: context.text.labelMedium?.copyWith(
              color: context.isDark
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFF15803D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.md,
      children: [
        for (final stat in AppConfig.stats)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: context.palette.heroGradient.createShader,
                child: Text(
                  stat.value,
                  textDirection: TextDirection.ltr,
                  style: context.text.headlineMedium,
                ),
              ),
              Text(
                stat.labelKey.tr,
                style: context.text.bodySmall?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Gradient avatar with a slowly rotating ring and floating tech badges.
class _HeroVisual extends StatelessWidget {
  const _HeroVisual({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final avatar = size * 0.72;
    const badges = ['Flutter', 'Dart', 'Kotlin', 'Swift'];
    // Badge anchors around the avatar (directional, so they mirror in RTL).
    final anchors =
        <({double? top, double? bottom, double? start, double? end})>[
          (top: size * 0.06, bottom: null, start: 0, end: null),
          (top: size * 0.18, bottom: null, start: null, end: 0),
          (top: null, bottom: size * 0.18, start: -size * 0.04, end: null),
          (top: null, bottom: size * 0.04, start: null, end: size * 0.06),
        ];

    return SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Rotating gradient ring.
              Container(
                    width: avatar + 24,
                    height: avatar + 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          context.colors.primary,
                          AppColors.accent,
                          context.colors.primary.withValues(alpha: 0.1),
                          context.colors.primary,
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .rotate(duration: const Duration(seconds: 12)),
              // Avatar.
              Container(
                width: avatar,
                height: avatar,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.themeData.scaffoldBackgroundColor,
                    width: 6,
                  ),
                  boxShadow: [
                    BoxShadow(color: context.palette.glow, blurRadius: 60),
                  ],
                ),
                child: AppConfig.avatar != null
                    ? ProjectImage(
                        path: AppConfig.avatar,
                        accent: AppColors.seed,
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: context.palette.heroGradient,
                        ),
                        child: Center(
                          child: Text(
                            AppConfig.initials,
                            textDirection: TextDirection.ltr,
                            style: context.text.displayLarge?.copyWith(
                              color: Colors.white,
                              fontSize: avatar * 0.32,
                            ),
                          ),
                        ),
                      ),
              ),
              // Floating badges, each bobbing with a different phase.
              for (var i = 0; i < badges.length; i++)
                PositionedDirectional(
                  top: anchors[i].top,
                  bottom: anchors[i].bottom,
                  start: anchors[i].start,
                  end: anchors[i].end,
                  child: _FloatingBadge(label: badges[i])
                      .animate(delay: (400 + i * 150).ms)
                      .fadeIn(duration: AppDurations.slow)
                      .scaleXY(begin: 0.6, end: 1, curve: Curves.easeOutBack)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: 0,
                        end: i.isEven ? -10 : 10,
                        duration: (2200 + i * 300).ms,
                        curve: Curves.easeInOut,
                      ),
                ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: AppDurations.slow)
        .scaleXY(begin: 0.9, end: 1, curve: Curves.easeOutCubic);
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      elevation: AppElevation.high,
      shadowColor: context.palette.glow,
      borderRadius: AppRadii.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 16, color: context.colors.primary),
            const SizedBox(width: AppSpacing.xxs),
            Text(label, style: context.text.labelLarge),
          ],
        ),
      ),
    );
  }
}

/// Two blurred colour blobs behind the hero. They drift in opposite
/// directions as the mouse moves (parallax), via [InteractiveBackground].
class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    Widget blob(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0)],
        ),
      ),
    );

    final pointer =
        InteractiveBackground.of(context)?.normalized ?? Offset.zero;

    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          PositionedDirectional(
            top: -120,
            end: -80,
            child: Transform.translate(
              offset: pointer * 40,
              child: blob(context.colors.primary, 520),
            ),
          ),
          PositionedDirectional(
            bottom: -160,
            start: -120,
            child: Transform.translate(
              offset: pointer * -30,
              child: blob(AppColors.accent, 460),
            ),
          ),
        ],
      ),
    );
  }
}
