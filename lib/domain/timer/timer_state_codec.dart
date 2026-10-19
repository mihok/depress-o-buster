import '../entities/approach_target.dart';
import '../entities/phase.dart';
import 'timer_engine.dart';

/// JSON round-trip for [TimerState] so a running timer survives process death.
class TimerStateCodec {
  TimerStateCodec._();

  static const int version = 1;

  static Map<String, dynamic> toJson(TimerState s) => {
    'v': version,
    'status': s.status.name,
    'phase': s.phase.name,
    'runId': s.runId,
    'config': configToJson(s.config),
    'target': s.target == null ? null : targetToJson(s.target!),
    'phaseStartedAt': s.phaseStartedAt?.toUtc().toIso8601String(),
    'phaseEndsAt': s.phaseEndsAt?.toUtc().toIso8601String(),
    'plannedMs': s.planned.inMilliseconds,
    'extendedMs': s.extended.inMilliseconds,
    'pausedTotalMs': s.pausedTotal.inMilliseconds,
    'pausedRemainingMs': s.pausedRemaining?.inMilliseconds,
    'pausedAt': s.pausedAt?.toUtc().toIso8601String(),
    'cycleIndex': s.cycleIndex,
    'snoozeCount': s.snoozeCount,
  };

  static TimerState fromJson(Map<String, dynamic> j) {
    final targetJson = j['target'];
    return TimerState(
      status: TimerStatus.values.byName(j['status'] as String),
      phase: Phase.fromStorageKey(j['phase'] as String),
      config: configFromJson(j['config'] as Map<String, dynamic>),
      runId: j['runId'] as String? ?? '',
      target: targetJson is Map<String, dynamic> ? targetFromJson(targetJson) : null,
      phaseStartedAt: _date(j['phaseStartedAt']),
      phaseEndsAt: _date(j['phaseEndsAt']),
      planned: Duration(milliseconds: (j['plannedMs'] as num?)?.toInt() ?? 0),
      extended: Duration(milliseconds: (j['extendedMs'] as num?)?.toInt() ?? 0),
      pausedTotal: Duration(milliseconds: (j['pausedTotalMs'] as num?)?.toInt() ?? 0),
      pausedRemaining: j['pausedRemainingMs'] == null
          ? null
          : Duration(milliseconds: (j['pausedRemainingMs'] as num).toInt()),
      pausedAt: _date(j['pausedAt']),
      cycleIndex: (j['cycleIndex'] as num?)?.toInt() ?? 0,
      snoozeCount: (j['snoozeCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, dynamic> configToJson(TimerConfig c) => {
    'approachMs': c.approach.inMilliseconds,
    'restMs': c.rest.inMilliseconds,
    'longRestMs': c.longRest?.inMilliseconds,
    'cyclesBeforeLongRest': c.cyclesBeforeLongRest,
    'snoozeByMs': c.snoozeBy.inMilliseconds,
    'restFirst': c.restFirst,
    'autoStartNext': c.autoStartNext,
  };

  static TimerConfig configFromJson(Map<String, dynamic> j) => TimerConfig(
    approach: Duration(milliseconds: (j['approachMs'] as num).toInt()),
    rest: Duration(milliseconds: (j['restMs'] as num).toInt()),
    longRest: j['longRestMs'] == null
        ? null
        : Duration(milliseconds: (j['longRestMs'] as num).toInt()),
    cyclesBeforeLongRest: (j['cyclesBeforeLongRest'] as num?)?.toInt() ?? 0,
    snoozeBy: Duration(
      milliseconds: (j['snoozeByMs'] as num?)?.toInt() ?? 120000,
    ),
    // Timers saved before rest-first existed ran approach first.
    restFirst: j['restFirst'] as bool? ?? false,
    autoStartNext: j['autoStartNext'] as bool? ?? j['autoStartRest'] as bool? ?? true,
  );

  static Map<String, dynamic> targetToJson(ApproachTarget t) => {
    'taskId': t.taskId,
    'taskTitle': t.taskTitle,
    'rungId': t.rungId,
    'rungPosition': t.rungPosition,
    'rungText': t.rungText,
  };

  static ApproachTarget targetFromJson(Map<String, dynamic> j) => ApproachTarget(
    taskId: j['taskId'] as String?,
    taskTitle: j['taskTitle'] as String?,
    rungId: j['rungId'] as String?,
    rungPosition: (j['rungPosition'] as num?)?.toInt(),
    rungText: j['rungText'] as String?,
  );

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.parse(v).toLocal() : null;
}
