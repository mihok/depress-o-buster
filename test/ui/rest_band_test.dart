import 'package:depress_o_buster/core/theme.dart';
import 'package:depress_o_buster/domain/ladder/ladder_rests.dart';
import 'package:depress_o_buster/ui/widgets/rest_band.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('heightFor', () {
    test('grows with the rest on a log scale', () {
      expect(RestBand.heightFor(const Duration(seconds: 30)), 18, reason: 'the floor: one line of small text');
      expect(RestBand.heightFor(const Duration(minutes: 10)), closeTo(38, 1));
      expect(RestBand.heightFor(const Duration(minutes: 20)), closeTo(48, 1));
      expect(RestBand.heightFor(const Duration(minutes: 50)), closeTo(64, 1));
      expect(RestBand.heightFor(const Duration(hours: 2, minutes: 10)), closeTo(83, 1));
    });

    test('is kept between 18 and 104 whatever the rest', () {
      expect(RestBand.heightFor(Duration.zero), RestBand.minHeight);
      expect(RestBand.heightFor(const Duration(seconds: -5)), RestBand.minHeight);
      expect(RestBand.heightFor(LadderRests.maxRest), RestBand.maxHeight, reason: 'six and a half hours fills the band');
      expect(RestBand.heightFor(const Duration(hours: 24)), RestBand.maxHeight);
    });

    test('never falls as the ladder climbs', () {
      for (final unit in [LadderRests.minUnit, const Duration(minutes: 10), LadderRests.maxUnit]) {
        final heights = [for (var p = 0; p < 9; p++) RestBand.heightFor(LadderRests.restFor(unit: unit, position: p))];
        for (var p = 1; p < heights.length; p++) {
          expect(heights[p], greaterThanOrEqualTo(heights[p - 1]), reason: 'unit $unit, step ${p + 1}');
        }
      }
      // With the usual unit every place up the climb is visibly taller than the last.
      final climb = [for (var p = 1; p < 7; p++) RestBand.heightFor(LadderRests.restFor(unit: const Duration(minutes: 10), position: p))];
      for (var i = 1; i < climb.length; i++) {
        expect(climb[i], greaterThan(climb[i - 1] + 4));
      }
    });
  });

  testWidgets('a longer rest is a taller band, and both still say the number', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Column(
            children: [
              RestBand(rest: Duration(minutes: 10), units: 1),
              RestBand(rest: Duration(minutes: 50), units: 5, before: false),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final bands = find.byType(RestBand);
    final short = tester.getSize(bands.first).height;
    final long = tester.getSize(bands.last).height;
    expect(long, greaterThan(short));
    expect(short, RestBand.heightFor(const Duration(minutes: 10)));
    expect(long, RestBand.heightFor(const Duration(minutes: 50)));
    expect(find.text('Rest 10 min'), findsOneWidget);
    expect(find.text('Rest 50 min'), findsOneWidget);
  });

  testWidgets('a screen reader hears the rest and which side of the step it is on', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Column(
            children: [
              RestBand(rest: Duration(minutes: 20), units: 2),
              RestBand(rest: Duration(minutes: 30), units: 3, before: false),
            ],
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Rest 20 min before this step'), findsOneWidget);
    expect(find.bySemanticsLabel('Rest 30 min after this step'), findsOneWidget);
    expect(find.bySemanticsLabel('Rest 20 min'), findsNothing, reason: 'the words are read once, with their side');
    semantics.dispose();
  });

  testWidgets('thirteen pebbles fit a narrow band and a short one without overflowing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Narrow: the pebbles wrap to more rows.
              const SizedBox(width: 160, child: RestBand(rest: Duration(hours: 2, minutes: 10), units: 13)),
              // Short: only the rows that fit are drawn.
              const SizedBox(width: 160, child: RestBand(rest: Duration(seconds: 30), units: 13)),
              // Too narrow for even the words: nothing is drawn, nothing breaks.
              const SizedBox(width: 40, child: RestBand(rest: Duration(minutes: 10), units: 1)),
              RestBand(rest: LadderRests.maxRest, units: 13),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Rest 6 hr 30 min'), findsOneWidget);
  });

  testWidgets('is never shorter than its own words at large text sizes', (tester) async {
    for (final scale in [1.3, 2.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const Scaffold(body: RestBand(rest: Duration(seconds: 30), units: 1)),
          ),
        ),
      );
      final paragraph = tester.renderObject<RenderParagraph>(find.text('Rest 30 sec'));
      expect(paragraph.debugHasOverflowShader, isFalse, reason: 'the words fit the band at $scale');
      expect(tester.getSize(find.byType(RestBand)).height, greaterThanOrEqualTo(paragraph.size.height));
    }
  });

  test('the pebbles are all drawn, closer together when the room is short, or not at all', () {
    // Room at the usual spacing.
    expect(RestBandPainter.layoutFor(13, const Size(160, 40)), isNotNull);
    expect(RestBandPainter.layoutFor(13, const Size(160, 40))!.gap, RestBandPainter.spacing);
    // A narrow band (one row, ten at the usual spacing): all thirteen still
    // drawn, closer together.
    final tight = RestBandPainter.layoutFor(13, const Size(120, 18));
    expect(tight, isNotNull);
    expect(tight!.perRow * tight.rows, greaterThanOrEqualTo(13));
    expect(tight.gap, lessThan(RestBandPainter.spacing));
    expect(tight.gap, greaterThanOrEqualTo(2 * RestBandPainter.radius + 1));
    // Too narrow for thirteen without overlap (they need 117 px): none
    // rather than a wrong count.
    expect(RestBandPainter.layoutFor(13, const Size(80, 18)), isNull);
    expect(RestBandPainter.layoutFor(0, const Size(160, 40)), isNull);
  });

  testWidgets('the band is a tint of the rest colour in both themes', (tester) async {
    for (final theme in [AppTheme.dark(), AppTheme.light()]) {
      await tester.pumpWidget(MaterialApp(theme: theme, home: const Scaffold(body: RestBand(rest: Duration(minutes: 10), units: 1))));
      final box = tester.widget<ColoredBox>(find.descendant(of: find.byType(RestBand), matching: find.byType(ColoredBox)));
      final band = HSLColor.fromColor(box.color);
      final rest = HSLColor.fromColor(theme.colorScheme.secondary);
      expect((band.hue - rest.hue).abs(), lessThan(1), reason: 'same hue as the rest colour');
      expect(box.color.a, lessThan(0.2), reason: 'a faint tint');
    }
  });

  test('the painter repaints only when the count or the colour changes', () {
    const a = RestBandPainter(units: 3, color: Colors.blue);
    const same = RestBandPainter(units: 3, color: Colors.blue);
    const more = RestBandPainter(units: 5, color: Colors.blue);
    const other = RestBandPainter(units: 3, color: Colors.green);
    expect(a.shouldRepaint(same), isFalse);
    expect(a.shouldRepaint(more), isTrue);
    expect(a.shouldRepaint(other), isTrue);
  });
}
