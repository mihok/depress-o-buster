import 'package:depress_o_buster/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = TimerEngine();
  final t0 = DateTime(2026, 10, 18, 9);
  const config = TimerConfig(restFirst: false, 
    approach: Duration(minutes: 5),
    rest: Duration(minutes: 30),
    snoozeBy: Duration(minutes: 2),
  );
  const target = ApproachTarget(
    taskId: 't1',
    taskTitle: 'Laundry',
    rungPosition: 4,
    rungText: 'Sit next to the pile for 5 minutes',
  );

  TimerTransition start(
    TimerState s,
    DateTime now, {
    Phase? phase,
    TimerConfig? cfg,
    ApproachTarget? tgt = target,
    String runId = 'run-1',
  }) =>
      engine.reduce(s, StartTimer(now, runId: runId, phase: phase, config: cfg, target: tgt));

  TimerState running(DateTime now, {TimerConfig cfg = config}) =>
      start(TimerState.idle(cfg), now, cfg: cfg).state;

  T single<T extends TimerEffect>(TimerTransition tr) => tr.effects.whereType<T>().single;
  bool has<T extends TimerEffect>(TimerTransition tr) => tr.effects.whereType<T>().isNotEmpty;
  List<ScheduleAlarm> alarms(TimerTransition tr) => tr.effects.whereType<ScheduleAlarm>().toList();

  group('start', () {
    test('from idle starts an approach and schedules its alarm', () {
      final tr = start(TimerState.idle(config), t0);
      final s = tr.state;
      expect(s.status, TimerStatus.running);
      expect(s.phase, Phase.approach);
      expect(s.phaseStartedAt, t0);
      expect(s.phaseEndsAt, t0.add(const Duration(minutes: 5)));
      expect(s.planned, const Duration(minutes: 5));
      expect(s.runId, 'run-1');
      expect(s.target, target);
      expect(s.cycleIndex, 0);
      expect(has<CancelAlarms>(tr), isTrue);
      final scheduled = alarms(tr);
      expect(scheduled.map((a) => a.phase), [Phase.approach, Phase.rest]);
      expect(scheduled[0].at, t0.add(const Duration(minutes: 5)));
      expect(scheduled[0].target, target);
      expect(
        scheduled[1].at,
        t0.add(const Duration(minutes: 35)),
        reason: 'the rest alarm is scheduled up front so it fires even if the app is dead',
      );
      expect(scheduled[1].target, target);
      final ongoing = single<ShowOngoing>(tr);
      expect(ongoing.endsAt, scheduled[0].at);
      expect(ongoing.runId, 'run-1');
      expect(ongoing.phase, Phase.approach);
      expect(ongoing.nextEndsAt, t0.add(const Duration(minutes: 35)), reason: 'a lock-screen view can switch to the rest by itself');
      expect(ongoing.nextPhase, Phase.rest);
      expect(ongoing.pausedAt, isNull);
      expect(single<PlaySound>(tr).kind, SoundKind.start);
      expect(has<PhaseEnded>(tr), isFalse);
    });

    test('30-second approaches are valid, there is no lower bound', () {
      const tiny = TimerConfig(restFirst: false, approach: Duration(seconds: 30), rest: Duration(minutes: 1));
      final tr = start(TimerState.idle(tiny), t0, cfg: tiny);
      expect(tr.state.phaseEndsAt, t0.add(const Duration(seconds: 30)));
      final done = engine.reduce(tr.state, Tick(t0.add(const Duration(seconds: 30))));
      expect(single<PhaseEnded>(done).actual, const Duration(seconds: 30));
    });

    test('with no target works ("just sit up")', () {
      final tr = start(TimerState.idle(config), t0, tgt: null);
      expect(tr.state.target, isNull);
      expect(tr.state.status, TimerStatus.running);
    });

    test('is ignored while running or paused', () {
      final s = running(t0);
      final again = start(s, t0.add(const Duration(minutes: 1)), runId: 'run-2');
      expect(again.state, same(s));
      expect(again.effects, isEmpty);
      final paused = engine.reduce(s, PauseTimer(t0.add(const Duration(minutes: 1)))).state;
      expect(start(paused, t0.add(const Duration(minutes: 2))).state, same(paused));
    });

    test('from finished keeps the cycle index and uses the new run id', () {
      var tr = engine.reduce(running(t0), Tick(t0.add(const Duration(minutes: 5))));
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 35))));
      expect(tr.state.status, TimerStatus.finished);
      expect(tr.state.cycleIndex, 1);
      final next = start(tr.state, t0.add(const Duration(minutes: 40)), runId: 'run-2');
      expect(next.state.cycleIndex, 1);
      expect(next.state.runId, 'run-2');
      expect(next.state.phase, Phase.approach);
      expect(next.state.snoozeCount, 0);
      expect(next.state.extended, Duration.zero);
    });
  });

  group('tick', () {
    test('before the end changes nothing', () {
      final s = running(t0);
      final tr = engine.reduce(s, Tick(t0.add(const Duration(minutes: 4, seconds: 59))));
      expect(tr.state, same(s));
      expect(tr.effects, isEmpty);
    });

    test('at the end completes the approach and auto-starts rest', () {
      final s = running(t0);
      final end = t0.add(const Duration(minutes: 5));
      final tr = engine.reduce(s, Tick(end));
      expect(tr.state.status, TimerStatus.running);
      expect(tr.state.phase, Phase.rest);
      expect(tr.state.phaseStartedAt, end);
      expect(tr.state.phaseEndsAt, end.add(const Duration(minutes: 30)));
      expect(tr.state.planned, const Duration(minutes: 30));
      expect(tr.state.cycleIndex, 1);
      expect(tr.state.target, target, reason: 'rest keeps the context of the approach');
      final ended = single<PhaseEnded>(tr);
      expect(ended.phase, Phase.approach);
      expect(ended.outcome, SessionOutcome.completed);
      expect(ended.actual, const Duration(minutes: 5));
      expect(ended.planned, const Duration(minutes: 5));
      expect(ended.auto, isTrue);
      expect(ended.target, target);
      expect(ended.runId, 'run-1');
      expect(ended.cycleIndex, 1);
      final alarm = single<ScheduleAlarm>(tr);
      expect(alarm.phase, Phase.rest);
      expect(alarm.at, end.add(const Duration(minutes: 30)));
      final ongoing = single<ShowOngoing>(tr);
      expect(ongoing.phase, Phase.rest);
      expect(ongoing.nextEndsAt, isNull);
      expect(ongoing.runId, 'run-1');
      final sound = single<PlaySound>(tr);
      expect(sound.kind, SoundKind.approachDone);
      expect(sound.alarmAlreadyFired, isTrue);
      expect(has<CancelAlarms>(tr), isTrue);
    });

    test('a late tick (app resumed) ends the phase at its scheduled end, not now', () {
      final s = running(t0);
      final late = t0.add(const Duration(minutes: 12));
      final tr = engine.reduce(s, Tick(late));
      final ended = single<PhaseEnded>(tr);
      expect(ended.endedAt, t0.add(const Duration(minutes: 5)));
      expect(ended.actual, const Duration(minutes: 5));
      expect(tr.state.phase, Phase.rest);
      expect(tr.state.phaseStartedAt, t0.add(const Duration(minutes: 5)));
      expect(tr.state.phaseEndsAt, t0.add(const Duration(minutes: 35)));
      expect(tr.state.remaining(late), const Duration(minutes: 23));
    });

    test('a second late tick completes the rest at its own scheduled end', () {
      final s = running(t0);
      final much = t0.add(const Duration(hours: 2));
      final tr = engine.reduce(s, Tick(much));
      final tr2 = engine.reduce(tr.state, Tick(much));
      expect(tr2.state.status, TimerStatus.finished);
      expect(tr2.state.phase, Phase.rest);
      final ended = single<PhaseEnded>(tr2);
      expect(ended.phase, Phase.rest);
      expect(ended.endedAt, t0.add(const Duration(minutes: 35)));
      expect(ended.actual, const Duration(minutes: 30));
      expect(ended.outcome, SessionOutcome.completed);
      expect(has<HideOngoing>(tr2), isTrue);
      expect(has<CancelAlarms>(tr2), isTrue);
      expect(has<ScheduleAlarm>(tr2), isFalse);
      expect(single<PlaySound>(tr2).kind, SoundKind.restDone);
    });

    test('is ignored when idle, paused or finished', () {
      final idle = TimerState.idle(config);
      expect(engine.reduce(idle, Tick(t0)).effects, isEmpty);
      final paused = engine.reduce(running(t0), PauseTimer(t0)).state;
      expect(engine.reduce(paused, Tick(t0.add(const Duration(hours: 1)))).effects, isEmpty);
      var tr = engine.reduce(running(t0), Tick(t0.add(const Duration(minutes: 5))));
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 35))));
      expect(engine.reduce(tr.state, Tick(t0.add(const Duration(hours: 1)))).effects, isEmpty);
    });
  });

  group('snooze', () {
    test('extends the approach and reschedules, no penalty', () {
      final s = running(t0);
      final tr = engine.reduce(s, Snooze(t0.add(const Duration(minutes: 4))));
      expect(tr.state.status, TimerStatus.running);
      expect(tr.state.phaseEndsAt, t0.add(const Duration(minutes: 7)));
      expect(tr.state.extended, const Duration(minutes: 2));
      expect(tr.state.snoozeCount, 1);
      expect(tr.state.planned, const Duration(minutes: 5));
      expect(has<CancelAlarms>(tr), isTrue);
      expect(
        alarms(tr).map((a) => a.at),
        [t0.add(const Duration(minutes: 7)), t0.add(const Duration(minutes: 37))],
        reason: 'both the approach and the pre-scheduled rest alarm move',
      );
      expect(single<ShowOngoing>(tr).endsAt, t0.add(const Duration(minutes: 7)));
      expect(has<PhaseEnded>(tr), isFalse);

      final done = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 7))));
      final ended = single<PhaseEnded>(done);
      expect(ended.outcome, SessionOutcome.snoozed);
      expect(ended.actual, const Duration(minutes: 7));
      expect(ended.planned, const Duration(minutes: 5));
      expect(ended.extended, const Duration(minutes: 2));
      expect(ended.snoozeCount, 1);
    });

    test('accepts a custom amount and stacks', () {
      var tr = engine.reduce(running(t0), Snooze(t0, by: const Duration(seconds: 30)));
      tr = engine.reduce(tr.state, Snooze(t0, by: const Duration(seconds: 30)));
      expect(tr.state.phaseEndsAt, t0.add(const Duration(minutes: 6)));
      expect(tr.state.snoozeCount, 2);
      expect(tr.state.extended, const Duration(minutes: 1));
    });

    test('is ignored during rest', () {
      final rest = engine.reduce(running(t0), Tick(t0.add(const Duration(minutes: 5)))).state;
      final tr = engine.reduce(rest, Snooze(t0.add(const Duration(minutes: 6))));
      expect(tr.state, same(rest), reason: 'a rest after the approach is simply rest');
      expect(tr.effects, isEmpty);
    });

    test('while paused adds to the remaining time', () {
      final paused = engine.reduce(running(t0), PauseTimer(t0.add(const Duration(minutes: 1)))).state;
      final tr = engine.reduce(paused, Snooze(t0.add(const Duration(minutes: 2))));
      expect(tr.state.status, TimerStatus.paused);
      expect(tr.state.pausedRemaining, const Duration(minutes: 6));
      expect(tr.state.snoozeCount, 1);
      expect(tr.effects, isEmpty);
    });
  });

  group('pause and resume', () {
    test('pause captures the remaining time and cancels alarms', () {
      final s = running(t0);
      final tr = engine.reduce(s, PauseTimer(t0.add(const Duration(minutes: 2))));
      expect(tr.state.status, TimerStatus.paused);
      expect(tr.state.pausedRemaining, const Duration(minutes: 3));
      expect(tr.state.remaining(t0.add(const Duration(minutes: 10))), const Duration(minutes: 3));
      expect(has<CancelAlarms>(tr), isTrue);
      expect(has<ScheduleAlarm>(tr), isFalse);
      final frozen = single<ShowOngoing>(tr);
      expect(frozen.pausedAt, t0.add(const Duration(minutes: 2)), reason: 'the live countdown freezes instead of vanishing');
      expect(frozen.endsAt, t0.add(const Duration(minutes: 5)));
      expect(frozen.nextEndsAt, isNull);
      expect(has<HideOngoing>(tr), isFalse);
    });

    test('resume reschedules from now and excludes paused time from actual', () {
      final paused = engine.reduce(running(t0), PauseTimer(t0.add(const Duration(minutes: 2)))).state;
      final resumed = engine.reduce(paused, ResumeTimer(t0.add(const Duration(minutes: 12))));
      expect(resumed.state.status, TimerStatus.running);
      expect(resumed.state.phaseEndsAt, t0.add(const Duration(minutes: 15)));
      expect(resumed.state.pausedTotal, const Duration(minutes: 10));
      expect(
        alarms(resumed).map((a) => a.at),
        [t0.add(const Duration(minutes: 15)), t0.add(const Duration(minutes: 45))],
      );
      expect(has<ShowOngoing>(resumed), isTrue);

      final done = engine.reduce(resumed.state, Tick(t0.add(const Duration(minutes: 15))));
      final ended = single<PhaseEnded>(done);
      expect(ended.actual, const Duration(minutes: 5), reason: '2 before + 3 after the pause');
      expect(ended.startedAt, t0);
      expect(ended.endedAt, t0.add(const Duration(minutes: 15)));
    });

    test('pause is ignored unless running; resume is ignored unless paused', () {
      final idle = TimerState.idle(config);
      expect(engine.reduce(idle, PauseTimer(t0)).effects, isEmpty);
      expect(engine.reduce(idle, ResumeTimer(t0)).effects, isEmpty);
      final s = running(t0);
      expect(engine.reduce(s, ResumeTimer(t0)).state, same(s));
    });
  });

  group('finish early', () {
    test('counts as completed with the elapsed time and moves on to rest', () {
      final tr = engine.reduce(running(t0), FinishEarly(t0.add(const Duration(minutes: 3))));
      final ended = single<PhaseEnded>(tr);
      expect(ended.outcome, SessionOutcome.completed);
      expect(ended.actual, const Duration(minutes: 3));
      expect(ended.planned, const Duration(minutes: 5));
      expect(ended.auto, isFalse);
      expect(single<PlaySound>(tr).alarmAlreadyFired, isFalse);
      expect(tr.state.phase, Phase.rest);
      expect(tr.state.phaseStartedAt, t0.add(const Duration(minutes: 3)));
      expect(tr.state.cycleIndex, 1);
    });

    test('after a snooze it is logged as snoozed', () {
      final snoozed = engine.reduce(running(t0), Snooze(t0)).state;
      final tr = engine.reduce(snoozed, FinishEarly(t0.add(const Duration(minutes: 6))));
      expect(single<PhaseEnded>(tr).outcome, SessionOutcome.snoozed);
    });

    test('ending rest early finishes the run and is still completed', () {
      final rest = engine.reduce(running(t0), Tick(t0.add(const Duration(minutes: 5)))).state;
      final tr = engine.reduce(rest, FinishEarly(t0.add(const Duration(minutes: 15))));
      expect(tr.state.status, TimerStatus.finished);
      final ended = single<PhaseEnded>(tr);
      expect(ended.phase, Phase.rest);
      expect(ended.actual, const Duration(minutes: 10));
      expect(ended.outcome, SessionOutcome.completed);
      expect(has<HideOngoing>(tr), isTrue);
      expect(has<ScheduleAlarm>(tr), isFalse);
    });

    test('while paused only counts time before the pause', () {
      final paused = engine.reduce(running(t0), PauseTimer(t0.add(const Duration(minutes: 1)))).state;
      final tr = engine.reduce(paused, FinishEarly(t0.add(const Duration(minutes: 20))));
      expect(single<PhaseEnded>(tr).actual, const Duration(minutes: 1));
      expect(tr.state.status, TimerStatus.running);
      expect(tr.state.phase, Phase.rest);
    });

    test('is ignored when idle or finished', () {
      expect(engine.reduce(TimerState.idle(config), FinishEarly(t0)).effects, isEmpty);
    });
  });

  group('abandon', () {
    test('returns to idle, logs neutrally and keeps the target for next time', () {
      final tr = engine.reduce(running(t0), AbandonTimer(t0.add(const Duration(seconds: 40))));
      expect(tr.state.status, TimerStatus.idle);
      expect(tr.state.cycleIndex, 0);
      expect(tr.state.target, target);
      expect(tr.state.config, config);
      final ended = single<PhaseEnded>(tr);
      expect(ended.outcome, SessionOutcome.abandoned);
      expect(ended.actual, const Duration(seconds: 40));
      expect(ended.auto, isFalse);
      expect(ended.cycleIndex, 0);
      expect(has<CancelAlarms>(tr), isTrue);
      expect(has<HideOngoing>(tr), isTrue);
      expect(has<ScheduleAlarm>(tr), isFalse);
      expect(has<PlaySound>(tr), isFalse);
    });

    test('during rest logs the rest as abandoned', () {
      final rest = engine.reduce(running(t0), Tick(t0.add(const Duration(minutes: 5)))).state;
      final tr = engine.reduce(rest, AbandonTimer(t0.add(const Duration(minutes: 9))));
      final ended = single<PhaseEnded>(tr);
      expect(ended.phase, Phase.rest);
      expect(ended.outcome, SessionOutcome.abandoned);
      expect(ended.actual, const Duration(minutes: 4));
      expect(tr.state.status, TimerStatus.idle);
    });

    test('while paused excludes the paused time', () {
      final paused = engine.reduce(running(t0), PauseTimer(t0.add(const Duration(seconds: 50)))).state;
      final tr = engine.reduce(paused, AbandonTimer(t0.add(const Duration(minutes: 30))));
      expect(single<PhaseEnded>(tr).actual, const Duration(seconds: 50));
    });
  });

  group('long rest (approach first)', () {
    const cfg = TimerConfig(restFirst: false, 
      approach: Duration(minutes: 25),
      rest: Duration(minutes: 5),
      longRest: Duration(minutes: 20),
      cyclesBeforeLongRest: 2,
    );

    test('every second completed approach is followed by the long rest', () {
      var tr = engine.reduce(running(t0, cfg: cfg), Tick(t0.add(const Duration(minutes: 25))));
      expect(tr.state.phase, Phase.rest);
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 30))));
      expect(tr.state.status, TimerStatus.finished);
      expect(tr.state.cycleIndex, 1);
      tr = start(tr.state, t0.add(const Duration(minutes: 31)), cfg: cfg, runId: 'run-2');
      expect(alarms(tr).last.phase, Phase.longRest, reason: 'pre-scheduled rest alarm knows it is the long one');
      expect(alarms(tr).last.at, t0.add(const Duration(minutes: 76)));
      expect(single<ShowOngoing>(tr).nextPhase, Phase.longRest, reason: 'the lock screen can label the long rest');
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 56))));
      expect(tr.state.phase, Phase.longRest);
      expect(tr.state.planned, const Duration(minutes: 20));
      expect(tr.state.cycleIndex, 2);
      expect(single<ScheduleAlarm>(tr).phase, Phase.longRest);
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 76))));
      expect(single<PhaseEnded>(tr).phase, Phase.longRest);
      expect(single<PhaseEnded>(tr).actual, const Duration(minutes: 20));
    });

    test('an abandoned approach does not count toward the long rest', () {
      var tr = engine.reduce(running(t0, cfg: cfg), AbandonTimer(t0.add(const Duration(minutes: 1))));
      expect(tr.state.cycleIndex, 0);
      tr = start(tr.state, t0.add(const Duration(minutes: 2)), cfg: cfg);
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 27))));
      expect(tr.state.phase, Phase.rest);
    });

    test('no long rest when cycles is 0 or longRest is null', () {
      const noLong = TimerConfig(restFirst: false, approach: Duration(minutes: 1), rest: Duration(minutes: 1), cyclesBeforeLongRest: 1);
      final tr = engine.reduce(running(t0, cfg: noLong), Tick(t0.add(const Duration(minutes: 1))));
      expect(tr.state.phase, Phase.rest);
      const zero = TimerConfig(restFirst: false, approach: Duration(minutes: 1), rest: Duration(minutes: 1), longRest: Duration(minutes: 9));
      final tr2 = engine.reduce(running(t0, cfg: zero), Tick(t0.add(const Duration(minutes: 1))));
      expect(tr2.state.phase, Phase.rest);
    });
  });

  group('autoStartNext off (approach first)', () {
    test('only the approach alarm is scheduled on start, and no rest end is announced', () {
      const manual = TimerConfig(restFirst: false, approach: Duration(minutes: 5), rest: Duration(minutes: 30), autoStartNext: false);
      final tr = start(TimerState.idle(manual), t0, cfg: manual);
      expect(alarms(tr).map((a) => a.phase), [Phase.approach]);
      expect(single<ShowOngoing>(tr).nextEndsAt, isNull);
    });

    test('a rest started by hand honours the long-rest cycle', () {
      const manual = TimerConfig(restFirst: false, 
        approach: Duration(minutes: 5),
        rest: Duration(minutes: 10),
        longRest: Duration(minutes: 25),
        cyclesBeforeLongRest: 2,
        autoStartNext: false,
      );
      var tr = engine.reduce(running(t0, cfg: manual), Tick(t0.add(const Duration(minutes: 5))));
      expect(tr.state.status, TimerStatus.finished);
      tr = start(tr.state, t0.add(const Duration(minutes: 6)), phase: Phase.rest, cfg: manual, tgt: null);
      expect(tr.state.phase, Phase.rest, reason: 'first approach: a normal rest');
      expect(alarms(tr).map((a) => a.phase), [Phase.rest]);
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 16))));
      tr = start(tr.state, t0.add(const Duration(minutes: 17)), cfg: manual, runId: 'run-2');
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 22))));
      expect(tr.state.cycleIndex, 2);
      tr = start(tr.state, t0.add(const Duration(minutes: 23)), phase: Phase.rest, cfg: manual, tgt: null);
      expect(tr.state.phase, Phase.longRest, reason: 'second approach: the long rest is due');
      expect(tr.state.planned, const Duration(minutes: 25));
      expect(TimerEngine.restPhaseFor(manual, 2), Phase.longRest);
      expect(TimerEngine.restPhaseFor(manual, 3), Phase.rest);
    });

    test('approach completion ends in finished with no rest scheduled', () {
      const manual = TimerConfig(restFirst: false, approach: Duration(minutes: 5), rest: Duration(minutes: 30), autoStartNext: false);
      final tr = engine.reduce(running(t0, cfg: manual), Tick(t0.add(const Duration(minutes: 5))));
      expect(tr.state.status, TimerStatus.finished);
      expect(tr.state.phase, Phase.approach);
      expect(tr.state.cycleIndex, 1);
      expect(has<ScheduleAlarm>(tr), isFalse);
      expect(has<HideOngoing>(tr), isTrue);
      expect(single<PhaseEnded>(tr).outcome, SessionOutcome.completed);
      // Rest can then be started by hand.
      final rest = start(tr.state, t0.add(const Duration(minutes: 6)), phase: Phase.rest, cfg: manual, tgt: null);
      expect(rest.state.phase, Phase.rest);
      expect(rest.state.target, target, reason: 'a rest keeps the previous target');
      expect(rest.state.planned, const Duration(minutes: 30));
    });
  });

  group('rest first (the default)', () {
    const cfg = TimerConfig(approach: Duration(minutes: 5), rest: Duration(minutes: 30), snoozeBy: Duration(minutes: 2));

    test('a round opens with the rest and pre-schedules the step', () {
      final tr = start(TimerState.idle(cfg), t0, cfg: cfg);
      final s = tr.state;
      expect(s.status, TimerStatus.running);
      expect(s.phase, Phase.rest);
      expect(s.isPreparing, isTrue);
      expect(s.planned, const Duration(minutes: 30));
      expect(s.phaseEndsAt, t0.add(const Duration(minutes: 30)));
      expect(s.target, target, reason: 'the rest knows which step it prepares for');
      expect(s.cycleIndex, 0);
      expect(alarms(tr).map((a) => a.phase), [Phase.rest, Phase.approach]);
      expect(alarms(tr)[1].at, t0.add(const Duration(minutes: 35)), reason: 'the step alarm fires even if the app is dead at the hand-over');
      final ongoing = single<ShowOngoing>(tr);
      expect(ongoing.phase, Phase.rest);
      expect(ongoing.nextPhase, Phase.approach);
      expect(ongoing.nextEndsAt, t0.add(const Duration(minutes: 35)));
      expect(single<PlaySound>(tr).kind, SoundKind.start);
    });

    test('when the rest ends the step begins on its own', () {
      final rest = start(TimerState.idle(cfg), t0, cfg: cfg).state;
      final tr = engine.reduce(rest, Tick(t0.add(const Duration(minutes: 30))));
      expect(tr.state.status, TimerStatus.running);
      expect(tr.state.phase, Phase.approach);
      expect(tr.state.phaseStartedAt, t0.add(const Duration(minutes: 30)));
      expect(tr.state.phaseEndsAt, t0.add(const Duration(minutes: 35)));
      expect(tr.state.cycleIndex, 0, reason: 'nothing completed yet');
      expect(tr.state.target, target);
      final ended = single<PhaseEnded>(tr);
      expect(ended.phase, Phase.rest);
      expect(ended.outcome, SessionOutcome.completed);
      expect(ended.actual, const Duration(minutes: 30));
      expect(single<PlaySound>(tr).kind, SoundKind.restDone);
      expect(single<ScheduleAlarm>(tr).phase, Phase.approach);
      final ongoing = single<ShowOngoing>(tr);
      expect(ongoing.phase, Phase.approach);
      expect(ongoing.nextPhase, isNull, reason: 'the step closes the round');
    });

    test('when the step ends the round is complete', () {
      var tr = engine.reduce(start(TimerState.idle(cfg), t0, cfg: cfg).state, Tick(t0.add(const Duration(minutes: 30))));
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 35))));
      expect(tr.state.status, TimerStatus.finished);
      expect(tr.state.phase, Phase.approach);
      expect(tr.state.cycleIndex, 1);
      expect(has<ScheduleAlarm>(tr), isFalse);
      expect(has<HideOngoing>(tr), isTrue);
      expect(single<PhaseEnded>(tr).phase, Phase.approach);
      expect(single<PlaySound>(tr).kind, SoundKind.approachDone);
      // Another round opens with the rest again, with whatever target is given.
      final next = start(tr.state, t0.add(const Duration(minutes: 40)), cfg: cfg, runId: 'run-2', tgt: null);
      expect(next.state.phase, Phase.rest);
      expect(next.state.cycleIndex, 1);
      expect(next.state.target, isNull, reason: 'a new round does not inherit the old target');
    });

    test('more time to get ready: snoozing the rest moves the step too', () {
      final rest = start(TimerState.idle(cfg), t0, cfg: cfg).state;
      final tr = engine.reduce(rest, Snooze(t0.add(const Duration(minutes: 25))));
      expect(tr.state.phase, Phase.rest);
      expect(tr.state.phaseEndsAt, t0.add(const Duration(minutes: 32)));
      expect(tr.state.snoozeCount, 1);
      expect(alarms(tr).map((a) => a.at), [t0.add(const Duration(minutes: 32)), t0.add(const Duration(minutes: 37))]);
      expect(single<ShowOngoing>(tr).nextEndsAt, t0.add(const Duration(minutes: 37)));
    });

    test('ready now: ending the rest early starts the step at once', () {
      final rest = start(TimerState.idle(cfg), t0, cfg: cfg).state;
      final tr = engine.reduce(rest, FinishEarly(t0.add(const Duration(minutes: 10))));
      expect(tr.state.phase, Phase.approach);
      expect(tr.state.status, TimerStatus.running);
      expect(tr.state.phaseEndsAt, t0.add(const Duration(minutes: 15)));
      final ended = single<PhaseEnded>(tr);
      expect(ended.phase, Phase.rest);
      expect(ended.outcome, SessionOutcome.completed);
      expect(ended.actual, const Duration(minutes: 10));
    });

    test('with automatic start off the step waits for a tap', () {
      const manual = TimerConfig(approach: Duration(minutes: 5), rest: Duration(minutes: 30), autoStartNext: false);
      var tr = start(TimerState.idle(manual), t0, cfg: manual);
      expect(alarms(tr).map((a) => a.phase), [Phase.rest], reason: 'no step alarm is pre-scheduled');
      expect(single<ShowOngoing>(tr).nextPhase, isNull);
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 30))));
      expect(tr.state.status, TimerStatus.finished);
      expect(tr.state.phase, Phase.rest);
      expect(tr.state.isPreparing, isTrue);
      expect(has<HideOngoing>(tr), isTrue);
      tr = start(tr.state, t0.add(const Duration(minutes: 31)), phase: Phase.approach, cfg: manual);
      expect(tr.state.phase, Phase.approach);
      expect(tr.state.cycleIndex, 0);
      expect(alarms(tr).map((a) => a.phase), [Phase.approach]);
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 36))));
      expect(tr.state.status, TimerStatus.finished);
      expect(tr.state.cycleIndex, 1);
    });

    test('the long rest opens a round after enough completed steps, never the first', () {
      const long = TimerConfig(
        approach: Duration(minutes: 5),
        rest: Duration(minutes: 10),
        longRest: Duration(minutes: 25),
        cyclesBeforeLongRest: 2,
      );
      var tr = start(TimerState.idle(long), t0, cfg: long);
      expect(tr.state.phase, Phase.rest, reason: 'no long rest before anything was done');
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 10))));
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 15))));
      expect(tr.state.cycleIndex, 1);
      tr = start(tr.state, t0.add(const Duration(minutes: 16)), cfg: long, runId: 'run-2');
      expect(tr.state.phase, Phase.rest);
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 26))));
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 31))));
      expect(tr.state.cycleIndex, 2);
      tr = start(tr.state, t0.add(const Duration(minutes: 32)), cfg: long, runId: 'run-3');
      expect(tr.state.phase, Phase.longRest, reason: 'two steps done: the next round opens with the long rest');
      expect(tr.state.planned, const Duration(minutes: 25));
      expect(alarms(tr).map((a) => a.phase), [Phase.longRest, Phase.approach]);
      expect(single<ShowOngoing>(tr).nextPhase, Phase.approach);
    });

    test('ready now with automatic start off still starts the step at once', () {
      const manual = TimerConfig(approach: Duration(minutes: 5), rest: Duration(minutes: 30), autoStartNext: false);
      final rest = start(TimerState.idle(manual), t0, cfg: manual).state;
      final tr = engine.reduce(rest, FinishEarly(t0.add(const Duration(minutes: 4))));
      expect(tr.state.status, TimerStatus.running);
      expect(tr.state.phase, Phase.approach, reason: '"Start the step" means now');
      expect(tr.state.phaseEndsAt, t0.add(const Duration(minutes: 9)));
      expect(single<ScheduleAlarm>(tr).phase, Phase.approach);
    });

    test('the mood given at the start rides the round to the step', () {
      final tr0 = engine.reduce(
        TimerState.idle(cfg),
        StartTimer(t0, runId: 'run-m', target: target, config: cfg, moodBefore: 'heavy'),
      );
      expect(tr0.state.moodBefore, 'heavy');
      final restDone = engine.reduce(tr0.state, Tick(t0.add(const Duration(minutes: 30))));
      expect(single<PhaseEnded>(restDone).moodBefore, isNull, reason: 'the mood belongs to the approach');
      expect(restDone.state.moodBefore, 'heavy');
      final stepDone = engine.reduce(restDone.state, Tick(t0.add(const Duration(minutes: 35))));
      expect(single<PhaseEnded>(stepDone).moodBefore, 'heavy');
      // A phase started by hand inside the round keeps it; a new round replaces it.
      const manual = TimerConfig(approach: Duration(minutes: 5), rest: Duration(minutes: 30), autoStartNext: false);
      var m = engine.reduce(TimerState.idle(manual), StartTimer(t0, runId: 'r', config: manual, moodBefore: 'flat'));
      m = engine.reduce(m.state, Tick(t0.add(const Duration(minutes: 30))));
      m = engine.reduce(m.state, StartTimer(t0.add(const Duration(minutes: 31)), runId: 'r', phase: Phase.approach, config: manual));
      expect(m.state.moodBefore, 'flat');
      final fresh = start(TimerState.idle(cfg), t0, cfg: cfg).state;
      expect(fresh.moodBefore, isNull);
    });

    test('alarms are told what happens when they fire', () {
      final tr = start(TimerState.idle(cfg), t0, cfg: cfg);
      final a = alarms(tr);
      expect(a[0].phase, Phase.rest);
      expect(a[0].next, Phase.approach, reason: 'the rest alarm announces the step');
      expect(a[0].preparing, isTrue);
      expect(a[1].phase, Phase.approach);
      expect(a[1].next, isNull, reason: 'the step closes the round');
      expect(single<ShowOngoing>(tr).preparing, isTrue);
      const manual = TimerConfig(approach: Duration(minutes: 5), rest: Duration(minutes: 30), autoStartNext: false);
      final waits = start(TimerState.idle(manual), t0, cfg: manual);
      expect(single<ScheduleAlarm>(waits).next, isNull);
      expect(single<ScheduleAlarm>(waits).preparing, isTrue, reason: 'the words still name the step');
      const classic = TimerConfig(restFirst: false, approach: Duration(minutes: 5), rest: Duration(minutes: 30));
      final c = alarms(start(TimerState.idle(classic), t0, cfg: classic));
      expect(c[0].next, Phase.rest);
      expect(c[0].preparing, isFalse);
      expect(c[1].next, isNull);
    });

    test('abandoning the rest returns to idle and keeps the target', () {
      final rest = start(TimerState.idle(cfg), t0, cfg: cfg).state;
      final tr = engine.reduce(rest, AbandonTimer(t0.add(const Duration(minutes: 3))));
      expect(tr.state.status, TimerStatus.idle);
      expect(tr.state.target, target);
      final ended = single<PhaseEnded>(tr);
      expect(ended.phase, Phase.rest);
      expect(ended.outcome, SessionOutcome.abandoned);
    });
  });

  group('derived values', () {
    test('idle shows the configured approach as remaining', () {
      final idle = TimerState.idle(config);
      expect(idle.remaining(t0), const Duration(minutes: 5));
      expect(idle.elapsed(t0), Duration.zero);
      expect(idle.progress(t0), 0);
    });

    test('remaining, elapsed and progress while running', () {
      final s = running(t0);
      final at = t0.add(const Duration(minutes: 1));
      expect(s.remaining(at), const Duration(minutes: 4));
      expect(s.elapsed(at), const Duration(minutes: 1));
      expect(s.progress(at), closeTo(0.2, 1e-9));
      expect(s.remaining(t0.add(const Duration(hours: 1))), Duration.zero);
      expect(s.progress(t0.add(const Duration(hours: 1))), 1.0);
    });

    test('progress accounts for snooze extensions', () {
      final s = engine.reduce(running(t0), Snooze(t0)).state;
      expect(s.plannedWithExtensions, const Duration(minutes: 7));
      expect(s.progress(t0.add(const Duration(minutes: 3, seconds: 30))), closeTo(0.5, 1e-9));
    });

    test('finished shows zero remaining and full progress', () {
      var tr = engine.reduce(running(t0), Tick(t0.add(const Duration(minutes: 5))));
      tr = engine.reduce(tr.state, Tick(t0.add(const Duration(minutes: 35))));
      expect(tr.state.remaining(t0.add(const Duration(hours: 9))), Duration.zero);
      expect(tr.state.progress(t0.add(const Duration(hours: 9))), 1.0);
    });
  });

  group('reset and config', () {
    test('reset returns to idle with the same config and cancels everything', () {
      final tr = engine.reduce(running(t0), ResetTimer(t0));
      expect(tr.state.status, TimerStatus.idle);
      expect(tr.state.config, config);
      expect(tr.state.target, target);
      expect(has<CancelAlarms>(tr), isTrue);
      expect(has<HideOngoing>(tr), isTrue);
      expect(has<PhaseEnded>(tr), isFalse);
    });

    test('update config does not touch the running phase', () {
      final s = running(t0);
      const other = TimerConfig(restFirst: false, approach: Duration(minutes: 50), rest: Duration(minutes: 10));
      final tr = engine.reduce(s, UpdateConfig(t0, other));
      expect(tr.state.config, other);
      expect(tr.state.phaseEndsAt, s.phaseEndsAt);
      expect(tr.effects, isEmpty);
      final idle = engine.reduce(TimerState.idle(config), UpdateConfig(t0, other)).state;
      expect(idle.config, other);
    });
  });
}
