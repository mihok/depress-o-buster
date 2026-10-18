import 'package:clock/clock.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/timer/timer_engine.dart';
import '../../domain/xp/levels.dart';
import '../../domain/xp/xp_rules.dart';

/// What happened when an interval was logged: the session, its XP, and
/// whether a level changed. The UI uses it for one calm line of feedback.
@immutable
class LoggedInterval {
  const LoggedInterval({
    required this.session,
    required this.award,
    required this.levelBefore,
    required this.levelAfter,
    required this.totalXp,
    required this.isWelcomeBack,
    required this.isFirstEver,
  });

  final Session session;
  final XpAward award;
  final int levelBefore;
  final int levelAfter;
  final int totalXp;
  final bool isWelcomeBack;
  final bool isFirstEver;

  bool get leveledUp => levelAfter > levelBefore;
}

/// Turns a [PhaseEnded] effect into a saved [Session] plus XP, using the
/// pure rules in [XpRules]. This is the only place that writes progress.
class XpService {
  XpService({
    required SessionRepository sessions,
    required ProgressRepository progress,
    required TaskRepository tasks,
    String Function()? idFactory,
  }) : this._(sessions, progress, tasks, idFactory ?? const Uuid().v4);

  XpService._(this._sessions, this._progress, this._tasks, this._newId);

  final SessionRepository _sessions;
  final ProgressRepository _progress;
  final TaskRepository _tasks;
  final String Function() _newId;

  Future<LoggedInterval> logPhase(PhaseEnded ended, {String? moodBefore}) async {
    final progress = await _progress.get();
    final today = XpRules.dateOnly(ended.endedAt.toLocal());
    final counts = ended.outcome != SessionOutcome.abandoned;
    final everLogged = await _sessions.totalCount() > 0;
    final daysSince = progress.lastActiveDay == null
        ? null
        : XpRules.daysBetween(progress.lastActiveDay!, today);
    final firstToday = counts && (daysSince == null || daysSince > 0);

    // Rung history is compared on the task's current ladder, by rung id, so
    // editing or replacing a ladder cannot hand out or withhold bonuses.
    int? previousMax;
    int? previousRung;
    final taskId = ended.target?.taskId;
    if (ended.phase == Phase.approach && taskId != null) {
      final ladder = await _tasks.ladder(taskId);
      for (final past in await _sessions.approachesForTask(taskId)) {
        final resolved = SessionRepository.resolveRung(past, ladder);
        if (resolved == null) continue;
        previousRung = resolved.position;
        if (previousMax == null || resolved.position > previousMax) {
          previousMax = resolved.position;
        }
      }
    }

    final consistency = counts
        ? XpRules.consistencyForToday(
            current: progress.consistency,
            lastActiveDay: progress.lastActiveDay,
            today: today,
          )
        : progress.consistency;

    final ctx = XpContext(
      firstSessionEver: !everLogged,
      daysSinceLastActive: daysSince,
      firstCompletedToday: firstToday,
      rungAttempted: ended.phase == Phase.approach ? ended.target?.rungPosition : null,
      previousMaxRungOnTask: previousMax,
      previousRungOnTask: previousRung,
      consistency: consistency,
    );
    final award = XpRules.award(
      phase: ended.phase,
      outcome: ended.outcome,
      actual: ended.actual,
      ctx: ctx,
    );

    final session = Session(
      id: _newId(),
      runId: ended.runId,
      taskId: taskId,
      taskTitle: ended.target?.taskTitle,
      rungId: ended.target?.rungId,
      rungPosition: ended.target?.rungPosition,
      rungText: ended.target?.rungText,
      phase: ended.phase,
      planned: ended.planned,
      actual: ended.actual,
      outcome: ended.outcome,
      snoozeCount: ended.snoozeCount,
      startedAt: ended.startedAt,
      endedAt: ended.endedAt,
      moodBefore: moodBefore,
      xpEarned: award.total,
      xpBonuses: award.bonuses.map((b) => b.name).toList(),
    );
    await _sessions.insert(session);

    final totalXp = progress.totalXp + award.total;
    await _progress.save(
      progress.copyWith(
        totalXp: totalXp,
        consistency: consistency,
        lastActiveDay: counts ? today : progress.lastActiveDay,
        totalCompletedIntervals: progress.totalCompletedIntervals + (counts ? 1 : 0),
      ),
    );

    return LoggedInterval(
      session: session,
      award: award,
      levelBefore: Levels.levelFor(progress.totalXp),
      levelAfter: Levels.levelFor(totalXp),
      totalXp: totalXp,
      isWelcomeBack: award.bonuses.contains(XpBonus.welcomeBack),
      isFirstEver: award.bonuses.contains(XpBonus.firstEver),
    );
  }

  /// Days since the last active day, for the "welcome back" line on the
  /// home screen. Null when nothing has ever been logged.
  Future<int?> daysSinceLastActive({DateTime? now}) async {
    final progress = await _progress.get();
    final last = progress.lastActiveDay;
    if (last == null) return null;
    return XpRules.daysBetween(last, XpRules.dateOnly(now ?? clock.now()));
  }
}
