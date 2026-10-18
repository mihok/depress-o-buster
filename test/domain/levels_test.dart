import 'package:depress_o_buster/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('thresholds follow 40 * (L - 1) * (L + 2)', () {
    expect(Levels.xpToReach(1), 0);
    expect(Levels.xpToReach(2), 160);
    expect(Levels.xpToReach(3), 400);
    expect(Levels.xpToReach(4), 720);
    expect(Levels.xpToReach(5), 1120);
    expect(Levels.xpToReach(10), 4320);
    expect(Levels.xpToReach(20), 16720);
  });

  test('thresholds are strictly increasing', () {
    for (var l = 1; l < Levels.maxLevel; l++) {
      expect(Levels.xpToReach(l + 1), greaterThan(Levels.xpToReach(l)));
    }
  });

  test('levelFor maps XP to the right level', () {
    expect(Levels.levelFor(0), 1);
    expect(Levels.levelFor(159), 1);
    expect(Levels.levelFor(160), 2);
    expect(Levels.levelFor(399), 2);
    expect(Levels.levelFor(400), 3);
    expect(Levels.levelFor(1 << 40), Levels.maxLevel);
  });

  test('level two is reachable in about five small sessions', () {
    // 30 XP for a one-minute approach, 12 for its rest, a few bonuses.
    const perRun = 30 + 12;
    expect((Levels.xpToReach(2) / perRun).ceil(), lessThanOrEqualTo(5));
  });

  test('names are calm and cover the first twenty levels', () {
    expect(Levels.names, hasLength(20));
    expect(Levels.nameFor(1), 'Resting');
    expect(Levels.nameFor(4), 'Sitting up');
    expect(Levels.nameFor(20), 'Here');
    expect(Levels.nameFor(21), contains('Here'));
    expect(Levels.nameFor(0), 'Resting');
    for (final n in Levels.names) {
      expect(n, isNot(contains('!')));
    }
  });

  test('progressFor reports position inside the level', () {
    final p = Levels.progressFor(200);
    expect(p.level, 2);
    expect(p.name, 'Stirring');
    expect(p.xpIntoLevel, 40);
    expect(p.xpSpan, 240);
    expect(p.xpToNext, 200);
    expect(p.fraction, closeTo(40 / 240, 1e-9));
    expect(p.nextName, 'Noticing');
    expect(Levels.progressFor(0).fraction, 0);
  });
}
