import 'package:depress_o_buster/app.dart';
import 'package:depress_o_buster/data/db/database.dart';
import 'package:depress_o_buster/data/repositories/preset_repository.dart';
import 'package:depress_o_buster/data/repositories/session_repository.dart';
import 'package:depress_o_buster/data/repositories/task_repository.dart';
import 'package:depress_o_buster/data/seed/seed_data.dart';
import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/alarms/alarm_service.dart';
import 'package:depress_o_buster/services/audio/sound_service.dart';
import 'package:depress_o_buster/services/providers.dart';
import 'package:depress_o_buster/services/settings/settings_service.dart';
import 'package:depress_o_buster/ui/timer/timer_view.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SilentSoundService extends SoundService {
  @override
  Future<void> play(SoundKind kind, {double volume = 0.7}) async {}

  @override
  Future<void> haptic(SoundKind kind) async {}
}

class _QuietAlarmService extends NoopAlarmService {
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
}

class _Harness {
  _Harness(this.db, this.settingsService);

  final AppDatabase db;
  final SettingsService settingsService;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(settingsService),
          initialSettingsProvider.overrideWithValue(await settingsService.load()),
          alarmServiceProvider.overrideWithValue(_QuietAlarmService()),
          soundServiceProvider.overrideWithValue(_SilentSoundService()),
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
  return _Harness(db, settingsService);
}

