import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../domain/entities/approach_target.dart';
import '../../domain/entities/phase.dart';
import '../../domain/timer/timer_engine.dart';
import '../../domain/timer/timer_state_codec.dart';
import '../alarms/alarm_service.dart';
import '../audio/sound_service.dart';
import '../providers.dart';
import '../settings/settings_service.dart';
import '../xp/xp_service.dart';

/// Drives the pure [TimerEngine]: feeds it events, runs a one-second ticker
/// while something is running, executes effects through the services, and
/// persists the state so a killed app resumes the same phase.
class TimerController extends Notifier<TimerState> {
  static const TimerEngine engine = TimerEngine();

  Timer? _ticker;
  String? _moodBefore;
  bool _wakelockOn = false;

  @override
  TimerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _ticker = null;
    });
    final settings = ref.read(settingsProvider);
    return TimerState.idle(settings.timerConfig);
  }

  AlarmService get _alarms => ref.read(alarmServiceProvider);
  SoundService get _sound => ref.read(soundServiceProvider);
  XpService get _xp => ref.read(xpServiceProvider);
  SettingsService get _store => ref.read(settingsServiceProvider);
  AppSettings get _settings => ref.read(settingsProvider);

  /// One tap. Requests notification permission the first time only.
  Future<void> start({
    TimerConfig? config,
    ApproachTarget? target,
    String? moodBefore,
    Phase phase = Phase.approach,
  }) async {
    if (state.isActive) return;
    _moodBefore = moodBefore;
    if (_alarms.isSupported && !_alarms.capabilities.notificationsGranted) {
      await _alarms.ensurePermissions();
    }
    _dispatch(
      StartTimer(
        clock.now(),
        runId: const Uuid().v4(),
        phase: phase,
        target: target,
        config: config ?? _settings.timerConfig,
      ),
    );
  }

  void pause() => _dispatch(PauseTimer(clock.now()));

  void resume() => _dispatch(ResumeTimer(clock.now()));

  void snooze({Duration? by}) => _dispatch(SnoozeApproach(clock.now(), by: by));

  void finishEarly() => _dispatch(FinishEarly(clock.now()));

  void abandon() => _dispatch(AbandonTimer(clock.now()));

  void reset() => _dispatch(ResetTimer(clock.now()));

  void updateConfig(TimerConfig config) => _dispatch(UpdateConfig(clock.now(), config));

  /// Call when the app comes back to the foreground: a missed tick ends any
  /// phase whose time ran out while the process was suspended.
  void catchUp() {
    if (state.isRunning) _dispatch(Tick(clock.now()));
  }

  /// Restore a timer that was running when the process died.
  Future<void> restore() async {
    final json = await _store.loadActiveTimer();
    if (json == null) return;
    try {
      final restored = TimerStateCodec.fromJson(json);
      if (!restored.isActive) {
        await _store.saveActiveTimer(null);
        return;
      }
      state = restored;
      _syncTicker();
      _syncWakelock();
      _dispatch(Tick(clock.now()));
    } catch (e) {
      debugPrint('Timer restore failed: $e');
      await _store.saveActiveTimer(null);
    }
  }

  void _dispatch(TimerEvent event) {
    final tr = engine.reduce(state, event);
    if (identical(tr.state, state) && tr.effects.isEmpty) return;
    state = tr.state;
    _syncTicker();
    _syncWakelock();
    unawaited(_persist());
    unawaited(_runEffects(tr.effects));
  }

  void _syncTicker() {
    if (state.isRunning) {
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        _dispatch(Tick(clock.now()));
      });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _syncWakelock() {
    final want = state.isRunning && _settings.keepScreenOn && !kIsWeb;
    if (want == _wakelockOn) return;
    _wakelockOn = want;
    unawaited(
      WakelockPlus.toggle(enable: want).catchError((Object e) {
        debugPrint('wakelock failed: $e');
      }),
    );
  }

  Future<void> _persist() async {
    try {
      await _store.saveActiveTimer(state.isActive ? TimerStateCodec.toJson(state) : null);
    } catch (e) {
      debugPrint('Timer persist failed: $e');
    }
  }

  Future<void> _runEffects(List<TimerEffect> effects) async {
    final settings = _settings;
    for (final effect in effects) {
      try {
        switch (effect) {
          case ScheduleAlarm():
            await _alarms.schedulePhaseEnd(
              phase: effect.phase,
              at: effect.at,
              target: effect.target,
              sound: settings.soundEnabled,
              vibrate: settings.vibrationEnabled,
            );
          case CancelAlarms():
            await _alarms.cancelScheduled();
          case ShowOngoing():
            await _alarms.showOngoing(
              phase: effect.phase,
              endsAt: effect.endsAt,
              target: effect.target,
            );
          case HideOngoing():
            await _alarms.hideOngoing();
          case PlaySound():
            if (settings.vibrationEnabled) await _sound.haptic(effect.kind);
            if (effect.kind == SoundKind.start) break;
            final osAlarmCoversIt =
                effect.alarmAlreadyFired && _alarms.capabilities.alarmsWillFire;
            if (settings.soundEnabled && !osAlarmCoversIt) {
              await _sound.play(effect.kind);
            }
          case PhaseEnded():
            final logged = await _xp.logPhase(
              effect,
              moodBefore: effect.phase == Phase.approach ? _moodBefore : null,
            );
            ref.read(lastLoggedProvider.notifier).set(logged);
            if (effect.phase == Phase.approach) {
              _moodBefore = null;
              ref.read(lastApproachLoggedProvider.notifier).set(logged);
            }
        }
      } catch (e, st) {
        debugPrint('Timer effect $effect failed: $e\n$st');
      }
    }
  }
}

/// The most recently logged interval, for the one-line XP feedback.
class LastLoggedController extends Notifier<LoggedInterval?> {
  @override
  LoggedInterval? build() => null;

  void set(LoggedInterval? value) => state = value;

  void clear() => state = null;
}
