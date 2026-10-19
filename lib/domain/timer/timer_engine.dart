import 'package:meta/meta.dart';

import '../entities/approach_target.dart';
import '../entities/phase.dart';
import '../entities/session.dart';

/// Pure, testable timer state machine. No Flutter, no plugins, no `Timer`.
///
/// `reduce(state, event)` returns the next state plus a list of effects the
/// outside world should perform (schedule an alarm, log a session, ...).
/// Remaining time is always derived from the wall clock (`phaseEndsAt - now`),
/// so backgrounding, process death and late ticks never drift the timer.
class TimerEngine {
  const TimerEngine();

  TimerTransition reduce(TimerState state, TimerEvent event) {
    return switch (event) {
      StartTimer e => _start(state, e),
      Tick e => _tick(state, e),
      PauseTimer e => _pause(state, e),
      ResumeTimer e => _resume(state, e),
      Snooze e => _snooze(state, e),
      FinishEarly e => _finishEarly(state, e),
      AbandonTimer e => _abandon(state, e),
      ResetTimer e => _reset(state, e),
      UpdateConfig e => TimerTransition(state.copyWith(config: e.config), const []),
    };
  }

  TimerTransition _start(TimerState s, StartTimer e) {
    if (s.status == TimerStatus.running || s.status == TimerStatus.paused) {
      return TimerTransition(s, const []);
    }
    final config = e.config ?? s.config;
    final cycleIndex = s.status == TimerStatus.finished ? s.cycleIndex : 0;
    // No phase: a new round, which opens with the rest when the config says
    // so (time to get ready) and with the approach otherwise. A rest started
    // by hand (autoStartNext off) still honours the long rest.
    final phase = switch (e.phase) {
      null => config.restFirst ? restPhaseFor(config, cycleIndex) : Phase.approach,
      Phase.approach => Phase.approach,
      Phase.longRest => Phase.longRest,
      Phase.rest => restPhaseFor(config, cycleIndex),
    };
    final planned = config.durationFor(phase);
    final endsAt = e.now.add(planned);
    // A new round or an explicit approach takes the target as given; a rest
    // started by hand after an approach keeps that approach's target.
    final target = e.phase == null || e.phase == Phase.approach ? e.target : (e.target ?? s.target);
    // The mood belongs to the round: set with a new round, kept by a phase
    // started by hand inside it.
    final mood = e.phase == null ? e.moodBefore : s.moodBefore;
    final next = s.copyWith(
      status: TimerStatus.running,
      phase: phase,
      config: config,
      target: target,
      clearTarget: target == null,
      moodBefore: mood,
      clearMoodBefore: mood == null,
      runId: e.runId,
      phaseStartedAt: e.now,
      phaseEndsAt: endsAt,
      planned: planned,
      extended: Duration.zero,
      pausedTotal: Duration.zero,
      clearPaused: true,
      snoozeCount: 0,
      cycleIndex: cycleIndex,
    );
    return TimerTransition(next, [
      const CancelAlarms(),
      _alarmFor(next),
      ..._followingAlarm(next),
      _ongoingFor(next),
      const PlaySound(SoundKind.start, alarmAlreadyFired: false),
    ]);
  }

  /// The alarm for the current phase, told what happens when it fires so the
  /// notification can say so ("time for the step" rather than "ready when
  /// you are").
  ScheduleAlarm _alarmFor(TimerState s) => ScheduleAlarm(
    phase: s.phase,
    at: s.phaseEndsAt!,
    target: s.target,
    next: followingPhase(s),
    preparing: s.isPreparing,
  );

  /// The live countdown for the current phase. While paused the countdown
  /// is frozen and no following phase is announced.
  ShowOngoing _ongoingFor(TimerState s, {DateTime? pausedAt}) {
    DateTime? nextEndsAt;
    Phase? nextPhase;
    if (pausedAt == null) {
      nextPhase = followingPhase(s);
      if (nextPhase != null) {
        nextEndsAt = s.phaseEndsAt!.add(s.config.durationFor(nextPhase));
      }
    }
    return ShowOngoing(
      runId: s.runId,
      phase: s.phase,
      endsAt: s.phaseEndsAt!,
      target: s.target,
      nextEndsAt: nextEndsAt,
      nextPhase: nextPhase,
      pausedAt: pausedAt,
      preparing: s.isPreparing,
    );
  }