/// From the Tasks tab: open [task], tap [step] and start it with the sheet's
/// [button] (which names the round), then let the sheet and the detail route
/// finish leaving and get past the controller's settle window.
Future<void> _startStep(
  WidgetTester tester, {
  required String task,
  required String step,
  required String button,
}) async {
  await tester.tap(find.text('Tasks'));
  await tester.pump();
  await tester.pump();
  await tester.tap(find.text(task));
  await tester.pump();
  await tester.pump();
  await tester.tap(find.text(step));
  await tester.pumpAndSettle();
  await tester.tap(find.text(button));
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Let the whole round run out on its own: the phase that is on now, then
/// the one that follows it.
Future<void> _runOut(WidgetTester tester, List<Duration> phases) async {
  for (final d in phases) {
    await tester.pump(d);
    await tester.pump();
    await tester.pump();
  }
}

const _shower1 = 'Think about a shower for 1 minute';
const _shower2 = 'Say out loud "a shower would be nice"';

void main() {
  // Each test opens its own in-memory database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('LadderLogic.stepAfter', () {
    LadderStep step(String id, int position) => LadderStep(id: id, taskId: 't', position: position, text: id);
    final ladder = [step('a', 0), step('b', 1), step('c', 2)];

    test('the step after the one with the id; the id wins over a stale position', () {
      expect(LadderLogic.stepAfter(ladder, id: 'a', position: 0)?.id, 'b');
      expect(LadderLogic.stepAfter(ladder, id: 'b', position: 7)?.id, 'c');
    });

    test('nothing after the last step, or for a step nobody can find', () {
      expect(LadderLogic.stepAfter(ladder, id: 'c', position: 2), isNull);
      expect(LadderLogic.stepAfter(ladder, id: 'gone'), isNull);
      expect(LadderLogic.stepAfter(const [], id: 'a', position: 0), isNull);
    });

    test('a load that failed still offers the plain controls; only a first load waits', () {
      const target = ApproachTarget(taskId: 't', taskTitle: 'Shower', rungId: 'a', rungPosition: 0, rungText: 'a');
      final task = Task(id: 't', title: 'Shower', createdAt: DateTime(2026));
      expect(nextStepFor(target: target, tasks: const AsyncValue.loading(), ladder: const AsyncValue.loading()).known, isFalse);
      expect(nextStepFor(target: target, tasks: AsyncValue.data([task]), ladder: const AsyncValue.loading()).known, isFalse);
      final failed = nextStepFor(
        target: target,
        tasks: AsyncValue.data([task]),
        ladder: AsyncValue.error(StateError('db'), StackTrace.empty),
      );
      expect(failed.known, isTrue);
      expect(failed.next, isNull);
      final gone = nextStepFor(target: target, tasks: const AsyncValue.data([]), ladder: AsyncValue.data(ladder));
      expect(gone.known, isTrue);
      expect(gone.next, isNull);
      final found = nextStepFor(target: target, tasks: AsyncValue.data([task]), ladder: AsyncValue.data(ladder));
      expect(found.next?.step.id, 'b');
    });

    test('falls back to the position when the id is gone', () {
      // The done step was removed: the step now at its old place is next.
      expect(LadderLogic.stepAfter(ladder, id: 'gone', position: 0)?.id, 'a');
      expect(LadderLogic.stepAfter(ladder, id: 'gone', position: 2)?.id, 'c');
      expect(LadderLogic.stepAfter(ladder, id: 'gone', position: 9), isNull);
    });
  });

  testWidgets('after a step, the next one is one tap away and gets its own rest', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    await _startStep(
      tester,
      task: 'Shower',
      step: _shower1,
      button: 'Rest 10 min, then a 1 min approach here',
    );
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text(_shower1), findsOneWidget);

    // The rest runs out, the step starts on its own and runs out too.
    await _runOut(tester, const [Duration(minutes: 10), Duration(minutes: 1)]);
    expect(find.text('Approach complete.'), findsOneWidget);
    expect(find.text('Next step'), findsOneWidget);
    expect(find.text('Up next: $_shower2'), findsOneWidget);
    expect(find.text('Another round'), findsOneWidget);
    expect(find.text('Done for now'), findsOneWidget);
    expect(find.textContaining('!'), findsNothing);

    // Taps settle for 700 ms after a phase ended by itself.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.text('Next step'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest'), findsOneWidget, reason: 'the next step opens with its own rest');
    expect(find.text(_shower2), findsOneWidget, reason: 'the heading names the next step');
    expect(find.text('10:00'), findsOneWidget, reason: 'step 2 rests one unit: the 10 min Settings rest');
    expect(find.text('Next step'), findsNothing);

    // Stop here; the log keeps the two steps apart.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Stop'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    final sessions = await h.read(() => SessionRepository(h.db).watchRecent().first, tester);
    expect(sessions.map((s) => s.rungText), [_shower2, _shower1, _shower1]);
    expect(sessions.map((s) => s.phase), [Phase.rest, Phase.approach, Phase.rest]);
    expect(sessions[1].runId, sessions[2].runId, reason: 'rest and step of the first round belong together');
    expect(sessions.first.runId, isNot(sessions[1].runId), reason: 'the next step is a new run');
    expect(sessions.first.rungPosition, 1);
    await h.tearDown(tester);
  });

  testWidgets('the last step of a ladder offers no next step', (tester) async {
    final h = await _harness();
    // At the top of the Tasks tab, so no scrolling is needed to reach it.
    await TaskRepository(h.db).createTask(
      'Kettle',
      ladder: const [
        MicroStep('Look at the kettle', suggestedDuration: Duration(minutes: 1)),
        MicroStep('Fill the kettle', suggestedDuration: Duration(minutes: 1)),
      ],
      sortOrder: -1,
    );
    await h.pump(tester);
    await _startStep(
      tester,
      task: 'Kettle',
      step: 'Fill the kettle',
      button: 'Rest 10 min, then a 1 min approach here',
    );
    await _runOut(tester, const [Duration(minutes: 10), Duration(minutes: 1)]);
    expect(find.text('Approach complete.'), findsOneWidget);
    expect(find.text('Next step'), findsNothing);
    expect(find.textContaining('Up next'), findsNothing);
    expect(find.text('Another round'), findsOneWidget);
    expect(find.text('Done for now'), findsOneWidget);
    await tester.tap(find.text('Done for now'));
    await tester.pump();
    await h.tearDown(tester);
  });

  testWidgets('approach first with the rest by hand: the next step is offered once the rest is done', (tester) async {
    final h = await _harness(settings: const AppSettings(restFirst: false, autoStartNext: false));
    await h.pump(tester);
    await _startStep(
      tester,
      task: 'Shower',
      step: _shower1,
      button: 'Start a 1 min approach here, then rest 10 min',
    );
    expect(find.text('Approach'), findsOneWidget);
    await _runOut(tester, const [Duration(minutes: 1)]);
    expect(find.text('Approach complete.'), findsOneWidget);
    expect(find.text('Start rest'), findsOneWidget);
    expect(find.text('Next step'), findsNothing, reason: 'the rest is still to come');

    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.text('Start rest'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest'), findsOneWidget);
    await _runOut(tester, const [Duration(minutes: 10)]);
    expect(find.text('Rest complete.'), findsOneWidget);
    expect(find.text('Next step'), findsOneWidget);
    expect(find.text('Up next: $_shower2'), findsOneWidget);
    await tester.tap(find.text('Done for now'));
    await tester.pump();
    await h.tearDown(tester);
  });
}
