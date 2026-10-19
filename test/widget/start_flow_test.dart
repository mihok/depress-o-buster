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
    Phase? next,
    bool preparing = false,
  }) async => calls.add('schedule:${phase.name}');

  @override
  Future<void> cancelScheduled() async => calls.add('cancel');

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

  testWidgets('open the app, one tap: the rest to get ready runs first, then the step', (tester) async {
    final h = await _harness();
    await h.pump(tester);

    expect(find.text('Sit up for 2 minutes'), findsOneWidget);
    expect(find.text('after 10 min of rest to get ready'), findsOneWidget);

    await tester.tap(find.text('Sit up for 2 minutes'));
    await tester.pump();
    await tester.pump();

    // The round opens with the rest; the step's alarm is already scheduled.
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Sit up for 2 minutes'), findsOneWidget, reason: 'the step is shown as what the rest prepares for');
    expect(find.text('Time to get ready. The chime says when the step starts.'), findsOneWidget);
    expect(h.alarms.calls, containsAllInOrder(['cancel', 'schedule:rest', 'schedule:approach', 'ongoing:rest']));

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('9:59'), findsOneWidget);

    // More time to get ready, without judgement.
    await tester.tap(find.text('+2 min'));
    await tester.pump();
    expect(find.text('11:59'), findsOneWidget);

    // Ready now: the step starts at once; the rest is logged as completed.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.text('Start the step'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Approach'), findsOneWidget);
    expect(find.text('2:00'), findsOneWidget);
    expect(h.alarms.calls.last, 'ongoing:approach');
    expect(find.textContaining('+'), findsWidgets, reason: 'XP feedback line for the rest');
    expect(find.textContaining('Your first one'), findsOneWidget);
    // The second tap of a double tap lands on "Done early": ignored.
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Done early'));
    await tester.pump();
    expect(find.text('Approach'), findsOneWidget, reason: 'taps settle for 700 ms after a phase change');

    // Finish the step early: completed, and the round is done.
    await tester.pump(const Duration(seconds: 30));
    await tester.tap(find.text('Done early'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Approach complete.'), findsOneWidget);
    expect(find.text('Another round'), findsOneWidget);

    await tester.tap(find.text('Done for now'));
    await tester.pump();
    expect(find.text('Sit up for 2 minutes'), findsOneWidget);

    final sessions = await h.read(() => SessionRepository(h.db).watchRecent().first, tester);
    expect(sessions.map((s) => s.phase), [Phase.approach, Phase.rest]);
    expect(sessions.last.outcome, SessionOutcome.snoozed, reason: 'the extended rest');
    expect(sessions.first.outcome, SessionOutcome.completed);
    expect(sessions.first.rungText, 'Sit up for 2 minutes');
    expect(sessions.first.rungId, isNotNull, reason: 'the seeded step is matched exactly');
    expect(sessions.first.taskTitle, 'Just sit up');
    expect(sessions.first.xpEarned, greaterThan(0));
    expect(sessions.first.runId, sessions.last.runId, reason: 'rest and step belong to one round');
    final progress = await h.read(() => ProgressRepository(h.db).get(), tester);
    expect(progress.totalXp, sessions.fold<int>(0, (sum, s) => sum + s.xpEarned));
    expect(progress.totalCompletedIntervals, 2);
    expect(
      h.sound.played,
      [SoundKind.restDone, SoundKind.approachDone],
      reason: 'manual finishes chime in-app',
    );

    await h.tearDown(tester);
  });

  testWidgets('the classic order is one switch away: approach first, then rest', (tester) async {
    final h = await _harness(settings: const AppSettings(restFirst: false));
    await h.pump(tester);
    expect(find.text('then rest for 10 min'), findsOneWidget);
    await tester.tap(find.text('Sit up for 2 minutes'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Approach'), findsOneWidget);
    expect(find.text('2:00'), findsOneWidget);
    expect(h.alarms.calls, containsAllInOrder(['cancel', 'schedule:approach', 'schedule:rest', 'ongoing:approach']));
    await tester.pump(const Duration(seconds: 1));
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
    await tester.pump(const Duration(minutes: 10));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest complete.'), findsOneWidget);
    await tester.tap(find.text('Done for now'));
    await tester.pump();
    final sessions = await h.read(() => SessionRepository(h.db).watchRecent().first, tester);
    expect(sessions.map((s) => s.phase), [Phase.rest, Phase.approach]);
    await h.tearDown(tester);
  });

  testWidgets('a 30-second approach from the ratio button is valid', (tester) async {
    final h = await _harness(
      settings: const AppSettings(approach: Duration(seconds: 30), rest: Duration(minutes: 1)),
    );
    await h.pump(tester);
    // The hero illustration pushes the ratio button below the 600 px test
    // viewport, and a lazy list does not build what is off screen.
    await tester.scrollUntilVisible(
      find.text('Rest 1 min, then a 30 sec approach'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(find.text('Rest 1 min, then a 30 sec approach'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('1:00'), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
    await tester.pump();
    await tester.pump();
    expect(find.text('Approach'), findsOneWidget);
    expect(find.text('0:30'), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    await tester.pump();
    expect(find.text('Approach complete.'), findsOneWidget);
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
    expect(sessions.single.phase, Phase.rest, reason: 'stopped during the rest to get ready');
    expect(sessions.single.xpEarned, greaterThan(0));
    expect(find.textContaining('missed'), findsNothing);
    expect(find.textContaining('broken'), findsNothing);
    await h.tearDown(tester);
  });

  testWidgets('a paused rest before the step still offers the step', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    await tester.tap(find.text('Sit up for 2 minutes'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Start the step'), findsOneWidget, reason: 'ready now works while paused too');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.text('Start the step'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Approach'), findsOneWidget);
    expect(find.text('2:00'), findsOneWidget);
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Stop'));
    await tester.pump();
    await tester.pump();
    await h.tearDown(tester);
  });

  testWidgets('a running timer survives a restart', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    await tester.tap(find.text('Sit up for 2 minutes'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('9:50'), findsOneWidget);

    // Simulate process death: new widget tree, same storage.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await h.pump(tester);
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('9:45'), findsOneWidget);

    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Stop'));
    await tester.pump();
    await tester.pump();
    await h.tearDown(tester);
  });

  testWidgets('tasks tab lists the starter ladders and a step can be started', (tester) async {
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
    // The step length card above the list pushes the fifth step below the
    // 600 px test viewport, and a lazy list does not build what is off screen.
    await tester.scrollUntilVisible(
      find.text('Sit next to the pile for 5 minutes'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(find.text('Sit next to the pile for 5 minutes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rest first, then a 5 min approach here'));
    // Let the sheet and the detail route finish leaving (about 300 ms),
    // one frame per 100 ms so the finished routes are actually removed, and
    // get past the controller's settle window before tapping Stop.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Rest'), findsOneWidget, reason: 'the rest to get ready comes first');
    expect(find.textContaining(RegExp(r'^(10:00|9:59)$')), findsOneWidget);
    expect(find.text('Sit next to the pile for 5 minutes'), findsOneWidget);
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Stop'));
    await tester.pump();
    await tester.pump();
    await h.tearDown(tester);
  });
}