  /// The alarm for the phase that follows automatically is scheduled
  /// together with the current phase's alarm, so its end is signalled even
  /// when the app process is suspended or dead at the moment the current
  /// phase ends. Re-scheduling the same alarm id later (when the phase
  /// actually ends) is harmless.
  List<TimerEffect> _followingAlarm(TimerState s) {
    final next = followingPhase(s);
    if (next == null) return const [];
    final at = s.phaseEndsAt!.add(s.config.durationFor(next));
    return [ScheduleAlarm(phase: next, at: at, target: s.target)];
  }

  /// The phase that begins on its own when the current one ends, or null
  /// when the run ends there (or the next phase is started by hand).
  ///
  /// Rest first: a rest is followed by the approach it prepares for, and the
  /// approach closes the round. Approach first: the approach is followed by
  /// its rest, which closes the round.
  static Phase? followingPhase(TimerState s) {
    if (!s.config.autoStartNext) return null;
    if (s.phase == Phase.approach) {
      return s.config.restFirst ? null : restPhaseFor(s.config, s.cycleIndex + 1);
    }
    return s.config.restFirst ? Phase.approach : null;
  }

  TimerTransition _tick(TimerState s, Tick e) {
    if (s.status != TimerStatus.running) return TimerTransition(s, const []);
    final endsAt = s.phaseEndsAt!;
    if (e.now.isBefore(endsAt)) return TimerTransition(s, const []);
    final outcome = s.snoozeCount > 0 ? SessionOutcome.snoozed : SessionOutcome.completed;
    // The phase ended at endsAt even if this tick arrives late (app resumed).
    return _endPhase(s, endedAt: endsAt, outcome: outcome, auto: true);
  }

  TimerTransition _pause(TimerState s, PauseTimer e) {
    if (s.status != TimerStatus.running) return TimerTransition(s, const []);
    final remaining = _clamp(s.phaseEndsAt!.difference(e.now));
    final next = s.copyWith(
      status: TimerStatus.paused,
      pausedRemaining: remaining,
      pausedAt: e.now,
    );
    // The live countdown stays, frozen, so the lock screen does not go blank.
    return TimerTransition(next, [const CancelAlarms(), _ongoingFor(next, pausedAt: e.now)]);
  }

  TimerTransition _resume(TimerState s, ResumeTimer e) {
    if (s.status != TimerStatus.paused) return TimerTransition(s, const []);
    final remaining = s.pausedRemaining ?? Duration.zero;
    final endsAt = e.now.add(remaining);
    final pausedFor = _clamp(e.now.difference(s.pausedAt ?? e.now));
    final next = s.copyWith(
      status: TimerStatus.running,
      phaseEndsAt: endsAt,
      pausedTotal: s.pausedTotal + pausedFor,
      clearPaused: true,
    );
    return TimerTransition(next, [
      _alarmFor(next),
      ..._followingAlarm(next),
      _ongoingFor(next),
    ]);
  }

  /// Extend the current phase: the approach, or the rest that prepares for
  /// it ("I need a little longer to get ready"). A rest that follows an
  /// approach is not extended this way; it is simply rest.
  TimerTransition _snooze(TimerState s, Snooze e) {
    if (s.phase != Phase.approach && !s.config.restFirst) return TimerTransition(s, const []);
    final by = e.by ?? s.config.snoozeBy;
    if (s.status == TimerStatus.paused) {
      return TimerTransition(
        s.copyWith(
          pausedRemaining: (s.pausedRemaining ?? Duration.zero) + by,
          extended: s.extended + by,
          snoozeCount: s.snoozeCount + 1,
        ),
        const [],
      );
    }
    if (s.status != TimerStatus.running) return TimerTransition(s, const []);
    final endsAt = s.phaseEndsAt!.add(by);
    final next = s.copyWith(
      phaseEndsAt: endsAt,
      extended: s.extended + by,
      snoozeCount: s.snoozeCount + 1,
    );
    return TimerTransition(next, [
      const CancelAlarms(),
      _alarmFor(next),
      ..._followingAlarm(next),
      _ongoingFor(next),
    ]);
  }

