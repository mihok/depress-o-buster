import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/approach_target.dart';
import '../../domain/entities/phase.dart';
import 'alarm_service.dart';

/// Alarms via `flutter_local_notifications`.
///
/// Android: exact alarms in `alarmClock` mode (the most reliable mode for a
/// user-visible timer; `USE_EXACT_ALARM` is declared because this is a timer
/// app), each phase on its own channel with its own gentle sound, plus an
/// ongoing low-importance notification that counts down with a chronometer.
/// iOS: a scheduled notification with a bundled sound at the time-sensitive
/// interruption level. There is no ongoing notification on iOS.
/// See docs/PLATFORM_ALARMS.md for the limitations.
class LocalNotificationsAlarmService implements AlarmService {
  LocalNotificationsAlarmService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
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

  @override
  bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux);

  @override
  AlarmCapabilities get capabilities => _caps;

  @override
  Stream<String?> get tapped => _taps.stream;

  AndroidFlutterLocalNotificationsPlugin? get _android => !kIsWeb && Platform.isAndroid
      ? _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      : null;

  @override
  Future<void> init() async {
    if (!isSupported || _initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin, macOS: darwin, linux: linux),
      onDidReceiveNotificationResponse: (response) => _taps.add(response.payload),
    );
    await _createChannels();
    _initialized = true;
    await ensurePermissions(request: false);
  }

  Future<void> _createChannels() async {
    final android = _android;
    if (android == null) return;
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        approachChannelId,
        'Approach finished',
        description: 'Plays when an approach interval ends.',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('approach_done'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        restChannelId,
        'Rest finished',
        description: 'Plays when a rest interval ends.',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('rest_done'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
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
        _caps = const AlarmCapabilities(notificationsGranted: true, exactAlarmsAllowed: true);
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
    final channelId = isApproach ? approachChannelId : restChannelId;
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
      sound: RawResourceAndroidNotificationSound(soundName),
      enableVibration: vibrate,
      autoCancel: true,
    );
    final darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: sound,
      presentBanner: true,
      presentList: true,
      sound: sound ? '$soundName.wav' : null,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    const linux = LinuxNotificationDetails(urgency: LinuxNotificationUrgency.critical);

    final exact = _caps.exactAlarmsAllowed;
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: NotificationDetails(android: android, iOS: darwin, macOS: darwin, linux: linux),
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
    required Phase phase,
    required DateTime endsAt,
    ApproachTarget? target,
  }) async {
    // Only Android has a notion of an ongoing, silently updated notification.
    final android = _android;
    if (android == null) return;
    final isApproach = phase == Phase.approach;
    final title = isApproach
        ? (target == null || target.isEmpty ? 'Approach' : 'Approach: ${target.description}')
        : phase.label;
    final body = 'Ends at ${DateFormat('HH:mm').format(endsAt.toLocal())}';
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
            showWhen: true,
            when: endsAt.millisecondsSinceEpoch,
            usesChronometer: true,
            chronometerCountDown: true,
            category: AndroidNotificationCategory.progress,
          ),
        ),
      );
    } catch (e) {
      debugPrint('showOngoing failed: $e');
    }
  }

  @override
  Future<void> hideOngoing() async {
    if (_android == null) return;
    try {
      await _plugin.cancel(id: ongoingId);
    } catch (e) {
      debugPrint('hideOngoing failed: $e');
    }
  }
}
