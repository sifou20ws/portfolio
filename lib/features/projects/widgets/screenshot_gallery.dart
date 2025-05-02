import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/i18n/locale_keys.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/widgets/project_image.dart';
import '../../../data/models/project.dart';

/// Phone-shaped screenshot carousel: swipe / drag / arrow buttons / dots,
/// side items are scaled down, and tapping opens a zoomable full-screen viewer.
///
/// When the project has no screenshots yet, four skeleton placeholders are
/// shown so the layout can be previewed with dummy data.
class ScreenshotGallery extends StatefulWidget {
  const ScreenshotGallery({super.key, required this.project});

  final Project project;

  static const _placeholderCount = 4;

  @override
  State<ScreenshotGallery> createState() => _ScreenshotGalleryState();
}

class _ScreenshotGalleryState extends State<ScreenshotGallery> {
  PageController? _controller;
  int _index = 0;

  List<String?> get _items => widget.project.screenshots.isEmpty
      ? List.filled(ScreenshotGallery._placeholderCount, null)
      : widget.project.screenshots;

  /// Recreates the controller when the viewport fraction changes (resize),
  /// preserving the current page.
  PageController _controllerFor(double fraction) {
    final current = _controller;
    if (current != null && current.viewportFraction == fraction) return current;
    final next = PageController(
      viewportFraction: fraction,
      initialPage: _index,
    );
    if (current != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => current.dispose());
    }
    return _controller = next;
  }

  void _go(int delta) {
    final target = (_index + delta).clamp(0, _items.length - 1);
    _controller?.animateToPage(
      target,
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = context.responsive<double>(440, tablet: 500, desktop: 560);
    final itemWidth = height * 9 / 19.5 + AppSpacing.lg;
    final items = _items;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final fraction = math
                .min(0.9, itemWidth / constraints.maxWidth)
                .clamp(0.2, 1.0);
            final controller = _controllerFor(fraction);

            return SizedBox(
              height: height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Allow mouse-drag on web/desktop for this carousel only.
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
                    child: PageView.builder(
                      controller: controller,
                      itemCount: items.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) => _ScaledPage(
                        controller: controller,
                        index: i,
                        child: _PhoneFrame(
                          onTap: () => _openViewer(context, i),
                          child: _shot(items[i], i),
                        ),
                      ),
                    ),
                  ),
                  if (!context.isMobile && items.length > 1) ...[
                    PositionedDirectional(
                      start: 0,
                      child: _ArrowButton(
                        icon: Icons.chevron_left_rounded,
                        tooltip: LocaleKeys.galleryPrevious.tr,
                        onPressed: _index > 0 ? () => _go(-1) : null,
                      ),
                    ),
                    PositionedDirectional(
                      end: 0,
                      child: _ArrowButton(
                        icon: Icons.chevron_right_rounded,
                        tooltip: LocaleKeys.galleryNext.tr,
                        onPressed: _index < items.length - 1
                            ? () => _go(1)
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _Dots(
          count: items.length,
          index: _index,
          color: widget.project.accentColor,
          onTap: (i) => _go(i - _index),
        ),
      ],
    );
  }

  Widget _shot(String? path, int i) => ProjectImage(
    path: path,
    accent: widget.project.accentColor,
    variant: PlaceholderVariant.screenshot,
  );

  void _openViewer(BuildContext context, int initial) {
    Get.dialog(
      _FullscreenViewer(
        count: _items.length,
        initialIndex: initial,
        builder: (i) => _shot(_items[i], i),
      ),
      barrierColor: Colors.black87,
      useSafeArea: false,
    );
  }
}

/// Scales & fades pages based on their distance from the centre.
class _ScaledPage extends StatelessWidget {
  const _ScaledPage({
    required this.controller,
    required this.index,
    required this.child,
  });

  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        var page = index.toDouble();
        if (controller.hasClients && controller.position.haveDimensions) {
          page = controller.page ?? page;
        } else {
          page = controller.initialPage.toDouble();
        }
        final distance = (index - page).abs().clamp(0.0, 1.0);
        return Opacity(
          opacity: 1 - distance * 0.4,
          child: Transform.scale(scale: 1 - distance * 0.12, child: child),
        );
      },
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 19.5,
        child: MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(
                  color: context.isDark ? Colors.white24 : Colors.black12,
                  width: 6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.palette.glow,
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: onPressed == null ? 0.3 : 1,
      duration: AppDurations.fast,
      child: IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: 28,
        // chevron_left/right mirror automatically in RTL.
        icon: Icon(icon),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.index,
    required this.color,
    required this.onTap,
  });

  final int count;
  final int index;
  final Color color;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: AppDurations.medium,
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index ? color : context.colors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}

/// Full-screen, pinch-to-zoom viewer. Arrow keys navigate, Esc closes.
class _FullscreenViewer extends StatefulWidget {
  const _FullscreenViewer({
    required this.count,
    required this.initialIndex,
    required this.builder,
  });

  final int count;
  final int initialIndex;
  final Widget Function(int index) builder;

  @override
  State<_FullscreenViewer> createState() => _FullscreenViewerState();
}

class _FullscreenViewerState extends State<_FullscreenViewer> {
  late final _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  void _go(int delta) {
    final target = (_index + delta).clamp(0, widget.count - 1);
    _controller.animateToPage(
      target,
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // In RTL the PageView is mirrored, so the physical arrow keys flip too.
    final rtl = context.isRtl;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _go(rtl ? 1 : -1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _go(rtl ? -1 : 1),
        const SingleActivator(LogicalKeyboardKey.escape): Get.back,
      },
      child: Focus(
        autofocus: true,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.count,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => InteractiveViewer(
                    maxScale: 4,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: AspectRatio(
                          aspectRatio: 9 / 19.5,
                          child: ClipRRect(
                            borderRadius: AppRadii.xlAll,
                            child: widget.builder(i),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: AppSpacing.md,
                end: AppSpacing.md,
                child: SafeArea(
                  child: IconButton.filledTonal(
                    tooltip: LocaleKeys.close.tr,
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
              Positioned(
                bottom: AppSpacing.lg,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Text(
                    '${_index + 1} / ${widget.count}',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: context.text.labelLarge?.copyWith(
                      color: Colors.white,
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