  TimerTransition _finishEarly(TimerState s, FinishEarly e) {
    if (s.status != TimerStatus.running && s.status != TimerStatus.paused) {
      return TimerTransition(s, const []);
    }
    final outcome = s.snoozeCount > 0 ? SessionOutcome.snoozed : SessionOutcome.completed;
    return _endPhase(_settlePause(s, e.now), endedAt: e.now, outcome: outcome, auto: false);
  }

  TimerTransition _abandon(TimerState s, AbandonTimer e) {
    if (s.status != TimerStatus.running && s.status != TimerStatus.paused) {
      return TimerTransition(s, const []);
    }
    return _endPhase(
      _settlePause(s, e.now),
      endedAt: e.now,
      outcome: SessionOutcome.abandoned,
      auto: false,
    );
  }

  TimerTransition _reset(TimerState s, ResetTimer e) {
    return TimerTransition(
      TimerState.idle(s.config, target: s.target),
      const [CancelAlarms(), HideOngoing()],
    );
  }

  /// If paused, fold the current pause into [pausedTotal] so `actual` is right.
  TimerState _settlePause(TimerState s, DateTime now) {
    if (s.status != TimerStatus.paused) return s;
    final pausedFor = _clamp(now.difference(s.pausedAt ?? now));
    return s.copyWith(pausedTotal: s.pausedTotal + pausedFor, clearPaused: true);
  }

  TimerTransition _endPhase(
    TimerState s, {
    required DateTime endedAt,
    required SessionOutcome outcome,
    required bool auto,
  }) {
    final startedAt = s.phaseStartedAt ?? endedAt;
    final actual = _clamp(endedAt.difference(startedAt) - s.pausedTotal);
    final isApproach = s.phase == Phase.approach;
    final cycleIndex = isApproach && outcome != SessionOutcome.abandoned
        ? s.cycleIndex + 1
        : s.cycleIndex;

    final ended = PhaseEnded(
      runId: s.runId,
      phase: s.phase,
      target: s.target,
      planned: s.planned,
      actual: actual,
      extended: s.extended,
      snoozeCount: s.snoozeCount,
      outcome: outcome,
      startedAt: startedAt,
      endedAt: endedAt,
      auto: auto,
      cycleIndex: cycleIndex,
      moodBefore: isApproach ? s.moodBefore : null,
    );
    final sound = PlaySound(
      isApproach ? SoundKind.approachDone : SoundKind.restDone,
      alarmAlreadyFired: auto,
    );

    if (outcome == SessionOutcome.abandoned) {
      return TimerTransition(
        TimerState.idle(s.config, target: s.target),
        [const CancelAlarms(), const HideOngoing(), ended],
      );
    }

    // Ending the rest before a step by hand means "I am ready now": the step
    // starts at once, whatever the automatic-start setting says.
    final following = !auto && s.isPreparing ? Phase.approach : followingPhase(s);
    if (following != null) {
      final planned = s.config.durationFor(following);
      final nextEndsAt = endedAt.add(planned);
      final next = s.copyWith(
        status: TimerStatus.running,
        phase: following,
        phaseStartedAt: endedAt,
        phaseEndsAt: nextEndsAt,
        planned: planned,
        extended: Duration.zero,
        pausedTotal: Duration.zero,
        clearPaused: true,
        snoozeCount: 0,
        cycleIndex: cycleIndex,
      );
      return TimerTransition(next, [
        const CancelAlarms(),
        ended,
        sound,
        _alarmFor(next),
        ..._followingAlarm(next),
        _ongoingFor(next),
      ]);
    }

    final finished = s.copyWith(
      status: TimerStatus.finished,
      phaseStartedAt: startedAt,
      phaseEndsAt: endedAt,
      pausedTotal: Duration.zero,
      clearPaused: true,
      cycleIndex: cycleIndex,
    );
    return TimerTransition(finished, [
      const CancelAlarms(),
      const HideOngoing(),
      ended,
      sound,
    ]);
  }

