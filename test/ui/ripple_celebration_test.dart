import 'package:depress_o_buster/ui/widgets/ripple_celebration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Object? trigger, {bool reduceMotion = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: Center(
          child: RippleCelebration(trigger: trigger, child: const Text('+36 XP')),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a null trigger never plays', (tester) async {
    await tester.pumpWidget(_app(null));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('plays once per trigger value', (tester) async {
    await tester.pumpWidget(_app('session-1'));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
    // A controller completes on the first tick past its duration.
    await tester.pump(RippleCelebration.duration + const Duration(milliseconds: 20));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);

    // The same value again: nothing.
    await tester.pumpWidget(_app('session-1'));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);

    // A new value: one more ring.
    await tester.pumpWidget(_app('session-2'));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(RippleCelebration.duration + const Duration(milliseconds: 20));
  });

  testWidgets('honours reduced motion', (tester) async {
    await tester.pumpWidget(_app('session-1', reduceMotion: true));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  test('the ring stays faint and fades out', () {
    const start = RipplePainter(progress: 0.05, color: Colors.blue);
    const end = RipplePainter(progress: 0.95, color: Colors.blue);
    expect(start.shouldRepaint(end), isTrue);
    expect(start.shouldRepaint(const RipplePainter(progress: 0.05, color: Colors.blue)), isFalse);
  });
}
