import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Lifts its child and adds a soft glow while hovered (mouse/trackpad only).
/// On touch devices it is a no-op, so it is safe to use everywhere.
class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.builder,
    this.lift = 6,
    this.borderRadius,
  });

  /// Receives the hover state so the child can react (e.g. zoom its image).
  final Widget Function(BuildContext context, bool hovered) builder;
  final double lift;
  final BorderRadius? borderRadius;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppPalette>()!.glow;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -widget.lift : 0, 0),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? AppRadii.lgAll,
          boxShadow: [
            BoxShadow(
              color: _hovered ? glow : Colors.transparent,
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: widget.builder(context, _hovered),
      ),
    );
  }
}
