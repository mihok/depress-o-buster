import 'package:depress_o_buster/app.dart';
import 'package:depress_o_buster/data/db/database.dart';
import 'package:depress_o_buster/data/repositories/preset_repository.dart';
import 'package:depress_o_buster/data/repositories/progress_repository.dart';
import 'package:depress_o_buster/data/repositories/session_repository.dart';
import 'package:depress_o_buster/data/repositories/task_repository.dart';
import 'package:depress_o_buster/data/seed/seed_data.dart';
import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/alarms/alarm_service.dart';
import 'package:depress_o_buster/services/audio/sound_service.dart';
import 'package:depress_o_buster/services/providers.dart';
import 'package:depress_o_buster/services/settings/settings_service.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SilentSoundService extends SoundService {
  final List<SoundKind> played = [];

  @override
  Future<void> play(SoundKind kind, {double volume = 0.7}) async => played.add(kind);

  @override
  Future<void> haptic(SoundKind kind) async {}
}

class _RecordingAlarmService extends NoopAlarmService {
  final List<String> calls = [];

  @override
  bool get isSupported => true;

  @override
  AlarmCapabilities get capabilities =>
      const AlarmCapabilities(notificationsGranted: true, exactAlarmsAllowed: true);

  @override
  Future<AlarmCapabilities> ensurePermissions({bool request = true}) async => capabilities;

  @override
  Future<void> schedulePhaseEnd({
    required Phase phase,
    required DateTime at,
    ApproachTarget? target,
    required bool sound,
    required bool vibrate,
  }) async => calls.add('schedule:${phase.name}');

  @override
  Future<void> cancelScheduled() async => calls.add('cancel');

  @override
  Future<void> showOngoing({
    required String runId,
    required Phase phase,
    required DateTime endsAt,
    ApproachTarget? target,
    DateTime? restEndsAt,
  }) async => calls.add('ongoing:${phase.name}');

  @override
  Future<void> hideOngoing() async => calls.add('hide');
}

class _Harness {
  _Harness(this.db, this.settingsService, this.alarms, this.sound);

  final AppDatabase db;
  final SettingsService settingsService;
  final _RecordingAlarmService alarms;
  final _SilentSoundService sound;

  Future<void> pump(WidgetTester tester, {AppSettings? settings}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(settingsService),
          initialSettingsProvider.overrideWithValue(settings ?? await settingsService.load()),
          alarmServiceProvider.overrideWithValue(alarms),
          soundServiceProvider.overrideWithValue(sound),
        ],
        child: const DepressOBusterApp(),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  /// Drift queries awaited directly in the fake-async test zone can stall
  /// after a stream was cancelled, so verification reads run with real async.
  Future<T> read<T>(Future<T> Function() query, WidgetTester tester) async =>
      (await tester.runAsync(query)) as T;

  Future<void> tearDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    // The in-memory database is not closed on purpose: closing it waits on
    // drift's stream bookkeeping, which does not progress under fake async.
  }
}

Future<_Harness> _harness({AppSettings settings = const AppSettings()}) async {
  // Synchronous stream close keeps drift from scheduling zero-delay timers
  // that flutter_test would report as pending at the end of the test.
  final db = AppDatabase(
    DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
  );
  await SeedData.seedIfEmpty(tasks: TaskRepository(db), presets: PresetRepository(db));
  final settingsService = SettingsService(prefs: InMemoryKeyValueStore(), secrets: InMemorySecretStore());
  await settingsService.save(settings);
  return _Harness(db, settingsService, _RecordingAlarmService(), _SilentSoundService());
}

