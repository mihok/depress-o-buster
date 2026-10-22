import 'package:depress_o_buster/ui/widgets/stretch_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the task screen: it owns the factor, follows every
/// onChanged, records what onChangeEnd hands it and, like the task screen,
/// returns the factor to 1 after a release (the control is relative).
class _Host {
  double factor = 1;
  final List<double> ends = [];

  Widget build() {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: StatefulBuilder(
            builder: (context, setState) => StretchSlider(
              factor: factor,
              onChanged: (f) => setState(() => factor = f),
              onChangeEnd: (f) => setState(() {
                ends.add(f);
                factor = 1;
              }),
              semanticsLabel: 'Step length',
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  final slider = find.byType(Slider);

  testWidgets('dragging into the right half multiplies, the left half divides', (tester) async {
    final host = _Host();
    await tester.pumpWidget(host.build());
    expect(tester.widget<Slider>(slider).divisions, isNull);
    final width = tester.getSize(slider).width;

    // A test drag grabs, moves and releases; the host returns the control
    // to ×1 on release, so the factor handed to onChangeEnd is what counts.
    await tester.drag(slider, Offset(width / 4, 0));
    await tester.pump();
    expect(host.ends, hasLength(1));
    expect(host.ends.single, greaterThan(1));
    expect(host.factor, 1);

    // Back at ×1 in the middle, the same distance left divides.
    await tester.drag(slider, Offset(-width / 4, 0));
    await tester.pump();
    expect(host.ends, hasLength(2));
    expect(host.ends.last, lessThan(1));
    expect(host.ends.last, closeTo(1 / host.ends.first, 1e-6), reason: 'equal drags multiply and divide equally');
  });

  testWidgets('holding an end stretches the range past the initial bounds', (tester) async {
    final host = _Host();
    await tester.pumpWidget(host.build());
    final rect = tester.getRect(slider);

    final right = await tester.startGesture(rect.center);
    await right.moveTo(Offset(rect.right, rect.center.dy));
    await tester.pump();
    expect(host.factor, lessThanOrEqualTo(4.0));

    // The bound grows ×1.15 every 120 ms while held: three ticks, then two
    // more, then it stops at the ×10 ceiling of a single release.
    await tester.pump(const Duration(milliseconds: 360));
    expect(host.factor, greaterThan(4.0));
    expect(host.factor, lessThan(10));
    final grown = host.factor;
    await tester.pump(const Duration(milliseconds: 240));
    expect(host.factor, greaterThan(grown));
    expect(host.factor, lessThan(10));
    await tester.pump(const Duration(seconds: 2));
    expect(host.factor, closeTo(10, 1e-9), reason: 'one release never goes past ×10');
    await right.up();
    await tester.pump();

    final left = await tester.startGesture(rect.center);
    await left.moveTo(Offset(rect.left, rect.center.dy));
    await tester.pump();
    expect(host.factor, greaterThanOrEqualTo(0.25));

    await tester.pump(const Duration(milliseconds: 360));
    expect(host.factor, lessThan(0.25));
    expect(host.factor, greaterThan(0.1));
    final shrunk = host.factor;
    await tester.pump(const Duration(milliseconds: 240));
    expect(host.factor, lessThan(shrunk));
    expect(host.factor, greaterThan(0.1));
    await tester.pump(const Duration(seconds: 2));
    expect(host.factor, closeTo(0.1, 1e-9), reason: 'one release never goes below ×0.1');
    await left.up();
    await tester.pump();
  });

  testWidgets('release reports the last factor once and stops stretching', (tester) async {
    final host = _Host();
    await tester.pumpWidget(host.build());
    final rect = tester.getRect(slider);

    final gesture = await tester.startGesture(rect.center);
    await gesture.moveTo(Offset(rect.right, rect.center.dy));
    await tester.pump(const Duration(milliseconds: 600));
    expect(host.ends, isEmpty);

    final held = host.factor;
    await gesture.up();
    await tester.pump();
    expect(host.ends, [held], reason: 'release reports exactly the last factor handed to onChanged');
    expect(held, greaterThan(4.0));
    expect(host.factor, 1, reason: 'the host returned the relative control to ×1');

    // The timer is gone: more time changes nothing. The test binding also
    // fails any test that ends with a timer still pending.
    await tester.pump(const Duration(seconds: 2));
    expect(host.factor, 1);
    expect(host.ends, hasLength(1));
  });

  testWidgets('stands at least 56 px tall and carries its label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_Host().build());
    expect(tester.getSize(find.byType(StretchSlider)).height, greaterThanOrEqualTo(56));
    expect(find.text('Shorter'), findsOneWidget);
    expect(find.text('Longer'), findsOneWidget);
    expect(find.bySemanticsLabel('Step length'), findsOneWidget);
    semantics.dispose();
  });
}
