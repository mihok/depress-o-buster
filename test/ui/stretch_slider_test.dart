import 'package:depress_o_buster/ui/widgets/stretch_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the task screen: it owns the factor, follows every
/// onChanged, and keeps whatever onChangeEnd hands it.
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
              onChangeEnd: ends.add,
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

    await tester.drag(slider, Offset(width / 4, 0));
    await tester.pump();
    expect(host.factor, greaterThan(1));

    // A drag starts by jumping the thumb to the pointer, so this one begins
    // at ×1 in the middle and lands a quarter of the way in from the left.
    await tester.drag(slider, Offset(-width / 4, 0));
    await tester.pump();
    expect(host.factor, lessThan(1));
  });

  testWidgets('holding an end stretches the range past the initial bounds', (tester) async {
    final host = _Host();
    await tester.pumpWidget(host.build());
    final rect = tester.getRect(slider);

    final right = await tester.startGesture(rect.center);
    await right.moveTo(Offset(rect.right, rect.center.dy));
    await tester.pump();
    expect(host.factor, lessThanOrEqualTo(4.0));

    await tester.pump(const Duration(seconds: 1));
    expect(host.factor, greaterThan(4.0));
    final grown = host.factor;
    await tester.pump(const Duration(milliseconds: 500));
    expect(host.factor, greaterThan(grown));
    expect(host.factor, lessThanOrEqualTo(10));
    await right.up();
    await tester.pump();

    final left = await tester.startGesture(rect.center);
    await left.moveTo(Offset(rect.left, rect.center.dy));
    await tester.pump();
    expect(host.factor, greaterThanOrEqualTo(0.25));

    await tester.pump(const Duration(seconds: 1));
    expect(host.factor, lessThan(0.25));
    final shrunk = host.factor;
    await tester.pump(const Duration(milliseconds: 500));
    expect(host.factor, lessThan(shrunk));
    expect(host.factor, greaterThanOrEqualTo(0.1));
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

    await gesture.up();
    await tester.pump();
    final released = host.factor;
    expect(released, greaterThan(4.0));
    expect(host.ends, [released]);

    // The timer is gone: more time changes nothing. The test binding also
    // fails any test that ends with a timer still pending.
    await tester.pump(const Duration(seconds: 2));
    expect(host.factor, released);
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