void main() {
  // Each test opens its own in-memory database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('open the app, one tap, a 2-minute approach is running with an alarm', (tester) async {
    final h = await _harness();
    await h.pump(tester);

    expect(find.text('Sit up for 2 minutes'), findsOneWidget);
    expect(find.text('then rest for 10 min'), findsOneWidget);

    await tester.tap(find.text('Sit up for 2 minutes'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Approach'), findsOneWidget);
    expect(find.text('2:00'), findsOneWidget);
    expect(find.text('Sit up for 2 minutes'), findsOneWidget, reason: 'the rung is shown as the target');
    expect(h.alarms.calls, containsAllInOrder(['cancel', 'schedule:approach', 'ongoing:approach']));

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1:59'), findsOneWidget);

    // Snooze extends without judgement.
    await tester.tap(find.text('+2 min'));
    await tester.pump();
    expect(find.text('3:59'), findsOneWidget);

    // Finish early: logged as completed, rest starts on its own.
    await tester.tap(find.text('Done early'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    // The second tap of a double tap lands on "End rest early": ignored.
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('End rest early'));
    await tester.pump();
    expect(find.text('Rest'), findsOneWidget, reason: 'rest is sacred; taps settle for 700 ms');
    expect(h.alarms.calls.last, 'ongoing:rest');
    expect(find.textContaining('+'), findsWidgets, reason: 'XP feedback line');
    expect(find.textContaining('Your first one'), findsOneWidget);

    // Rest is counted down with the same respect.
    await tester.pump(const Duration(minutes: 10));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest complete.'), findsOneWidget);
    expect(find.text('Another round'), findsOneWidget);

    await tester.tap(find.text('Done for now'));
    await tester.pump();
    expect(find.text('Sit up for 2 minutes'), findsOneWidget);

    final sessions = await h.read(() => SessionRepository(h.db).watchRecent().first, tester);
    expect(sessions.map((s) => s.phase), [Phase.rest, Phase.approach]);
    expect(sessions.last.outcome, SessionOutcome.snoozed);
    expect(sessions.last.rungText, 'Sit up for 2 minutes');
    expect(sessions.last.rungId, isNotNull, reason: 'the seeded rung is matched exactly');
    expect(sessions.last.taskTitle, 'Just sit up');
    expect(sessions.last.xpEarned, greaterThan(0));
    final progress = await h.read(() => ProgressRepository(h.db).get(), tester);
    expect(progress.totalXp, sessions.fold<int>(0, (sum, s) => sum + s.xpEarned));
    expect(progress.totalCompletedIntervals, 2);
    expect(
      h.sound.played,
      [SoundKind.approachDone],
      reason: 'a manual finish chimes in-app; the automatic rest end is left to the OS alarm',
    );

    await h.tearDown(tester);
  });

  testWidgets('a 30-second approach from the ratio button is valid', (tester) async {
    final h = await _harness(
      settings: const AppSettings(approach: Duration(seconds: 30), rest: Duration(minutes: 1)),
    );
    await h.pump(tester);
    expect(find.text('Start a 30 sec approach'), findsOneWidget);
    await tester.tap(find.text('Start a 30 sec approach'));
    await tester.pump();
    await tester.pump();
    expect(find.text('0:30'), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('1:00'), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest complete.'), findsOneWidget);
    await tester.tap(find.text('Done for now'));
    await tester.pump();
    await h.tearDown(tester);
  });

  testWidgets('stopping is neutral and still logged', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    await tester.tap(find.text('Sit up for 2 minutes'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 20));
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    expect(find.text('Starting still counts. It is logged, nothing is lost.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Stop'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Sit up for 2 minutes'), findsOneWidget, reason: 'back on the start view');
    final sessions = await h.read(() => SessionRepository(h.db).watchRecent().first, tester);
    expect(sessions.single.outcome, SessionOutcome.abandoned);
    expect(sessions.single.actual, const Duration(seconds: 20));
    expect(sessions.single.xpEarned, greaterThan(0));
    expect(find.textContaining('missed'), findsNothing);
    expect(find.textContaining('broken'), findsNothing);
    await h.tearDown(tester);
  });

  testWidgets('a running timer survives a restart', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    await tester.tap(find.text('Sit up for 2 minutes'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('1:50'), findsOneWidget);

    // Simulate process death: new widget tree, same storage.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await h.pump(tester);
    await tester.pump();
    await tester.pump();
    expect(find.text('Approach'), findsOneWidget);
    expect(find.text('1:45'), findsOneWidget);

    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Stop'));
    await tester.pump();
    await tester.pump();
    await h.tearDown(tester);
  });

  testWidgets('tasks tab lists the starter ladders and a rung can be started', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    await tester.tap(find.text('Tasks'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Laundry'), findsOneWidget);
    await tester.tap(find.text('Laundry'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Think about laundry for 1 minute'), findsOneWidget);
    expect(find.text('Break this down smaller'), findsOneWidget);
    await tester.tap(find.text('Sit next to the pile for 5 minutes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a 5 min approach here'));
    // Let the sheet and the detail route finish leaving (about 300 ms),
    // one frame per 100 ms so the finished routes are actually removed, and
    // get past the controller's settle window before tapping Stop.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Approach'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^(5:00|4:59)$')), findsOneWidget);
    expect(find.text('Sit next to the pile for 5 minutes'), findsOneWidget);
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Stop'));
    await tester.pump();
    await tester.pump();
    await h.tearDown(tester);
  });
}
