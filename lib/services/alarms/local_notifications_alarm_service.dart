import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/approach_target.dart';
import '../../domain/entities/phase.dart';
import 'alarm_service.dart';
import 'live_activity_channel.dart';

/// Alarms via `flutter_local_notifications`.
///
/// Android: exact alarms in `alarmClock` mode (the most reliable mode for a
/// user-visible timer; `USE_EXACT_ALARM` is declared because this is a timer
/// app), each phase on its own channel with its own gentle sound, plus an
/// ongoing low-importance notification that counts down with a chronometer.
/// iOS: a scheduled notification with a bundled sound at the time-sensitive
/// interruption level, plus a Live Activity (lock screen and Dynamic Island)
/// for the countdown. See docs/PLATFORM_ALARMS.md for the limitations.
class LocalNotificationsAlarmService implements AlarmService {
  LocalNotificationsAlarmService({
    FlutterLocalNotificationsPlugin? plugin,
    LiveActivityChannel? liveActivity,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _liveActivity = liveActivity ?? LiveActivityChannel();

  final FlutterLocalNotificationsPlugin _plugin;
  final LiveActivityChannel _liveActivity;
  final _taps = StreamController<String?>.broadcast();
  AlarmCapabilities _caps = AlarmCapabilities.unsupported;
  bool _initialized = false;

  static const int approachAlarmId = 1001;
  static const int restAlarmId = 1002;
  static const int ongoingId = 2001;

  static const String approachChannelId = 'approach_done';
  static const String restChannelId = 'rest_done';
  static const String ongoingChannelId = 'ongoing_timer';

  static const String payloadApproach = 'phase:approach';
  static const String payloadRest = 'phase:rest';
  static const String payloadOngoing = 'ongoing';

  /// Linux is left out on purpose: the plugin cannot schedule there, so the
  /// in-app chime has to carry the alarm (see docs/PLATFORM_ALARMS.md).
  @override
  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  @override
  AlarmCapabilities get capabilities => _caps;

  @override
  Stream<String?> get tapped => _taps.stream;

  /// The sage of the approach colour; Android tints the small icon with it.
  static const Color _accent = Color(0xFF8FB39A);

  AndroidFlutterLocalNotificationsPlugin? get _android => !kIsWeb && Platform.isAndroid
      ? _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      : null;

  @override
  Future<void> init() async {
    if (!isSupported || _initialized) return;
    // A monochrome glyph: Android draws small icons as a white silhouette and
    // tints them, so the launcher icon would come out as a blob.
    const android = AndroidInitializationSettings('ic_stat_stone');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin, macOS: darwin),
      onDidReceiveNotificationResponse: (response) => _taps.add(response.payload),
    );
    await _createChannels();
    _initialized = true;
    await ensurePermissions(request: false);
  }

  /// Channel id for a phase and the two user switches. On Android 8+ sound
  /// and vibration are properties of the channel, not of the notification, so
  /// every combination the settings allow is its own channel.
  static String channelIdFor({required bool approach, required bool sound, required bool vibrate}) {
    final base = approach ? approachChannelId : restChannelId;
    if (sound && vibrate) return base;
    if (!sound && vibrate) return '${base}_silent';
    if (sound && !vibrate) return '${base}_novibe';
    return '${base}_silent_novibe';
  }

