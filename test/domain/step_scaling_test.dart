import 'package:depress_o_buster/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const s = Duration(seconds: 1);
  const m = Duration(minutes: 1);

  group('StepScaling.round', () {
    test('never goes below 30 seconds', () {
      expect(StepScaling.round(Duration.zero), s * 30);
      expect(StepScaling.round(s * 10), s * 30);
      expect(StepScaling.round(s * 44), s * 30);
    });

    test('under 5 minutes: nearest 30 seconds, halves up', () {
      expect(StepScaling.round(s * 45), m);
      expect(StepScaling.round(m + s * 10), m);
      expect(StepScaling.round(m + s * 15), m + s * 30);
      expect(StepScaling.round(m + s * 44), m + s * 30);
      expect(StepScaling.round(m * 4 + s * 59), m * 5);
    });

    test('from 5 minutes: nearest minute, halves up', () {
      expect(StepScaling.round(m * 5), m * 5);
      expect(StepScaling.round(m * 5 + s * 29), m * 5);
      expect(StepScaling.round(m * 5 + s * 30), m * 6);
      expect(StepScaling.round(m * 12 + s * 20), m * 12);
      expect(StepScaling.round(m * 60 + s * 40), m * 61);
    });

    test('a value already on the grid is unchanged', () {
      for (final d in [s * 30, m, m + s * 30, m * 3, m * 5, m * 25, m * 90]) {
        expect(StepScaling.round(d), d);
      }
    });
  });

  group('StepScaling.scale', () {
    test('multiplies then rounds', () {
      expect(StepScaling.scale(m * 2, 0.25), s * 30);
      expect(StepScaling.scale(m, 0.25), s * 30, reason: '15 seconds is lifted to the floor');
      expect(StepScaling.scale(m * 7, 0.5), m * 3 + s * 30);
      expect(StepScaling.scale(m * 3, 1.5), m * 4 + s * 30);
      expect(StepScaling.scale(m * 10, 0.75), m * 8, reason: '7 min 30 s is at or above 5 min, so whole minutes');
      expect(StepScaling.scale(m * 25, 2), m * 50);
      expect(StepScaling.scale(s * 30, 3), m + s * 30);
    });
  });

  group('StepScaling.scaleAll', () {
    LadderStep step(String id, int position, Duration? d) =>
        LadderStep(id: id, taskId: 't', position: position, text: 'step $id', suggestedDuration: d);

    test('scales every timed step, leaves untimed ones alone, keeps identity', () {
      final ladder = [step('a', 0, m), step('b', 1, null), step('c', 2, s * 30), step('d', 3, m * 5)];
      final scaled = StepScaling.scaleAll(ladder, 0.5);
      expect(scaled.map((x) => x.suggestedDuration), [s * 30, null, s * 30, m * 2 + s * 30]);
      expect(scaled.map((x) => x.id), ['a', 'b', 'c', 'd']);
      expect(scaled.map((x) => x.position), [0, 1, 2, 3]);
      expect(scaled.map((x) => x.text), ladder.map((x) => x.text));
      expect(scaled[1], same(ladder[1]), reason: 'an untimed step is the same object');
    });
  });

  group('StepScaling stops and labels', () {
    test('seven stops, ascending, with ×1 in the middle', () {
      expect(StepScaling.factors, [0.25, 0.5, 0.75, 1, 1.5, 2, 3]);
      expect(StepScaling.factors[3], 1);
    });

    test('labels read as multipliers without trailing zeros', () {
      expect(StepScaling.label(0.25), '×0.25');
      expect(StepScaling.label(0.5), '×0.5');
      expect(StepScaling.label(1), '×1');
      expect(StepScaling.label(1.5), '×1.5');
      expect(StepScaling.label(3), '×3');
      expect(StepScaling.label(1.88), '×1.88');
    });

    test('a factor a hair off a whole number reads as that number, never "×1."', () {
      expect(StepScaling.label(1.003), '×1');
      expect(StepScaling.label(0.998), '×1');
      expect(StepScaling.label(2.001), '×2');
      expect(StepScaling.label(1.104), '×1.1');
    });
  });
}
