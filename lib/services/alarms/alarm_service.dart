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

  Future<void> schedulePhaseEnd({
    required Phase phase,
    required DateTime at,
    ApproachTarget? target,
    required bool sound,
    required bool vibrate,
  });

  /// Cancel the scheduled "phase over" alarms (not the ongoing notification).
  Future<void> cancelScheduled();

  Future<void> showOngoing({
    required Phase phase,
    required DateTime endsAt,
    ApproachTarget? target,
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
  }) async {}

  @override
  Future<void> cancelScheduled() async {}

  @override
  Future<void> showOngoing({
    required Phase phase,
    required DateTime endsAt,
    ApproachTarget? target,
  }) async {}

  @override
  Future<void> hideOngoing() async {}

  @override
  Stream<String?> get tapped => const Stream.empty();
}
