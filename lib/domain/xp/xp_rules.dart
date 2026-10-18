import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../entities/phase.dart';
import '../entities/session.dart';

/// Named bonuses. Values are flat XP added after the consistency multiplier.
enum XpBonus {
  firstEver(50, 'First session ever'),
  welcomeBack(40, 'Back after a few days away'),
  firstToday(10, 'First one today'),
  newPersonalRung(25, 'Highest rung yet on this task'),
  climbedLadder(15, 'Higher than last time on this task');

  const XpBonus(this.xp, this.label);

  final int xp;
  final String label;

  static XpBonus? fromName(String name) {
    for (final b in XpBonus.values) {
      if (b.name == name) return b;
    }
    return null;
  }
}

/// What the rules need to know about the person's history. The caller (a
/// repository) fills this in; the rules themselves never touch storage.
@immutable
class XpContext {
  const XpContext({
    this.firstSessionEver = false,
    this.daysSinceLastActive,
    this.firstCompletedToday = false,
    this.rungAttempted,
    this.previousMaxRungOnTask,
    this.previousRungOnTask,
    this.consistency = XpRules.minConsistency,
  });

  /// No interval has ever been completed before this one.
  final bool firstSessionEver;

  /// Calendar days between the last active day and today. Null when there is
  /// no previous active day. 0 means "already active today".
  final int? daysSinceLastActive;

  /// This is the first interval completed today.
  final bool firstCompletedToday;

  /// Rung position attempted in this approach, if any.
  final int? rungAttempted;

  /// Highest rung position previously attempted on the same task.
  final int? previousMaxRungOnTask;

  /// Rung position of the previous approach on the same task.
  final int? previousRungOnTask;

  /// Current consistency multiplier, already updated for today.
  final double consistency;
}

@immutable
class XpAward {
  const XpAward({
    required this.base,
    required this.multiplier,
    required this.bonuses,
  });

  final int base;
  final double multiplier;
  final List<XpBonus> bonuses;

  int get multiplied => (base * multiplier).round();
  int get bonusTotal => bonuses.fold(0, (sum, b) => sum + b.xp);
  int get total => multiplied + bonusTotal;

  @override
  String toString() =>
      'XpAward(base=$base x$multiplier + ${bonuses.map((b) => b.name).join(',')} = $total)';
}

/// Pure XP rules. Tune the constants here; the unit tests pin the shape of the curve.
class XpRules {
  XpRules._();

  static const double minConsistency = 1.0;
  static const double maxConsistency = 1.5;

  /// Added on the first completed interval of an active day.
  static const double consistencyStep = 0.05;

  /// Removed per missed day. Decays gently, never below [minConsistency].
  static const double consistencyDecayPerMissedDay = 0.03;

  /// A gap of at least this many days makes the return a "welcome back".
  static const int welcomeBackGapDays = 3;

  /// Every honoured rest earns this, flat. Rest is part of the method.
  static const int restBase = 12;

  /// Starting counts, even when the run is stopped early.
  static const int startBase = 10;
  static const int abandonedRestBase = 6;

  static double _log2(double x) => math.log(x) / math.ln2;

  static double _minutes(Duration d) => d.inMilliseconds / 60000.0;

  /// 1 min -> 30, 2 min -> 36, 5 min -> 46, 25 min -> 67, 50 min -> 77.
  static int approachBase(Duration actual) =>
      (20 + 10 * _log2(1 + _minutes(_clamp(actual)))).round();

  /// 0 min -> 10, 1 min -> 15, 5 min -> 23.
  static int abandonedApproachBase(Duration actual) =>
      startBase + (5 * _log2(1 + _minutes(_clamp(actual)))).round();

  static int baseFor({
    required Phase phase,
    required SessionOutcome outcome,
    required Duration actual,
  }) {
    final isApproach = phase == Phase.approach;
    return switch (outcome) {
      SessionOutcome.completed || SessionOutcome.snoozed =>
        isApproach ? approachBase(actual) : restBase,
      SessionOutcome.abandoned =>
        isApproach ? abandonedApproachBase(actual) : abandonedRestBase,
    };
  }

  static List<XpBonus> bonusesFor({
    required Phase phase,
    required SessionOutcome outcome,
    required XpContext ctx,
  }) {
    final bonuses = <XpBonus>[];
    if (ctx.firstSessionEver) {
      bonuses.add(XpBonus.firstEver);
    } else if (ctx.daysSinceLastActive != null &&
        ctx.daysSinceLastActive! >= welcomeBackGapDays &&
        ctx.firstCompletedToday) {
      bonuses.add(XpBonus.welcomeBack);
    }
    if (ctx.firstCompletedToday) bonuses.add(XpBonus.firstToday);

    // Attempting a higher rung counts even when the approach is stopped early.
    if (phase == Phase.approach && ctx.rungAttempted != null) {
      final rung = ctx.rungAttempted!;
      final prevMax = ctx.previousMaxRungOnTask;
      final prev = ctx.previousRungOnTask;
      if (prevMax != null && rung > prevMax) {
        bonuses.add(XpBonus.newPersonalRung);
      } else if (prev != null && rung > prev) {
        bonuses.add(XpBonus.climbedLadder);
      }
    }
    return bonuses;
  }

  static XpAward award({
    required Phase phase,
    required SessionOutcome outcome,
    required Duration actual,
    required XpContext ctx,
  }) {
    return XpAward(
      base: baseFor(phase: phase, outcome: outcome, actual: actual),
      multiplier: ctx.consistency.clamp(minConsistency, maxConsistency),
      bonuses: bonusesFor(phase: phase, outcome: outcome, ctx: ctx),
    );
  }

  /// Apply the decay for days with no activity. Never below [minConsistency].
  static double decayConsistency(double current, int missedDays) {
    if (missedDays <= 0) return current.clamp(minConsistency, maxConsistency);
    final decayed = current - missedDays * consistencyDecayPerMissedDay;
    return _round2(decayed.clamp(minConsistency, maxConsistency));
  }

  /// Apply today's bump (once per active day). Never above [maxConsistency].
  static double bumpConsistency(double current) =>
      _round2((current + consistencyStep).clamp(minConsistency, maxConsistency));

  /// Consistency for an interval completed today, given the last active day.
  /// Handles the first interval of the day (decay for the gap, then bump) and
  /// later intervals the same day (no change).
  static double consistencyForToday({
    required double current,
    required DateTime? lastActiveDay,
    required DateTime today,
  }) {
    if (lastActiveDay == null) return bumpConsistency(minConsistency);
    final gap = daysBetween(lastActiveDay, today);
    if (gap <= 0) return current.clamp(minConsistency, maxConsistency);
    final missed = gap - 1;
    return bumpConsistency(decayConsistency(current, missed));
  }

  static DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  /// Whole calendar days from [from] to [to] (local dates, time ignored).
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  static Duration _clamp(Duration d) => d.isNegative ? Duration.zero : d;

  static double _round2(double v) => (v * 100).round() / 100;
}
