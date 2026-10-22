import 'package:depress_o_buster/ui/widgets/stretch_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the task screen: it owns the factor, follows every
/// onChanged, records what onChangeEnd hands it and, like the task screen,
/// returns the factor to 1 after a release (the control is relative).
class _Host {
  double factor = 1;
  final List<double> ends = [];

  /// Alone in the middle of the screen, or ([inList]) inside a vertical
  /// scroll view, as on the task screen, where the two share the gesture
  /// arena.
  Widget build({bool inList = false}) {
    final slider = StatefulBuilder(
      builder: (context, setState) => StretchSlider(
        factor: factor,
        onChanged: (f) => setState(() => factor = f),
        onChangeEnd: (f) => setState(() {
          ends.add(f);
          factor = 1;
        }),
        semanticsLabel: 'Step length',
      ),
    );
    return MaterialApp(
      home: Scaffold(
        body: inList
            ? ListView(children: [const SizedBox(height: 200), slider, const SizedBox(height: 2000)])
            : Center(child: slider),
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

  testWidgets('a screen-reader or keyboard step is one whole change, with nothing left running', (tester) async {
    final semantics = tester.ensureSemantics();
    final host = _Host();
    await tester.pumpWidget(host.build());
    final node = tester.getSemantics(find.byType(Slider));
    tester.binding.performSemanticsAction(
      SemanticsActionEvent(type: SemanticsAction.increase, viewId: tester.view.viewId, nodeId: node.id),
    );
    await tester.pump();
    expect(host.ends, hasLength(1), reason: 'reported at once: no release will ever come');
    expect(host.ends.single, greaterThan(1));
    expect(host.factor, 1, reason: 'the host returned the relative control to ×1');
    // No timer is armed: the binding would fail the test if one were pending.
    await tester.pump(const Duration(seconds: 2));
    expect(host.ends, hasLength(1));
    semantics.dispose();
  });

  /// A held thumb slides in two moves: in a scroll view the slider's drag
  /// wins the arena only past the touch slop, and that move is its start.
  Future<void> slide(WidgetTester tester, TestGesture gesture, double dx) async {
    await gesture.moveBy(Offset(dx.sign * 20, 0));
    await tester.pump();
    await gesture.moveBy(Offset(dx - dx.sign * 20, 0));
    await tester.pump();
  }

  testWidgets('a touch off the thumb that turns into a scroll leaves the next thumb drag working', (tester) async {
    final host = _Host();
    await tester.pumpWidget(host.build(inList: true));
    var rect = tester.getRect(slider);
    // Rest on the track off the thumb past the tap deadline, then scroll.
    final stray = await tester.startGesture(rect.center + const Offset(150, 0));
    await tester.pump(const Duration(milliseconds: 150));
    await stray.moveBy(const Offset(0, 60));
    await tester.pump();
    await stray.up();
    await tester.pumpAndSettle();
    expect(host.ends, isEmpty);

    rect = tester.getRect(slider);
    final drag = await tester.startGesture(rect.center);
    await tester.pump();
    await slide(tester, drag, 100);
    expect(host.factor, greaterThan(1), reason: 'the stray touch did not jam the slider');
    await drag.up();
    await tester.pump();
    expect(host.ends, hasLength(1));
    expect(host.ends.single, greaterThan(1));
  });

  testWidgets('a hold on the thumb that turns into a scroll does not arm a later touch on the track', (tester) async {
    final host = _Host();
    await tester.pumpWidget(host.build(inList: true));
    var rect = tester.getRect(slider);
    final hold = await tester.startGesture(rect.center);
    await tester.pump(const Duration(milliseconds: 150));
    await hold.moveBy(const Offset(0, 60));
    await tester.pump();
    await hold.up();
    await tester.pumpAndSettle();

    rect = tester.getRect(slider);
    final stray = await tester.startGesture(Offset(rect.left + 40, rect.center.dy));
    await tester.pump();
    await slide(tester, stray, 100);
    expect(host.factor, 1, reason: 'a touch off the thumb moves nothing');
    await stray.up();
    await tester.pump();
    expect(host.ends.where((f) => f != 1), isEmpty, reason: 'and saves nothing');
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

  testWidgets('pulling back from past the end stops stretching, pushing out again resumes it', (tester) async {
    final host = _Host();
    await tester.pumpWidget(host.build());
    final rect = tester.getRect(slider);
    final past = Offset(rect.right + 60, rect.center.dy);

    // Past the end the slider pins its value at the maximum and reports
    // nothing new however the finger moves, so the finger itself decides.
    final gesture = await tester.startGesture(rect.center);
    await gesture.moveTo(past);
    await tester.pump(const Duration(milliseconds: 360));
    expect(host.factor, greaterThan(4.0));
    final stopped = host.factor;

    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump(const Duration(milliseconds: 600));
    expect(host.factor, stopped, reason: 'moving back towards the middle stops the stretching');

    await gesture.moveTo(past);
    await tester.pump(const Duration(milliseconds: 360));
    expect(host.factor, greaterThan(stopped), reason: 'pushing outward again resumes it');
    await gesture.up();
    await tester.pump();
    expect(host.ends, hasLength(1));
  });

  testWidgets('a tremor of a few pixels does not stop the stretching', (tester) async {
    final host = _Host();
    await tester.pumpWidget(host.build());
    final rect = tester.getRect(slider);

    final gesture = await tester.startGesture(rect.center);
    await gesture.moveTo(Offset(rect.right, rect.center.dy));
    await tester.pump(const Duration(milliseconds: 240));
    final grown = host.factor;
    expect(grown, greaterThan(4.0));

    await gesture.moveBy(const Offset(-5, 0));
    await tester.pump(const Duration(milliseconds: 240));
    expect(host.factor, greaterThan(grown), reason: '5 px back is tremor, not a change of mind');
    await gesture.up();
    await tester.pump();
  });

  testWidgets('the thumb is grabbed within 28 px of its centre, not beyond', (tester) async {
    final host = _Host();
    await tester.pumpWidget(host.build());
    final centre = tester.getRect(slider).center;

    // Only a touch inside the overlay circle grabs the thumb. 40 px out is
    // beyond the 56 px circle, so the drag goes nowhere.
    final outside = await tester.startGesture(centre + const Offset(40, 0));
    await outside.moveBy(const Offset(100, 0));
    await tester.pump();
    expect(host.factor, 1);
    await outside.up();
    await tester.pump();
    expect(host.ends, isEmpty);

    // 26 px out is inside it, though outside the 48 px circle a Slider gets
    // by default.
    final inside = await tester.startGesture(centre + const Offset(26, 0));
    await inside.moveBy(const Offset(100, 0));
    await tester.pump();
    expect(host.factor, greaterThan(1));
    await inside.up();
    await tester.pump();
    expect(host.ends, hasLength(1));
    expect(host.ends.single, greaterThan(1));
  });
}
