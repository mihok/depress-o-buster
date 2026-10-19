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

  test('describes the climb in minutes', () {
    expect(LadderRests.describe(unit), '10, 10, 20, 30, 50 min, …');
    expect(LadderRests.describe(const Duration(seconds: 90), count: 3), '1.5, 1.5, 3 min, …');
  });
}
