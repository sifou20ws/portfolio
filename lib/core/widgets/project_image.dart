import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Displays a project image from a network URL or a bundled asset, and falls
/// back to a branded gradient placeholder when the path is empty or fails to
/// load. This lets the dummy data render nicely before real images exist.
class ProjectImage extends StatelessWidget {
  const ProjectImage({
    super.key,
    required this.path,
    required this.accent,
    this.icon = Icons.phone_iphone_rounded,
    this.label,
    this.fit = BoxFit.cover,
    this.variant = PlaceholderVariant.banner,
  });

  final String? path;
  final Color accent;
  final IconData icon;
  final String? label;
  final BoxFit fit;
  final PlaceholderVariant variant;

  @override
  Widget build(BuildContext context) {
    final src = path?.trim() ?? '';
    Widget fallback(BuildContext c, Object? _, StackTrace? __) => _Placeholder(
      accent: accent,
      icon: icon,
      label: label,
      variant: variant,
    );

    if (src.isEmpty) return fallback(context, null, null);
    if (src.startsWith('http')) {
      return Image.network(src, fit: fit, errorBuilder: fallback);
    }
    return Image.asset(src, fit: fit, errorBuilder: fallback);
  }
}

enum PlaceholderVariant { banner, screenshot }

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.accent,
    required this.icon,
    required this.variant,
    this.label,
  });

  final Color accent;
  final IconData icon;
  final String? label;
  final PlaceholderVariant variant;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(accent);
    final secondary = hsl
        .withHue((hsl.hue + 40) % 360)
        .withLightness((hsl.lightness * 0.8).clamp(0.0, 1.0))
        .toColor();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [accent, secondary],
        ),
      ),
      child: switch (variant) {
        PlaceholderVariant.banner => _BannerArt(icon: icon, label: label),
        PlaceholderVariant.screenshot => const _FakeAppScreen(),
      },
    );
  }
}

/// Big icon with decorative circles — used for card thumbnails & hero banners.
class _BannerArt extends StatelessWidget {
  const _BannerArt({required this.icon, this.label});

  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.biggest.shortestSide;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            PositionedDirectional(
              top: -size * 0.3,
              end: -size * 0.2,
              child: _circle(size * 0.9, 0.12),
            ),
            PositionedDirectional(
              bottom: -size * 0.4,
              start: -size * 0.15,
              child: _circle(size * 0.8, 0.08),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: size * 0.32, color: Colors.white),
                  if (label != null) ...[
                    SizedBox(height: size * 0.04),
                    Text(
                      label!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (size * 0.09).clamp(12, 34),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _circle(double d, double alpha) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );
}

/// Skeleton of an app screen — stands in for missing screenshots.
class _FakeAppScreen extends StatelessWidget {
  const _FakeAppScreen();

  @override
  Widget build(BuildContext context) {
    Widget bar(double widthFactor, {double height = 10, double alpha = 0.35}) =>
        FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: widthFactor,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: alpha),
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          bar(0.5, height: 14, alpha: 0.7),
          const SizedBox(height: AppSpacing.xs),
          bar(0.3),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppRadii.mdAll,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < 3; i++) ...[
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: AppRadii.smAll,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: bar(0.9 - i * 0.15)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const Spacer(),
          bar(1, height: 36, alpha: 0.5),
        ],
      ),
    );
  }
}
