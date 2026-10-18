import 'package:depress_o_buster/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const min = Duration(minutes: 1);

  group('approach base curve', () {
    test('pins the documented values', () {
      expect(XpRules.approachBase(min), 30);
      expect(XpRules.approachBase(const Duration(minutes: 2)), 36);
      expect(XpRules.approachBase(const Duration(minutes: 5)), 46);
      expect(XpRules.approachBase(const Duration(minutes: 25)), 67);
      expect(XpRules.approachBase(const Duration(minutes: 50)), 77);
    });

    test('a one-minute approach is meaningful, at least 40% of a 25-minute one', () {
      final one = XpRules.approachBase(min);
      final long = XpRules.approachBase(const Duration(minutes: 25));
      expect(one / long, greaterThanOrEqualTo(0.4));
    });

    test('a 30-second approach still earns real XP', () {
      expect(XpRules.approachBase(const Duration(seconds: 30)), greaterThanOrEqualTo(25));
    });

    test('is monotonic and flattens', () {
      var prev = XpRules.approachBase(Duration.zero);
      var prevGain = 1 << 30;
      for (final m in [1, 2, 5, 10, 25, 50, 100]) {
        final v = XpRules.approachBase(Duration(minutes: m));
        expect(v, greaterThan(prev));
        final gain = (v - prev) / m;
        expect(gain, lessThanOrEqualTo(prevGain + 1e-9));
        prevGain = gain.ceil();
        prev = v;
      }
    });

    test('negative durations are treated as zero', () {
      expect(XpRules.approachBase(const Duration(minutes: -5)), XpRules.approachBase(Duration.zero));
    });
  });

  group('rest and abandoned bases', () {
    test('rest is flat regardless of length', () {
      expect(XpRules.baseFor(phase: Phase.rest, outcome: SessionOutcome.completed, actual: min), 12);
      expect(XpRules.baseFor(phase: Phase.longRest, outcome: SessionOutcome.snoozed, actual: const Duration(hours: 1)), 12);
    });

    test('abandoned approaches earn something for starting, less than completing', () {
      expect(XpRules.abandonedApproachBase(Duration.zero), 10);
      expect(XpRules.abandonedApproachBase(min), 15);
      expect(XpRules.abandonedApproachBase(const Duration(minutes: 5)), 23);
      for (final m in [0, 1, 3, 10, 40]) {
        final d = Duration(minutes: m);
        expect(XpRules.abandonedApproachBase(d), lessThan(XpRules.approachBase(d)));
        expect(XpRules.abandonedApproachBase(d), greaterThan(0));
      }
    });

    test('abandoned rest earns a small flat amount', () {
      expect(XpRules.baseFor(phase: Phase.rest, outcome: SessionOutcome.abandoned, actual: min), 6);
    });

    test('snoozed approaches earn the same as completed ones of that length', () {
      expect(
        XpRules.baseFor(phase: Phase.approach, outcome: SessionOutcome.snoozed, actual: const Duration(minutes: 7)),
        XpRules.approachBase(const Duration(minutes: 7)),
      );
    });
  });

  group('bonuses', () {
    test('first session ever stacks with first today, never with welcome back', () {
      final b = XpRules.bonusesFor(
        phase: Phase.approach,
        outcome: SessionOutcome.completed,
        ctx: const XpContext(firstSessionEver: true, firstCompletedToday: true, daysSinceLastActive: 10),
      );
      expect(b, containsAll([XpBonus.firstEver, XpBonus.firstToday]));
      expect(b, isNot(contains(XpBonus.welcomeBack)));
    });

    test('welcome back after a gap of 3 or more days, bigger than a normal day', () {
      final back = XpRules.bonusesFor(
        phase: Phase.approach,
        outcome: SessionOutcome.completed,
        ctx: const XpContext(daysSinceLastActive: 3, firstCompletedToday: true),
      );
      expect(back, containsAll([XpBonus.welcomeBack, XpBonus.firstToday]));
      final normal = XpRules.bonusesFor(
        phase: Phase.approach,
        outcome: SessionOutcome.completed,
        ctx: const XpContext(daysSinceLastActive: 1, firstCompletedToday: true),
      );
      expect(normal, [XpBonus.firstToday]);
      expect(XpBonus.welcomeBack.xp, greaterThan(XpBonus.firstToday.xp));
    });

    test('welcome back only once: later intervals the same day do not get it', () {
      final b = XpRules.bonusesFor(
        phase: Phase.approach,
        outcome: SessionOutcome.completed,
        ctx: const XpContext(daysSinceLastActive: 0, firstCompletedToday: false),
      );
      expect(b, isEmpty);
    });

    test('new personal rung beats climbed ladder; neither when going lower', () {
      List<XpBonus> rung(int attempted, {int? prevMax, int? prev}) => XpRules.bonusesFor(
        phase: Phase.approach,
        outcome: SessionOutcome.completed,
        ctx: XpContext(rungAttempted: attempted, previousMaxRungOnTask: prevMax, previousRungOnTask: prev),
      );
      expect(rung(5, prevMax: 4, prev: 4), [XpBonus.newPersonalRung]);
      expect(rung(3, prevMax: 5, prev: 2), [XpBonus.climbedLadder]);
      expect(rung(2, prevMax: 5, prev: 2), isEmpty);
      expect(rung(1, prevMax: 5, prev: 4), isEmpty);
      expect(rung(0), isEmpty, reason: 'first attempt on a task has nothing to compare');
    });

    test('rung bonuses are awarded even when the approach was stopped early', () {
      final b = XpRules.bonusesFor(
        phase: Phase.approach,
        outcome: SessionOutcome.abandoned,
        ctx: const XpContext(rungAttempted: 6, previousMaxRungOnTask: 5),
      );
      expect(b, [XpBonus.newPersonalRung]);
    });

    test('rest intervals never get rung bonuses', () {
      final b = XpRules.bonusesFor(
        phase: Phase.rest,
        outcome: SessionOutcome.completed,
        ctx: const XpContext(rungAttempted: 6, previousMaxRungOnTask: 5),
      );
      expect(b, isEmpty);
    });
  });

  group('award', () {
    test('total = round(base * multiplier) + bonuses', () {
      final award = XpRules.award(
        phase: Phase.approach,
        outcome: SessionOutcome.completed,
        actual: min,
        ctx: const XpContext(consistency: 1.25, firstCompletedToday: true, daysSinceLastActive: 1),
      );
      expect(award.base, 30);
      expect(award.multiplier, 1.25);
      expect(award.multiplied, 38);
      expect(award.bonuses, [XpBonus.firstToday]);
      expect(award.total, 48);
    });

    test('multiplier is clamped to the allowed range', () {
      final award = XpRules.award(
        phase: Phase.rest,
        outcome: SessionOutcome.completed,
        actual: min,
        ctx: const XpContext(consistency: 9),
      );
      expect(award.multiplier, XpRules.maxConsistency);
    });
  });

  group('consistency', () {
    test('bumps by 0.05 per active day up to 1.5', () {
      expect(XpRules.bumpConsistency(1.0), 1.05);
      expect(XpRules.bumpConsistency(1.47), 1.5);
      expect(XpRules.bumpConsistency(1.5), 1.5);
    });

    test('decays gently per missed day and never below 1.0', () {
      expect(XpRules.decayConsistency(1.5, 3), 1.41);
      expect(XpRules.decayConsistency(1.05, 10), 1.0);
      expect(XpRules.decayConsistency(1.2, 0), 1.2);
    });

    test('consistencyForToday handles first day, same day, consecutive days and gaps', () {
      final today = DateTime(2026, 10, 18);
      expect(XpRules.consistencyForToday(current: 1.0, lastActiveDay: null, today: today), 1.05);
      expect(XpRules.consistencyForToday(current: 1.2, lastActiveDay: today, today: today), 1.2);
      expect(XpRules.consistencyForToday(current: 1.2, lastActiveDay: DateTime(2026, 10, 17), today: today), 1.25);
      // 4-day gap = 3 missed days: 1.2 - 0.09 + 0.05
      expect(XpRules.consistencyForToday(current: 1.2, lastActiveDay: DateTime(2026, 10, 14), today: today), 1.16);
      // A very long gap bottoms out at 1.0 then bumps.
      expect(XpRules.consistencyForToday(current: 1.5, lastActiveDay: DateTime(2025, 1, 1), today: today), 1.05);
    });

    test('daysBetween counts calendar days across month ends', () {
      expect(XpRules.daysBetween(DateTime(2026, 9, 30, 23, 59), DateTime(2026, 10, 1, 0, 1)), 1);
      expect(XpRules.daysBetween(DateTime(2026, 10, 18, 1), DateTime(2026, 10, 18, 23)), 0);
      expect(XpRules.daysBetween(DateTime(2026, 10, 1), DateTime(2026, 10, 18)), 17);
    });
  });
}
