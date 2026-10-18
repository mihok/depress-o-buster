import 'package:clock/clock.dart';
import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../db/database.dart';
import '../mappers.dart';

class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  Future<void> insert(Session session) async {
    await _db.into(_db.sessions).insert(sessionToCompanion(session, clock.now()));
  }

  Future<Session?> get(String id) async {
    final row = await (_db.select(_db.sessions)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : sessionFromRow(row);
  }

  /// Every logged interval, newest first. The History screen uses this.
  Stream<List<Session>> watchAll() =>
      (_db.select(_db.sessions)..orderBy([(s) => OrderingTerm.desc(s.endedAt)]))
          .watch()
          .map((rows) => rows.map(sessionFromRow).toList());

  Stream<List<Session>> watchRecent({int limit = 300}) =>
      (_db.select(_db.sessions)
            ..orderBy([(s) => OrderingTerm.desc(s.endedAt)])
            ..limit(limit))
          .watch()
          .map((rows) => rows.map(sessionFromRow).toList());

  Future<List<Session>> between(DateTime from, DateTime to) async {
    final rows = await (_db.select(_db.sessions)
          ..where(
            (s) =>
                s.endedAt.isBiggerOrEqualValue(from.toUtc()) &
                s.endedAt.isSmallerThanValue(to.toUtc()),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.endedAt)]))
        .get();
    return rows.map(sessionFromRow).toList();
  }

  Future<void> updateMood(String id, {String? before, String? after}) async {
    await (_db.update(_db.sessions)..where((s) => s.id.equals(id))).write(
      SessionsCompanion(
        moodBefore: before == null ? const Value.absent() : Value(before),
        moodAfter: after == null ? const Value.absent() : Value(after),
        updatedAt: Value(clock.now().toUtc()),
      ),
    );
  }

  Future<void> deleteAll() => _db.delete(_db.sessions).go();

  /// Completed or snoozed intervals that ended on [day] (local).
  Future<int> countCompletedOn(DateTime day) async {
    // Calendar arithmetic: DateTime normalises day + 1 across DST changes,
    // where Duration arithmetic would land an hour off local midnight.
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day + 1);
    final rows = await between(start, end);
    return rows.where((s) => s.outcome != SessionOutcome.abandoned).length;
  }

  /// Every logged interval, any outcome.
  Future<int> totalCount() async {
    final count = _db.sessions.id.count();
    final q = _db.selectOnly(_db.sessions)..addColumns([count]);
    return (await q.getSingle()).read(count) ?? 0;
  }

  Future<int> totalCompleted() async {
    final count = _db.sessions.id.count();
    final q = _db.selectOnly(_db.sessions)
      ..addColumns([count])
      ..where(_db.sessions.outcome.isNotValue(SessionOutcome.abandoned.name));
    return (await q.getSingle()).read(count) ?? 0;
  }

  /// Most recent approach on [taskId], completed or not.
  Future<Session?> lastApproachOnTask(String taskId) async {
    final row = await (_db.select(_db.sessions)
          ..where(
            (s) => s.taskId.equals(taskId) & s.phase.equals(Phase.approach.storageKey),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.endedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : sessionFromRow(row);
  }

  /// Highest rung ever attempted on [taskId].
  Future<int?> maxRungOnTask(String taskId) async {
    final maxRung = _db.sessions.rungPosition.max();
    final q = _db.selectOnly(_db.sessions)
      ..addColumns([maxRung])
      ..where(
        _db.sessions.taskId.equals(taskId) &
            _db.sessions.phase.equals(Phase.approach.storageKey),
      );
    return (await q.getSingleOrNull())?.read(maxRung);
  }

  /// Longest approach that was not stopped early.
  Future<Duration> longestApproach() async {
    final longest = _db.sessions.actualSeconds.max();
    final q = _db.selectOnly(_db.sessions)
      ..addColumns([longest])
      ..where(
        _db.sessions.phase.equals(Phase.approach.storageKey) &
            _db.sessions.outcome.isNotValue(SessionOutcome.abandoned.name),
      );
    final seconds = (await q.getSingleOrNull())?.read(longest) ?? 0;
    return Duration(seconds: seconds);
  }

  /// Approaches (any outcome) per local day for the last [days] days,
  /// oldest first. Days with nothing are present with 0.
  Future<List<DayCount>> approachesPerDay({int days = 14, DateTime? now}) async {
    final today = _dateOnly(now ?? clock.now());
    final start = DateTime(today.year, today.month, today.day - (days - 1));
    final rows = await between(start, DateTime(today.year, today.month, today.day + 1));
    final counts = <DateTime, int>{
      for (var i = 0; i < days; i++) DateTime(start.year, start.month, start.day + i): 0,
    };
    for (final s in rows) {
      if (!s.isApproach) continue;
      final d = _dateOnly(s.endedAt);
      counts[d] = (counts[d] ?? 0) + 1;
    }
    return [for (final e in counts.entries) DayCount(e.key, e.value)];
  }

  /// All approaches on a task, oldest first (for rung progression).
  Future<List<Session>> approachesForTask(String taskId) async {
    final rows = await (_db.select(_db.sessions)
          ..where(
            (s) => s.taskId.equals(taskId) & s.phase.equals(Phase.approach.storageKey),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.endedAt)]))
        .get();
    return rows.map(sessionFromRow).toList();
  }

  /// Best rung per task across all approaches, keyed by task id, measured
  /// against the task's *current* ladder ([ladders], keyed by task id). A
  /// session's rung is located by id; rungs that no longer exist are skipped,
  /// and sessions without a rung id (older rows) use their stored position
  /// clamped to the ladder.
  Future<Map<String, RungProgress>> rungProgressByTask({
    Map<String, List<LadderStep>> ladders = const {},
  }) async {
    final rows = await (_db.select(_db.sessions)
          ..where(
            (s) => s.phase.equals(Phase.approach.storageKey) & s.rungPosition.isNotNull(),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.endedAt)]))
        .get();
    final result = <String, RungProgress>{};
    for (final r in rows) {
      final id = r.taskId;
      if (id == null) continue;
      final session = sessionFromRow(r);
      final resolved = resolveRung(session, ladders[id]);
      if (resolved == null) continue;
      final prev = result[id];
      final best = prev == null || resolved.position > prev.bestRung ? resolved : null;
      result[id] = RungProgress(
        taskId: id,
        taskTitle: r.taskTitle ?? prev?.taskTitle ?? '',
        bestRung: best?.position ?? prev!.bestRung,
        bestRungText: best?.text ?? prev!.bestRungText,
        latestRung: resolved.position,
        attempts: (prev?.attempts ?? 0) + 1,
      );
    }
    return result;
  }

  /// Where a past session's rung sits on the current [ladder]. Null when the
  /// rung is gone (or the ladder is unknown and the session has no position).
  static ResolvedRung? resolveRung(Session session, List<LadderStep>? ladder) {
    if (ladder == null) {
      return session.rungPosition == null
          ? null
          : ResolvedRung(session.rungPosition!, session.rungText ?? '');
    }
    if (session.rungId != null) {
      for (final step in ladder) {
        if (step.id == session.rungId) return ResolvedRung(step.position, step.text);
      }
      return null;
    }
    final stored = session.rungPosition;
    if (stored == null || ladder.isEmpty) return null;
    final clamped = stored.clamp(0, ladder.length - 1);
    return ResolvedRung(clamped, ladder[clamped].text);
  }

  static DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);
}

class ResolvedRung {
  const ResolvedRung(this.position, this.text);
  final int position;
  final String text;
}

class DayCount {
  const DayCount(this.day, this.count);
  final DateTime day;
  final int count;
}

class RungProgress {
  const RungProgress({
    required this.taskId,
    required this.taskTitle,
    required this.bestRung,
    required this.bestRungText,
    required this.latestRung,
    required this.attempts,
  });

  final String taskId;
  final String taskTitle;
  final int bestRung;
  final String bestRungText;
  final int latestRung;
  final int attempts;
}
