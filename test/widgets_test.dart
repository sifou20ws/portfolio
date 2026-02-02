import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/responsive_grid.dart';
import 'package:portfolio/core/widgets/reveal.dart';

Widget _app(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('ResponsiveGrid gives cells in a row the same height', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 600,
          child: ResponsiveGrid(
            columns: 2,
            children: [
              Container(key: const Key('short'), height: 50),
              Container(key: const Key('tall'), height: 200),
              Container(key: const Key('alone'), height: 80),
            ],
          ),
        ),
      ),
    );

    final short = tester.getSize(find.byKey(const Key('short')));
    final tall = tester.getSize(find.byKey(const Key('tall')));
    expect(short.height, tall.height);
    expect(short.width, tall.width);
    // The last row keeps an empty slot so the card isn't stretched full-width.
    expect(tester.getSize(find.byKey(const Key('alone'))).width, short.width);
  });

  testWidgets('Reveal with an id does not replay after being rebuilt', (
    tester,
  ) async {
    Opacity? opacityOf(String text) => tester
        .widgetList<Opacity>(
          find.ancestor(of: find.text(text), matching: find.byType(Opacity)),
        )
        .firstOrNull;
    FadeTransition? fadeOf(String text) => tester
        .widgetList<FadeTransition>(
          find.ancestor(
            of: find.text(text),
            matching: find.byType(FadeTransition),
          ),
        )
        .firstOrNull;
    double visibility(String text) =>
        opacityOf(text)?.opacity ?? fadeOf(text)?.opacity.value ?? 1;

    await tester.pumpWidget(
      _app(const Reveal(id: 'card-a', child: Text('card'))),
    );
    await tester.pumpAndSettle();
    expect(visibility('card'), 1, reason: 'revealed on first appearance');

    // Rebuild it under a different parent, as a grid column change does.
    await tester.pumpWidget(
      _app(
        const Column(
          children: [Reveal(id: 'card-a', child: Text('card'))],
        ),
      ),
    );
    await tester.pump(); // a single frame: no time for a fade-in
    expect(visibility('card'), 1, reason: 'shown instantly, no replay');

    // Let flutter_animate's internal timers finish before the test ends.
    await tester.pumpAndSettle();
  });
}
