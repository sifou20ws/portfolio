import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// A non-scrolling grid whose cells in the same row share the tallest cell's
/// height. Unlike `GridView`, it needs no fixed `childAspectRatio`, so cards
/// never overflow when text wraps or the user enlarges the font size.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.columns,
    required this.children,
    this.spacing = AppSpacing.lg,
    this.runSpacing = AppSpacing.lg,
  });

  final int columns;
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      for (var c = 0; c < columns; c++) {
        if (c > 0) rowChildren.add(SizedBox(width: spacing));
        final index = i + c;
        rowChildren.add(
          Expanded(
            child: index < children.length ? children[index] : const SizedBox(),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: runSpacing));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rowChildren,
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
