import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../utils/context_ext.dart';

/// A viewport-fixed background that reacts to the mouse:
/// * a soft spotlight in the primary colour follows the cursor (eased),
/// * a faint dot grid lights up and grows around the cursor,
/// * the grid drifts at 30 % of the scroll speed for a sense of depth.
///
/// Descendants can read the eased pointer with [InteractiveBackground.of] to
/// add their own parallax. Only the painter repaints on mouse move — the
/// content is never rebuilt. On touch devices (no hover) and when the OS asks
/// for reduced motion, it renders a static dot grid.
class InteractiveBackground extends StatefulWidget {
  const InteractiveBackground({
    super.key,
    required this.child,
    this.scrollController,
  });

  final Widget child;

  /// Optional: makes the dot grid drift with scrolling.
  final ScrollController? scrollController;

  /// Eased pointer state of the nearest [InteractiveBackground], or `null`.
  static PointerGlow? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PointerScope>()?.notifier;

  @override
  State<InteractiveBackground> createState() => _InteractiveBackgroundState();
}

/// Eased pointer position (viewport pixels) plus a 0‥1 [presence] that fades
/// in while the mouse is over the page. Notifies once per animation frame.
class PointerGlow extends ChangeNotifier {
  Offset position = Offset.zero;
  double presence = 0;
  Size size = Size.zero;

  /// Pointer relative to the viewport centre, each axis in -1‥1, scaled by
  /// [presence] so parallax relaxes back to rest when the mouse leaves.
  Offset get normalized {
    if (size.isEmpty) return Offset.zero;
    final dx = (position.dx / size.width) * 2 - 1;
    final dy = (position.dy / size.height) * 2 - 1;
    return Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0)) * presence;
  }

  void _notify() => notifyListeners();
}

class _InteractiveBackgroundState extends State<InteractiveBackground>
    with SingleTickerProviderStateMixin {
  final _glow = PointerGlow();
  late final Ticker _ticker = createTicker(_tick);

  Offset? _target;
  bool _inside = false;

  void _tick(Duration _) {
    // Ease position towards the cursor and presence towards in/out.
    const follow = 0.14, fade = 0.08;
    final target = _target ?? _glow.position;
    _glow.position = Offset.lerp(_glow.position, target, follow)!;
    _glow.presence += ((_inside ? 1.0 : 0.0) - _glow.presence) * fade;

    final settled =
        (target - _glow.position).distance < 0.5 &&
        (_glow.presence - (_inside ? 1 : 0)).abs() < 0.01;
    if (settled) {
      _glow.position = target;
      _glow.presence = _inside ? 1 : 0;
      _ticker.stop();
    }
    _glow._notify();
  }

  void _onHover(PointerEvent e) {
    if (!_inside) {
      // Start the eased position at the entry point instead of sliding in
      // from wherever it last was.
      if (_glow.presence < 0.05) _glow.position = e.localPosition;
      _inside = true;
    }
    _target = e.localPosition;
    if (!_ticker.isActive) _ticker.start();
  }

  void _onExit(PointerEvent _) {
    _inside = false;
    if (!_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final painter = _BackgroundPainter(
      glow: _glow,
      scroll: widget.scrollController,
      dot: context.isDark
          ? Colors.white.withValues(alpha: 0.07)
          : Colors.black.withValues(alpha: 0.07),
      accent: context.colors.primary,
      spotlightAlpha: context.isDark ? 0.22 : 0.14,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        _glow.size = constraints.biggest;
        return MouseRegion(
          opaque: false,
          onHover: reduceMotion ? null : _onHover,
          onExit: reduceMotion ? null : _onExit,
          child: _PointerScope(
            notifier: _glow,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: CustomPaint(painter: painter),
                    ),
                  ),
                ),
                widget.child,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PointerScope extends InheritedNotifier<PointerGlow> {
  const _PointerScope({required super.notifier, required super.child});
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({
    required this.glow,
    required this.scroll,
    required this.dot,
    required this.accent,
    required this.spotlightAlpha,
  }) : super(repaint: Listenable.merge([glow, ?scroll]));

  final PointerGlow glow;
  final ScrollController? scroll;
  final Color dot;
  final Color accent;
  final double spotlightAlpha;

  static const _spacing = 28.0;
  static const _radius = 190.0; // dot highlight radius around the cursor

  @override
  void paint(Canvas canvas, Size size) {
    final presence = glow.presence;
    final pointer = glow.position;

    // 1. Spotlight.
    if (presence > 0.01) {
      final r = math.max(size.shortestSide * 0.55, 380.0);
      canvas.drawCircle(
        pointer,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              accent.withValues(alpha: spotlightAlpha * presence),
              accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: pointer, radius: r)),
      );
    }

    // 2. Dot grid, drifting with scroll (parallax) — one batched draw call.
    final offset = (scroll?.hasClients ?? false) ? scroll!.offset * 0.3 : 0.0;
    final shiftY = -(offset % _spacing);
    final points = <Offset>[];
    for (var y = shiftY; y < size.height + _spacing; y += _spacing) {
      for (var x = _spacing / 2; x < size.width; x += _spacing) {
        points.add(Offset(x, y));
      }
    }
    canvas.drawPoints(
      PointMode.points,
      points,
      Paint()
        ..color = dot
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // 3. Dots near the cursor light up and grow.
    if (presence > 0.01) {
      final highlight = Paint();
      for (final p in points) {
        final d = (p - pointer).distance;
        if (d > _radius) continue;
        final t = (1 - d / _radius) * presence; // 0 at the edge → 1 at centre
        highlight.color = accent.withValues(alpha: 0.9 * t);
        canvas.drawCircle(p, 1.2 + 2.4 * t, highlight);
      }
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.dot != dot ||
      old.accent != accent ||
      old.spotlightAlpha != spotlightAlpha ||
      old.scroll != scroll;
}