  /// Which rest comes after [completedApproaches] approaches: the one that
  /// follows the last of them, or (rest first) the one that opens the next
  /// round. The long rest is due after every [TimerConfig.cyclesBeforeLongRest]
  /// completed approaches, never before the first.
  static Phase restPhaseFor(TimerConfig config, int completedApproaches) {
    final n = config.cyclesBeforeLongRest;
    if (n > 0 &&
        config.longRest != null &&
        completedApproaches > 0 &&
        completedApproaches % n == 0) {
      return Phase.longRest;
    }
    return Phase.rest;
  }

  static Duration _clamp(Duration d) => d.isNegative ? Duration.zero : d;
}

enum TimerStatus { idle, running, paused, finished }

enum SoundKind { start, approachDone, restDone }

@immutable
class TimerConfig {
  const TimerConfig({
    required this.approach,
    required this.rest,
    this.longRest,
    this.cyclesBeforeLongRest = 0,
    this.snoozeBy = const Duration(minutes: 2),
    this.restFirst = true,
    this.autoStartNext = true,
  });

  final Duration approach;
  final Duration rest;
  final Duration? longRest;

  /// After this many completed approaches, use [longRest]. 0 disables it.
  final int cyclesBeforeLongRest;
  final Duration snoozeBy;

  /// A round opens with the rest, then the approach: time to get ready
  /// before the step, instead of having to do it the moment it is planned.
  /// Off: the approach comes first and the rest follows it.
  final bool restFirst;

  /// Start the phase that follows (the approach after its rest, or the rest
  /// after its approach) the moment the current one completes. Off: it is
  /// started by hand.
  final bool autoStartNext;

  Duration durationFor(Phase phase) => switch (phase) {
    Phase.approach => approach,
    Phase.rest => rest,
    Phase.longRest => longRest ?? rest,
  };

