import 'package:depress_o_buster/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const unit = Duration(minutes: 10);

  test('rests climb 1, 1, 2, 3, 5, 8, 13 units and then stay', () {
    expect([for (var p = 0; p < 9; p++) LadderRests.multiplierFor(p)], [1, 1, 2, 3, 5, 8, 13, 13, 13]);
    expect(LadderRests.restFor(unit: unit, position: 0), const Duration(minutes: 10));
    expect(LadderRests.restFor(unit: unit, position: 2), const Duration(minutes: 20));
    expect(LadderRests.restFor(unit: unit, position: 5), const Duration(minutes: 80));
    expect(LadderRests.restFor(unit: unit, position: 40), const Duration(minutes: 130));
    expect(LadderRests.multiplierFor(-3), 1);
  });

  test('the rest follows the place in the ladder, not the step', () {
    // Two steps swap places: the rests stay with the places.
    final a = LadderRests.restFor(unit: unit, position: 1);
    final b = LadderRests.restFor(unit: unit, position: 4);
    expect(a, const Duration(minutes: 10));
    expect(b, const Duration(minutes: 50));
  });

  test('a task uses its own unit, or the fallback', () {
    final t = Task(id: 't', title: 'Laundry', createdAt: DateTime(2026));
    expect(LadderRests.unitFor(t, unit), unit);
    expect(LadderRests.unitFor(t.copyWith(restUnit: const Duration(minutes: 3)), unit), const Duration(minutes: 3));
    expect(LadderRests.unitFor(t.copyWith(restUnit: const Duration(minutes: 3)).copyWith(clearRestUnit: true), unit), unit);
  });

  test('scaling the unit rounds like step times', () {
    expect(LadderRests.scaleUnit(unit, 0.5), const Duration(minutes: 5));
    expect(LadderRests.scaleUnit(const Duration(minutes: 1), 0.25), const Duration(seconds: 30));
    expect(LadderRests.scaleUnit(unit, 1.37), const Duration(minutes: 14));
  });

  test('describes the whole climb in the words used everywhere else', () {
    expect(LadderRests.describe(unit), '10, 10, 20, 30, 50 min, 1 hr 20 min, then 2 hr 10 min from step 7 on');
    expect(
      LadderRests.describe(const Duration(seconds: 90)),
      '1 min 30 sec, 1 min 30 sec, 3 min, 4 min 30 sec, 7 min 30 sec, 12 min, then 19 min 30 sec from step 7 on',
    );
    expect(LadderRests.restsFor(unit, 3), [const Duration(minutes: 10), const Duration(minutes: 10), const Duration(minutes: 20)]);
  });

  test('the unit stays between 30 seconds and 30 minutes, wherever it comes from', () {
    expect(LadderRests.clampUnit(const Duration(seconds: 5)), LadderRests.minUnit);
    expect(LadderRests.clampUnit(const Duration(hours: 4)), LadderRests.maxUnit);
    expect(LadderRests.clampUnit(unit), unit);
    final t = Task(id: 't', title: 'Laundry', createdAt: DateTime(2026));
    expect(LadderRests.unitFor(t, const Duration(hours: 24)), LadderRests.maxUnit, reason: 'a huge Settings rest');
    expect(LadderRests.unitFor(t.copyWith(restUnit: const Duration(seconds: 1)), unit), LadderRests.minUnit);
    // The longest rest any step can get is a long afternoon, not days.
    expect(LadderRests.maxRest, const Duration(hours: 6, minutes: 30));
    expect(LadderRests.restFor(unit: LadderRests.maxUnit, position: 40), LadderRests.maxRest);
  });

  test('a round for a step uses its place in the ladder and no long rest', () {
    const base = TimerConfig(
      approach: Duration(minutes: 2),
      rest: Duration(minutes: 5),
      longRest: Duration(minutes: 20),
      cyclesBeforeLongRest: 4,
    );
    final t = Task(id: 't', title: 'Laundry', createdAt: DateTime(2026));
    final timed = LadderStep(id: 's', taskId: 't', position: 4, text: 'Sit by the pile', suggestedDuration: const Duration(minutes: 5));
    final round = LadderRests.roundFor(base: base, task: t, step: timed, fallbackUnit: unit);
    expect(round.approach, const Duration(minutes: 5));
    expect(round.rest, const Duration(minutes: 50));
    expect(round.longRest, isNull);
    expect(round.cyclesBeforeLongRest, 0);
    // An untimed step takes the usual approach; a task's own unit wins.
    final untimed = LadderStep(id: 'u', taskId: 't', position: 0, text: 'Think about it');
    final own = LadderRests.roundFor(base: base, task: t.copyWith(restUnit: const Duration(minutes: 3)), step: untimed, fallbackUnit: unit);
    expect(own.approach, const Duration(minutes: 2));
    expect(own.rest, const Duration(minutes: 3));
  });
}