  Future<void> _createChannels() async {
    final android = _android;
    if (android == null) return;
    for (final approach in [true, false]) {
      final name = approach ? 'Approach finished' : 'Rest finished';
      final description = approach
          ? 'Plays when an approach interval ends.'
          : 'Plays when a rest interval ends.';
      final soundName = approach ? 'approach_done' : 'rest_done';
      for (final sound in [true, false]) {
        for (final vibrate in [true, false]) {
          final suffix = switch ((sound, vibrate)) {
            (true, true) => '',
            (false, true) => ' (silent)',
            (true, false) => ' (no vibration)',
            (false, false) => ' (silent, no vibration)',
          };
          await android.createNotificationChannel(
            AndroidNotificationChannel(
              channelIdFor(approach: approach, sound: sound, vibrate: vibrate),
              '$name$suffix',
              description: description,
              importance: Importance.max,
              playSound: sound,
              sound: sound ? RawResourceAndroidNotificationSound(soundName) : null,
              enableVibration: vibrate,
              audioAttributesUsage: AudioAttributesUsage.alarm,
            ),
          );
        }
      }
    }
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        ongoingChannelId,
        'Running timer',
        description: 'Shows the countdown while a timer is running.',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );
  }

  @override
  Future<AlarmCapabilities> ensurePermissions({bool request = true}) async {
    if (!isSupported) return _caps;
    try {
      if (Platform.isAndroid) {
        final android = _android!;
        var granted = await android.areNotificationsEnabled() ?? false;
        if (!granted && request) {
          granted = await android.requestNotificationsPermission() ?? false;
        }
        var exact = await android.canScheduleExactNotifications() ?? false;
        if (!exact && request) {
          exact = await android.requestExactAlarmsPermission() ?? false;
        }
        _caps = AlarmCapabilities(notificationsGranted: granted, exactAlarmsAllowed: exact);
      } else if (Platform.isIOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        var granted = (await ios?.checkPermissions())?.isEnabled ?? false;
        if (!granted && request) {
          granted = await ios?.requestPermissions(alert: true, sound: true, badge: false) ?? false;
        }
        _caps = AlarmCapabilities(notificationsGranted: granted, exactAlarmsAllowed: true);
      } else if (Platform.isMacOS) {
        final mac = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
        var granted = (await mac?.checkPermissions())?.isEnabled ?? false;
        if (!granted && request) {
          granted = await mac?.requestPermissions(alert: true, sound: true, badge: false) ?? false;
        }
        _caps = AlarmCapabilities(notificationsGranted: granted, exactAlarmsAllowed: true);
      } else {
        _caps = AlarmCapabilities.unsupported;
      }
    } catch (e, st) {
      debugPrint('ensurePermissions failed: $e\n$st');
    }
    return _caps;
  }

  @override
  Future<void> openExactAlarmSettings() async {
    await _android?.requestExactAlarmsPermission();
    await ensurePermissions(request: false);
  }

  @override
  Future<void> schedulePhaseEnd({
    required Phase phase,
    required DateTime at,
    ApproachTarget? target,
    required bool sound,
    required bool vibrate,
  }) async {
    if (!isSupported) return;
    final isApproach = phase == Phase.approach;
    final id = isApproach ? approachAlarmId : restAlarmId;
    final channelId = channelIdFor(approach: isApproach, sound: sound, vibrate: vibrate);
    final soundName = isApproach ? 'approach_done' : 'rest_done';
    final title = isApproach ? 'Approach done' : (phase == Phase.longRest ? 'Long rest done' : 'Rest done');
    final body = isApproach
        ? (target?.description == null || (target?.isEmpty ?? true)
              ? 'That counts. Rest now.'
              : '${target!.description}. That counts. Rest now.')
        : 'Ready when you are.';

    final android = AndroidNotificationDetails(
      channelId,
      isApproach ? 'Approach finished' : 'Rest finished',
      channelDescription: isApproach
          ? 'Plays when an approach interval ends.'
          : 'Plays when a rest interval ends.',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: sound,
      sound: sound ? RawResourceAndroidNotificationSound(soundName) : null,
      enableVibration: vibrate,
      autoCancel: true,
      color: _accent,
    );
    final darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: sound,
      presentBanner: true,
      presentList: true,
      sound: sound ? '$soundName.wav' : null,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    final exact = _caps.exactAlarmsAllowed;
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: NotificationDetails(android: android, iOS: darwin, macOS: darwin),
        androidScheduleMode: exact ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: isApproach ? payloadApproach : payloadRest,
      );
    } catch (e, st) {
      debugPrint('schedulePhaseEnd failed: $e\n$st');
    }
  }

  @override
  Future<void> cancelScheduled() async {
    if (!isSupported) return;
    try {
      await _plugin.cancel(id: approachAlarmId);
      await _plugin.cancel(id: restAlarmId);
    } catch (e) {
      debugPrint('cancelScheduled failed: $e');
    }
  }

  @override
  Future<void> showOngoing({
    required String runId,
    required Phase phase,
    required DateTime endsAt,
    ApproachTarget? target,
    DateTime? nextEndsAt,
    Phase? nextPhase,
    DateTime? pausedAt,
  }) async {
    if (!kIsWeb && Platform.isIOS) {
      await _liveActivity.show(
        runId: runId,
        phase: phase,
        title: target == null || target.isEmpty ? phase.label : target.description,
        endsAt: endsAt,
        nextEndsAt: nextEndsAt,
        nextPhase: nextPhase,
        pausedAt: pausedAt,
      );
      return;
    }
    // Android: an ongoing, silently updated notification.
    final android = _android;
    if (android == null) return;
    final isApproach = phase == Phase.approach;
    final hasTarget = target != null && !target.isEmpty;
    final title = isApproach
        ? (hasTarget ? 'Approach: ${target.description}' : 'Approach')
        : (nextPhase == Phase.approach && hasTarget
            ? '${phase.label} before: ${target.description}'
            : phase.label);
    final paused = pausedAt != null;
    final body = paused
        ? 'Paused, ${_short(endsAt.difference(pausedAt))} left'
        : 'Ends at ${DateFormat('HH:mm').format(endsAt.toLocal())}';
    final msUntilEnd = endsAt.difference(clock.now()).inMilliseconds;
    try {
      await _plugin.show(
        id: ongoingId,
        title: title,
        body: body,
        payload: payloadOngoing,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            ongoingChannelId,
            'Running timer',
            channelDescription: 'Shows the countdown while a timer is running.',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
            // Frozen text while paused; a live chronometer otherwise.
            showWhen: !paused,
            when: paused ? null : endsAt.millisecondsSinceEpoch,
            usesChronometer: !paused,
            chronometerCountDown: !paused,
            // Removed by the system at the end of the phase, so it never
            // counts into negative time if the app is frozen or killed.
            timeoutAfter: paused ? null : (msUntilEnd < 1000 ? 1000 : msUntilEnd),
            category: AndroidNotificationCategory.progress,
            color: _accent,
          ),
        ),
      );
    } catch (e) {
      debugPrint('showOngoing failed: $e');
    }
  }

  static String _short(Duration d) {
    final total = d.isNegative ? 0 : d.inSeconds;
    final m = total ~/ 60;
    final sec = total % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> hideOngoing() async {
    if (!kIsWeb && Platform.isIOS) {
      await _liveActivity.hide();
      return;
    }
    if (_android == null) return;
    try {
      await _plugin.cancel(id: ongoingId);
    } catch (e) {
      debugPrint('hideOngoing failed: $e');
    }
  }
}
