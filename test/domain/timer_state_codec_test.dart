import 'dart:convert';

import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/domain/timer/timer_state_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = TimerEngine();
  final t0 = DateTime(2026, 10, 18, 9, 30);
  const config = TimerConfig(
    approach: Duration(minutes: 5),
    rest: Duration(minutes: 30),
    longRest: Duration(minutes: 45),
    cyclesBeforeLongRest: 3,
    snoozeBy: Duration(seconds: 90),
    autoStartRest: false,
  );
  const target = ApproachTarget(taskId: 't', taskTitle: 'Laundry', rungId: 'r2', rungPosition: 2, rungText: 'Sit up');

  test('running state round-trips through JSON', () {
    var tr = engine.reduce(
      TimerState.idle(config),
      StartTimer(t0, runId: 'run-7', target: target, config: config),
    );
    tr = engine.reduce(tr.state, SnoozeApproach(t0.add(const Duration(minutes: 1))));
    final json = jsonDecode(jsonEncode(TimerStateCodec.toJson(tr.state))) as Map<String, dynamic>;
    final back = TimerStateCodec.fromJson(json);
    expect(back.status, TimerStatus.running);
    expect(back.phase, Phase.approach);
    expect(back.runId, 'run-7');
    expect(back.config, config);
    expect(back.target, target);
    expect(back.phaseStartedAt, t0);
    expect(back.phaseEndsAt, t0.add(const Duration(minutes: 6, seconds: 30)));
    expect(back.planned, const Duration(minutes: 5));
    expect(back.extended, const Duration(seconds: 90));
    expect(back.snoozeCount, 1);
    expect(back.cycleIndex, 0);
    // The restored state keeps ticking correctly.
    final done = engine.reduce(back, Tick(t0.add(const Duration(minutes: 7))));
    expect(done.effects.whereType<PhaseEnded>().single.outcome, SessionOutcome.snoozed);
  });

  test('paused state keeps pausedRemaining and pausedAt', () {
    final running = engine.reduce(TimerState.idle(config), StartTimer(t0, runId: 'r')).state;
    final paused = engine.reduce(running, PauseTimer(t0.add(const Duration(minutes: 2)))).state;
    final back = TimerStateCodec.fromJson(TimerStateCodec.toJson(paused));
    expect(back.status, TimerStatus.paused);
    expect(back.pausedRemaining, const Duration(minutes: 3));
    expect(back.pausedAt, t0.add(const Duration(minutes: 2)));
    expect(back.target, isNull);
    final resumed = engine.reduce(back, ResumeTimer(t0.add(const Duration(minutes: 10))));
    expect(resumed.state.phaseEndsAt, t0.add(const Duration(minutes: 13)));
  });

  test('missing optional fields fall back to defaults', () {
    final back = TimerStateCodec.fromJson({
      'status': 'idle',
      'phase': 'approach',
      'config': {'approachMs': 60000, 'restMs': 120000},
    });
    expect(back.status, TimerStatus.idle);
    expect(back.config.snoozeBy, const Duration(minutes: 2));
    expect(back.config.autoStartRest, isTrue);
    expect(back.runId, '');
  });
}
