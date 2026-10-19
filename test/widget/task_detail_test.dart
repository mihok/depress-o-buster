import 'package:depress_o_buster/core/format.dart';
import 'package:depress_o_buster/core/theme.dart';
import 'package:depress_o_buster/data/db/database.dart';
import 'package:depress_o_buster/data/repositories/task_repository.dart';
import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/providers.dart';
import 'package:depress_o_buster/services/settings/settings_service.dart';
import 'package:depress_o_buster/ui/tasks/task_detail_screen.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _ladder = [
  MicroStep('Think about a shower', suggestedDuration: Duration(minutes: 1)),
  MicroStep('Stand in the bathroom', suggestedDuration: Duration(minutes: 2)),
  MicroStep('Turn the water on', suggestedDuration: Duration(seconds: 30)),
  MicroStep('Step in', suggestedDuration: Duration(minutes: 5)),
  MicroStep('Wash up'),
];

class _Harness {
  _Harness(this.db, this.repo, this.task, this.settingsService);

  final AppDatabase db;
  final TaskRepository repo;
  final Task task;
  final SettingsService settingsService;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(settingsService),
          initialSettingsProvider.overrideWithValue(const AppSettings()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: TaskDetailScreen(taskId: task.id),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  /// Drift queries awaited directly in the fake-async test zone can stall
  /// after a stream was cancelled, so verification reads run with real async.
  Future<List<LadderStep>> ladder(WidgetTester tester) async =>
      (await tester.runAsync(() => repo.ladder(task.id)))!;

  Future<void> tearDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    // The in-memory database is not closed on purpose: closing it waits on
    // drift's stream bookkeeping, which does not progress under fake async.
  }
}

Future<_Harness> _harness() async {
  // Synchronous stream close keeps drift from scheduling zero-delay timers
  // that flutter_test would report as pending at the end of the test.
  final db = AppDatabase(
    DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
  );
  final repo = TaskRepository(db);
  final task = await repo.createTask('Shower', ladder: _ladder);
  final settingsService = SettingsService(prefs: InMemoryKeyValueStore(), secrets: InMemorySecretStore());
  await settingsService.save(const AppSettings());
  return _Harness(db, repo, task, settingsService);
}

