import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_tokens.dart';

/// Fades + slides [child] in the first time it scrolls into the viewport.
///
/// Works with any ancestor [Scrollable] (no extra packages): it listens to the
/// scroll position and, after the next layout, checks whether its own render
/// box has entered the bottom 90 % of the screen. Once revealed it stops
/// listening.
///
/// Give it an [id] when a layout change can rebuild it in a new place (e.g. a
/// grid switching from 3 to 2 columns): an item already revealed then shows
/// up instantly instead of replaying its entrance.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 0.08,
    this.id,
  });

  final Widget child;
  final Duration delay;

  /// Stable identity used to remember that this item was already revealed.
  final Object? id;

  /// Ids revealed so far during this session.
  static final Set<Object> _shown = {};

  /// Vertical slide distance, as a fraction of the child's height.
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  ScrollPosition? _position;
  bool _visible = false;
  bool _checkScheduled = false;

  /// Already revealed in an earlier life: show immediately, no animation.
  late final bool _instant =
      widget.id != null && Reveal._shown.contains(widget.id);

  @override
  void initState() {
    super.initState();
    if (_instant) _visible = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_scheduleCheck);
      _position = position;
      _position?.addListener(_scheduleCheck);
    }
    _scheduleCheck();
  }

  /// Scroll notifications fire *before* the new frame is laid out, so reading
  /// the box position right away would be one frame stale (and miss the last
  /// scroll step). Measure after layout instead, at most once per frame.
  void _scheduleCheck() {
    if (_checkScheduled || _visible) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      _check();
    });
  }

  void _check() {
    if (_visible || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (top < screenHeight * 0.9) {
      setState(() => _visible = true);
      if (widget.id != null) Reveal._shown.add(widget.id!);
      _position?.removeListener(_scheduleCheck);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_scheduleCheck);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child
        .animate(target: _visible ? 1 : 0, value: _instant ? 1 : null)
        .fadeIn(
          duration: AppDurations.slow,
          delay: widget.delay,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: widget.offset,
          end: 0,
          duration: AppDurations.slow,
          delay: widget.delay,
          curve: Curves.easeOutCubic,
        );
  }
}
