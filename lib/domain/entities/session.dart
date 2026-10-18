import 'package:meta/meta.dart';

import 'phase.dart';

/// How an interval ended. All three are logged neutrally.
enum SessionOutcome {
  completed,
  snoozed,
  abandoned;

  String get label => switch (this) {
    SessionOutcome.completed => 'Completed',
    SessionOutcome.snoozed => 'Completed (snoozed)',
    SessionOutcome.abandoned => 'Stopped early',
  };

  static SessionOutcome fromStorageKey(String key) => SessionOutcome.values
      .firstWhere((o) => o.name == key, orElse: () => SessionOutcome.completed);
}

/// One logged interval (an approach or a rest). Approach and rest intervals of
/// the same run share a [runId].
@immutable
class Session {
  const Session({
    required this.id,
    required this.runId,
    required this.phase,
    required this.planned,
    required this.actual,
    required this.outcome,
    required this.startedAt,
    required this.endedAt,
    this.taskId,
    this.taskTitle,
    this.rungPosition,
    this.rungText,
    this.snoozeCount = 0,
    this.moodBefore,
    this.moodAfter,
    this.xpEarned = 0,
    this.xpBonuses = const [],
  });

  final String id;
  final String runId;
  final String? taskId;
  final String? taskTitle;
  final int? rungPosition;
  final String? rungText;
  final Phase phase;
  final Duration planned;
  final Duration actual;
  final SessionOutcome outcome;
  final int snoozeCount;
  final DateTime startedAt;
  final DateTime endedAt;
  final String? moodBefore;
  final String? moodAfter;
  final int xpEarned;

  /// Names of the XP bonuses awarded, for display in history.
  final List<String> xpBonuses;

  bool get isApproach => phase == Phase.approach;

  Session copyWith({
    String? moodBefore,
    String? moodAfter,
    int? xpEarned,
    List<String>? xpBonuses,
  }) {
    return Session(
      id: id,
      runId: runId,
      taskId: taskId,
      taskTitle: taskTitle,
      rungPosition: rungPosition,
      rungText: rungText,
      phase: phase,
      planned: planned,
      actual: actual,
      outcome: outcome,
      snoozeCount: snoozeCount,
      startedAt: startedAt,
      endedAt: endedAt,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      xpEarned: xpEarned ?? this.xpEarned,
      xpBonuses: xpBonuses ?? this.xpBonuses,
    );
  }

  @override
  String toString() =>
      'Session(${phase.name} ${outcome.name} ${actual.inSeconds}s/${planned.inSeconds}s xp=$xpEarned)';
}