  TimerConfig copyWith({
    Duration? approach,
    Duration? rest,
    Duration? longRest,
    bool clearLongRest = false,
    int? cyclesBeforeLongRest,
    Duration? snoozeBy,
    bool? restFirst,
    bool? autoStartNext,
  }) {
    return TimerConfig(
      approach: approach ?? this.approach,
      rest: rest ?? this.rest,
      longRest: clearLongRest ? null : (longRest ?? this.longRest),
      cyclesBeforeLongRest: cyclesBeforeLongRest ?? this.cyclesBeforeLongRest,
      snoozeBy: snoozeBy ?? this.snoozeBy,
      restFirst: restFirst ?? this.restFirst,
      autoStartNext: autoStartNext ?? this.autoStartNext,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TimerConfig &&
      other.approach == approach &&
      other.rest == rest &&
      other.longRest == longRest &&
      other.cyclesBeforeLongRest == cyclesBeforeLongRest &&
      other.snoozeBy == snoozeBy &&
      other.restFirst == restFirst &&
      other.autoStartNext == autoStartNext;

  @override
  int get hashCode => Object.hash(
    approach,
    rest,
    longRest,
    cyclesBeforeLongRest,
    snoozeBy,
    restFirst,
    autoStartNext,
  );
}

@immutable
class TimerState {
  const TimerState({
    required this.status,
    required this.phase,
    required this.config,
    required this.runId,
    this.target,
    this.phaseStartedAt,
    this.phaseEndsAt,
    this.planned = Duration.zero,
    this.extended = Duration.zero,
    this.pausedTotal = Duration.zero,
    this.pausedRemaining,
    this.pausedAt,
    this.cycleIndex = 0,
    this.snoozeCount = 0,
    this.moodBefore,
  });

  factory TimerState.idle(TimerConfig config, {ApproachTarget? target}) =>
      TimerState(
        status: TimerStatus.idle,
        phase: Phase.approach,
        config: config,
        runId: '',
        target: target,
        planned: config.approach,
      );

  final TimerStatus status;
  final Phase phase;
  final TimerConfig config;
  final ApproachTarget? target;
  final String runId;
  final DateTime? phaseStartedAt;
  final DateTime? phaseEndsAt;

  /// Planned length of the current phase, before snoozes.
  final Duration planned;

  /// Total snooze extension applied to the current phase.
  final Duration extended;

  /// Total time spent paused during the current phase.
  final Duration pausedTotal;
  final Duration? pausedRemaining;
  final DateTime? pausedAt;

  /// Approaches completed in this run (drives the long rest).
  final int cycleIndex;
  final int snoozeCount;

  /// The optional one-word mood given when the round started. It rides in
  /// the state (and so survives process death) until the approach is logged.
  final String? moodBefore;

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isActive => isRunning || isPaused;
  bool get isApproach => phase == Phase.approach;

  /// A rest that prepares for the approach (rest first), as opposed to the
  /// rest that follows one.
  bool get isPreparing => phase.isRest && config.restFirst;

  Duration get plannedWithExtensions => planned + extended;

  Duration remaining(DateTime now) => switch (status) {
    TimerStatus.running => _clamp(phaseEndsAt!.difference(now)),
    TimerStatus.paused => pausedRemaining ?? Duration.zero,
    TimerStatus.idle => config.durationFor(phase),
    TimerStatus.finished => Duration.zero,
  };

  Duration elapsed(DateTime now) => switch (status) {
    TimerStatus.running || TimerStatus.paused =>
      _clamp(plannedWithExtensions - remaining(now)),
    TimerStatus.idle => Duration.zero,
    TimerStatus.finished => plannedWithExtensions,
  };

  /// 0.0 at the start of the phase, 1.0 at the end.
  double progress(DateTime now) {
    final total = plannedWithExtensions.inMilliseconds;
    if (total <= 0) return status == TimerStatus.finished ? 1 : 0;
    return (elapsed(now).inMilliseconds / total).clamp(0.0, 1.0);
  }

  TimerState copyWith({
    TimerStatus? status,
    Phase? phase,
    TimerConfig? config,
    ApproachTarget? target,
    bool clearTarget = false,
    String? runId,
    DateTime? phaseStartedAt,
    DateTime? phaseEndsAt,
    Duration? planned,
    Duration? extended,
    Duration? pausedTotal,
    Duration? pausedRemaining,
    DateTime? pausedAt,
    bool clearPaused = false,
    int? cycleIndex,
    int? snoozeCount,
    String? moodBefore,
    bool clearMoodBefore = false,
  }) {
    return TimerState(
      status: status ?? this.status,
      phase: phase ?? this.phase,
      config: config ?? this.config,
      target: clearTarget ? null : (target ?? this.target),
      runId: runId ?? this.runId,
      phaseStartedAt: phaseStartedAt ?? this.phaseStartedAt,
      phaseEndsAt: phaseEndsAt ?? this.phaseEndsAt,
      planned: planned ?? this.planned,
      extended: extended ?? this.extended,
      pausedTotal: pausedTotal ?? this.pausedTotal,
      pausedRemaining: clearPaused ? null : (pausedRemaining ?? this.pausedRemaining),
      pausedAt: clearPaused ? null : (pausedAt ?? this.pausedAt),
      cycleIndex: cycleIndex ?? this.cycleIndex,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      moodBefore: clearMoodBefore ? null : (moodBefore ?? this.moodBefore),
    );
  }

  static Duration _clamp(Duration d) => d.isNegative ? Duration.zero : d;

  @override
  String toString() =>
      'TimerState(${status.name} ${phase.name} ends=$phaseEndsAt cycle=$cycleIndex snoozes=$snoozeCount)';
}

@immutable
class TimerTransition {
  const TimerTransition(this.state, this.effects);
  final TimerState state;
  final List<TimerEffect> effects;
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class TimerEvent {
  const TimerEvent(this.now);
  final DateTime now;
}

/// Start a round ([phase] null: the config decides whether it opens with the
/// rest or the approach), or one specific phase by hand.
final class StartTimer extends TimerEvent {
  const StartTimer(
    super.now, {
    required this.runId,
    this.phase,
    this.target,
    this.config,
    this.moodBefore,
  });
  final String runId;
  final Phase? phase;
  final ApproachTarget? target;
  final TimerConfig? config;

  /// One optional word about how the person feels, for the round's approach.
  final String? moodBefore;
}

final class Tick extends TimerEvent {
  const Tick(super.now);
}

final class PauseTimer extends TimerEvent {
  const PauseTimer(super.now);
}

final class ResumeTimer extends TimerEvent {
  const ResumeTimer(super.now);
}

/// Extend the current approach, or the rest that prepares for it. Never a
/// penalty.
final class Snooze extends TimerEvent {
  const Snooze(super.now, {this.by});
  final Duration? by;
}

/// "I'm done with this phase" (also used to end a rest early). Counts as completed.
final class FinishEarly extends TimerEvent {
  const FinishEarly(super.now);
}

/// Stop the run. Logged neutrally; still earns XP for starting.
final class AbandonTimer extends TimerEvent {
  const AbandonTimer(super.now);
}

final class ResetTimer extends TimerEvent {
  const ResetTimer(super.now);
}

final class UpdateConfig extends TimerEvent {
  const UpdateConfig(super.now, this.config);
  final TimerConfig config;
}

// ---------------------------------------------------------------------------
// Effects
// ---------------------------------------------------------------------------

sealed class TimerEffect {
  const TimerEffect();
}

/// Schedule the "phase over" alarm. [next] is the phase that begins on its
/// own when it fires (null when the run waits or ends there) and
/// [preparing] says the rest is the one before a step, so the notification
/// can say what actually happens.
final class ScheduleAlarm extends TimerEffect {
  const ScheduleAlarm({
    required this.phase,
    required this.at,
    this.target,
    this.next,
    this.preparing = false,
  });
  final Phase phase;
  final DateTime at;
  final ApproachTarget? target;
  final Phase? next;
  final bool preparing;
}

final class CancelAlarms extends TimerEffect {
  const CancelAlarms();
}

/// Show (or update) the live countdown: an ongoing notification on Android,
/// a Live Activity on iOS. [nextPhase] and [nextEndsAt] are set when another
/// phase will follow automatically, so a lock-screen view can switch to it
/// on its own if the app is suspended when the current phase ends.
final class ShowOngoing extends TimerEffect {
  const ShowOngoing({
    required this.runId,
    required this.phase,
    required this.endsAt,
    this.target,
    this.nextEndsAt,
    this.nextPhase,
    this.pausedAt,
    this.preparing = false,
  });
  final String runId;
  final Phase phase;
  final DateTime endsAt;
  final ApproachTarget? target;
  final DateTime? nextEndsAt;

  /// The rest before a step (so the countdown can name the step even when
  /// it is started by hand).
  final bool preparing;

  /// The phase that follows on its own, when [nextEndsAt] is set.
  final Phase? nextPhase;

  /// Set while paused: the countdown is frozen at `endsAt - pausedAt`.
  final DateTime? pausedAt;
}

final class HideOngoing extends TimerEffect {
  const HideOngoing();
}

final class PlaySound extends TimerEffect {
  const PlaySound(this.kind, {required this.alarmAlreadyFired});
  final SoundKind kind;

  /// True when the OS alarm for this moment has already fired (the phase ended
  /// on its own), so the in-app sound should only be a fallback.
  final bool alarmAlreadyFired;
}

/// Everything needed to log a [Session] for the phase that just ended.
final class PhaseEnded extends TimerEffect {
  const PhaseEnded({
    required this.runId,
    required this.phase,
    required this.planned,
    required this.actual,
    required this.extended,
    required this.snoozeCount,
    required this.outcome,
    required this.startedAt,
    required this.endedAt,
    required this.auto,
    required this.cycleIndex,
    this.target,
    this.moodBefore,
  });

  final String runId;
  final Phase phase;
  final ApproachTarget? target;

  /// The mood given at the start of the round; only on an approach.
  final String? moodBefore;
  final Duration planned;
  final Duration actual;
  final Duration extended;
  final int snoozeCount;
  final SessionOutcome outcome;
  final DateTime startedAt;
  final DateTime endedAt;

  /// True when the phase ended because its time ran out.
  final bool auto;
  final int cycleIndex;

  @override
  String toString() =>
      'PhaseEnded(${phase.name} ${outcome.name} ${actual.inSeconds}s of ${planned.inSeconds}s)';
}
