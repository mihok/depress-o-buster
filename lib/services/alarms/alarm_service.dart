import 'package:meta/meta.dart';

import '../../domain/entities/approach_target.dart';
import '../../domain/entities/phase.dart';

/// What the OS currently lets us do. Used by the UI to show one calm hint,
/// never a wall.
@immutable
class AlarmCapabilities {
  const AlarmCapabilities({
    required this.notificationsGranted,
    required this.exactAlarmsAllowed,
  });

  static const AlarmCapabilities unsupported = AlarmCapabilities(
    notificationsGranted: false,
    exactAlarmsAllowed: false,
  );

  final bool notificationsGranted;

  /// Android only: whether exact alarms are allowed. Always true elsewhere.
  final bool exactAlarmsAllowed;

  bool get alarmsWillFire => notificationsGranted;
}

/// Schedules the "phase over" alarms and the ongoing countdown notification.
/// The timer never waits on this; every call is best-effort.
abstract class AlarmService {
  bool get isSupported;

  /// Last known capabilities (cheap, synchronous, may be stale).
  AlarmCapabilities get capabilities;

  Future<void> init();

  /// Checks and, when [request] is true, asks for what is missing.
  Future<AlarmCapabilities> ensurePermissions({bool request = true});

  /// Android: open the exact-alarm settings page.
  Future<void> openExactAlarmSettings();

  /// [next] is the phase that begins on its own when the alarm fires;
  /// [preparing] marks the rest before a step. Both only change the words.
  Future<void> schedulePhaseEnd({
    required Phase phase,
    required DateTime at,
    ApproachTarget? target,
    required bool sound,
    required bool vibrate,
    Phase? next,
    bool preparing = false,
  });

  /// Cancel the scheduled "phase over" alarms (not the ongoing notification).
  Future<void> cancelScheduled();

  /// Show or update the live countdown for [runId]: an ongoing notification
  /// on Android, a Live Activity on iOS. [nextEndsAt] and [nextPhase] describe
  /// the phase that will follow automatically, if any. While [pausedAt] is
  /// set the countdown is frozen at `endsAt - pausedAt`.
  Future<void> showOngoing({
    required String runId,
    required Phase phase,
    required DateTime endsAt,
    ApproachTarget? target,
    DateTime? nextEndsAt,
    Phase? nextPhase,
    DateTime? pausedAt,
    bool preparing = false,
  });

  Future<void> hideOngoing();

  /// Payloads of tapped notifications.
  Stream<String?> get tapped;
}

/// For web, Windows and tests.
class NoopAlarmService implements AlarmService {
  @override
  bool get isSupported => false;

  @override
  AlarmCapabilities get capabilities => AlarmCapabilities.unsupported;

  @override
  Future<void> init() async {}

  @override
  Future<AlarmCapabilities> ensurePermissions({bool request = true}) async =>
      AlarmCapabilities.unsupported;

  @override
  Future<void> openExactAlarmSettings() async {}

  @override
  Future<void> schedulePhaseEnd({
    required Phase phase,
    required DateTime at,
    ApproachTarget? target,
    required bool sound,
    required bool vibrate,
    Phase? next,
    bool preparing = false,
  }) async {}

  @override
  Future<void> cancelScheduled() async {}

  @override
  Future<void> showOngoing({
    required String runId,
    required Phase phase,
    required DateTime endsAt,
    ApproachTarget? target,
    DateTime? nextEndsAt,
    Phase? nextPhase,
    DateTime? pausedAt,
    bool preparing = false,
  }) async {}

  @override
  Future<void> hideOngoing() async {}

  @override
  Stream<String?> get tapped => const Stream.empty();
}

/// The words on a "phase over" notification. Pure, so they can be tested.
class AlarmCopy {
  AlarmCopy._();

  static ({String title, String body}) phaseEnd({
    required Phase phase,
    ApproachTarget? target,
    Phase? next,
    bool preparing = false,
  }) {
    final what = target == null || target.isEmpty ? null : target.description;
    if (phase == Phase.approach) {
      final counts = what == null ? 'That counts.' : '$what. That counts.';
      return (title: 'Approach done', body: next == null ? counts : '$counts Rest now.');
    }
    final restTitle = phase == Phase.longRest ? 'Long rest done' : 'Rest done';
    if (next == Phase.approach) {
      return (title: 'Time for the step', body: what ?? 'The rest is over. The step starts now.');
    }
    if (preparing) {
      return (
        title: restTitle,
        body: what == null ? 'Start the step when you are ready.' : 'Start the step when you are ready: $what',
      );
    }
    return (title: restTitle, body: 'Ready when you are.');
  }
}