void main() {
  // Each test opens its own in-memory database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('swiping a step away removes it; Undo brings back the very same step', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    final before = await h.ladder(tester);
    final removed = before[1];
    expect(removed.text, 'Stand in the bathroom');
    expect(find.text('Stand in the bathroom'), findsOneWidget);

    await tester.drag(find.text('Stand in the bathroom'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Stand in the bathroom'), findsNothing);
    expect(find.text('Step removed'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.textContaining('rung'), findsNothing);
    final without = await h.ladder(tester);
    expect(without.map((s) => s.id), [before[0].id, before[2].id, before[3].id, before[4].id]);
    expect(without.map((s) => s.position), [0, 1, 2, 3]);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Stand in the bathroom'), findsOneWidget);
    expect(find.text('Step removed'), findsNothing);
    final restored = await h.ladder(tester);
    expect(restored, before, reason: 'same ids, positions, text and times as before the swipe');
    expect(restored[1].id, removed.id);
    expect(restored[1].position, 1);
    expect(restored[1].suggestedDuration, const Duration(minutes: 2));
    // The list numbers follow the restored order (the fifth tile sits below
    // the 600 px test viewport and is not built).
    final numbers = tester.widgetList<Text>(find.descendant(of: find.byType(CircleAvatar), matching: find.byType(Text)));
    expect(numbers.map((t) => t.data), ['1', '2', '3', '4']);

    await h.tearDown(tester);
  });

  testWidgets('the step length slider previews live, saves on release and returns to ×1', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    // Every step shows its rest (1, 1, 2, 3, 5 units of the 10 min Settings rest) and its time.
    expect(find.text('Rest 10 min · 1 min'), findsOneWidget);
    expect(find.text('Rest 10 min · 2 min'), findsOneWidget);
    expect(find.text('Rest 20 min · 30 sec'), findsOneWidget);
    expect(find.text('Rest 30 min · 5 min'), findsOneWidget);
    // The sliders fold out of the way until asked for.
    expect(find.byType(Slider), findsNothing);
    expect(find.textContaining('Rest unit 10 min · rests 10, 10, 20, 30, 50 min'), findsOneWidget);
    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();
    expect(find.text('Step length'), findsOneWidget);
    expect(find.text('×1'), findsOneWidget);
    expect(find.text('Shorter'), findsNWidgets(2), reason: 'step length and rest unit sliders');
    expect(find.text('Longer'), findsNWidgets(2));
    final sliders = find.byType(Slider);
    expect(sliders, findsNWidgets(2));
    expect(tester.getSize(sliders.first).height, greaterThanOrEqualTo(AppTheme.minTouchTarget));

    // Hold the step length thumb (×1 sits in the middle) and move right.
    final slider = tester.getRect(sliders.first);
    final gesture = await tester.startGesture(slider.center);
    await tester.pump();
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump();

    expect(find.text('×1'), findsNothing, reason: 'the label follows the drag');
    expect(find.textContaining(RegExp(r'^×\d(\.\d\d?)?$')), findsOneWidget, reason: 'a readable factor');
    expect(find.text('Rest 10 min · 1 min'), findsNothing, reason: '1 min shown longer while held');
    expect(find.text('Rest 10 min · 4 min'), findsOneWidget, reason: '2 min shown roughly doubled');
    final held = await h.ladder(tester);
    expect(held[1].suggestedDuration, const Duration(minutes: 2), reason: 'nothing is saved while held');

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('×1'), findsOneWidget, reason: 'the slider is relative and rests at ×1');
    final saved = await h.ladder(tester);
    expect(saved[1].suggestedDuration!, greaterThan(const Duration(minutes: 2)));
    expect(saved[3].suggestedDuration!, greaterThan(const Duration(minutes: 5)));
    expect(saved[4].suggestedDuration, isNull, reason: 'an untimed step stays untimed');
    expect(saved.map((s) => s.id), held.map((s) => s.id));
    expect(find.textContaining('step times changed'), findsOneWidget);

    await h.tearDown(tester);
  });

  testWidgets('the rest unit slider rescales every rest and saves the unit on the task', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();
    expect(find.text('Rest unit'), findsOneWidget);

    final slider = tester.getRect(find.byType(Slider).last);
    final gesture = await tester.startGesture(slider.center);
    await tester.pump();
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();
    expect(find.text('Rest 10 min · 1 min'), findsNothing, reason: 'rests shrink live while held');
    await gesture.up();
    await tester.pumpAndSettle();

    final task = await tester.runAsync(() => h.repo.getTask(h.task.id));
    expect(task!.restUnit, isNotNull);
    expect(task.restUnit!, lessThan(const Duration(minutes: 10)));
    expect(find.textContaining('Rest unit is now'), findsOneWidget);
    // The tiles and the summary follow the saved unit.
    final first = LadderRests.restFor(unit: task.restUnit!, position: 0);
    expect(find.text('Rest ${formatWords(first)} · 1 min'), findsOneWidget);
    expect(find.textContaining('Rest unit ${formatWords(task.restUnit!)} · rests'), findsOneWidget);

    await h.tearDown(tester);
  });

  testWidgets('a single step\'s time can be set to the second from the edit dialog', (tester) async {
    final h = await _harness();
    await h.pump(tester);

    await tester.ensureVisible(find.text('Turn the water on'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn the water on'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    final dialog = find.byType(AlertDialog);
    expect(find.text('Edit step'), findsOneWidget);
    expect(find.text('Suggested time'), findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text('30 sec')), findsOneWidget);

    await tester.tap(find.text('Suggested time'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'min'), '0');
    await tester.enterText(find.widgetWithText(TextField, 'sec'), '45');
    // Two dialogs are open; the time picker's Save is the topmost one.
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await tester.pumpAndSettle();
    expect(find.descendant(of: dialog, matching: find.textContaining('45 sec')), findsOneWidget, reason: 'the tile shows the picked time');

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Edit step'), findsNothing);
    expect(find.textContaining('45 sec'), findsOneWidget, reason: 'the step tile shows the new time');
    final ladder = await h.ladder(tester);
    expect(ladder[2].text, 'Turn the water on');
    expect(ladder[2].suggestedDuration, const Duration(seconds: 45));

    await h.tearDown(tester);
  });

  testWidgets('the Remove button in the step menu also offers Undo', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    final before = await h.ladder(tester);

    await tester.ensureVisible(find.text('Step in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Step in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Step in'), findsNothing);
    expect(find.text('Step removed'), findsOneWidget);
    expect((await h.ladder(tester)).map((s) => s.text), ['Think about a shower', 'Stand in the bathroom', 'Turn the water on', 'Wash up']);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Step in'), findsOneWidget);
    expect(await h.ladder(tester), before);

    await h.tearDown(tester);
  });
}
