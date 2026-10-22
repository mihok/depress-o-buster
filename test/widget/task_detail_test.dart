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
  _Harness(this.db, this.repo, this.task, this.settingsService, this.settings);

  final AppDatabase db;
  final TaskRepository repo;
  final Task task;
  final SettingsService settingsService;
  final AppSettings settings;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(settingsService),
          initialSettingsProvider.overrideWithValue(settings),
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
    // Let any Undo bar time out, so no timer is left pending.
    await tester.pump(const Duration(seconds: 7));
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
  final repo = TaskRepository(db);
  final task = await repo.createTask('Shower', ladder: _ladder);
  final settingsService = SettingsService(prefs: InMemoryKeyValueStore(), secrets: InMemorySecretStore());
  await settingsService.save(settings);
  return _Harness(db, repo, task, settingsService, settings);
}

/// Slide a held thumb by [dx]. In a scroll view the slider's drag recognizer
/// wins the gesture arena only once the touch slop is crossed, and Flutter
/// folds that first move into the drag's start, so the move comes in two
/// parts, as a finger's would.
Future<void> _slide(WidgetTester tester, TestGesture gesture, double dx) async {
  await gesture.moveBy(Offset(dx.sign * 20, 0));
  await tester.pump();
  await gesture.moveBy(Offset(dx - dx.sign * 20, 0));
  await tester.pump();
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
    // Tall enough that the step tiles stay built below the unfolded sliders.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = await _harness();
    await h.pump(tester);
    // Every step shows its rest (1, 1, 2, 3, 5 units of the 10 min Settings rest) and its time.
    expect(find.text('Rest 10 min · Step 1 min'), findsOneWidget);
    expect(find.text('Rest 10 min · Step 2 min'), findsOneWidget);
    expect(find.text('Rest 20 min · Step 30 sec'), findsOneWidget);
    expect(find.text('Rest 30 min · Step 5 min'), findsOneWidget);
    // The sliders fold out of the way until asked for.
    expect(find.byType(Slider), findsNothing);
    expect(find.text('Rest unit 10 min, from Settings'), findsOneWidget);
    expect(find.textContaining('then 2 hr 10 min from step 7 on'), findsNothing, reason: 'the climb is in the fold');
    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Each step has its own rest before it, from its place in the ladder: '
          '10, 10, 20, 30, 50 min, 1 hr 20 min, then 2 hr 10 min from step 7 on.'),
      findsOneWidget,
    );
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
    await _slide(tester, gesture, 120);

    expect(find.text('×1'), findsNothing, reason: 'the label follows the drag');
    expect(find.textContaining(RegExp(r'^×\d(\.\d\d?)?$')), findsOneWidget, reason: 'a readable factor');
    expect(find.text('Rest 10 min · Step 1 min'), findsNothing, reason: '1 min shown longer while held');
    expect(find.textContaining(RegExp(r'^Rest 10 min · Step [3-9] min( 30 sec)?$')), findsOneWidget, reason: '2 min shown longer, rounded to half a minute');
    expect(find.text('Rest 20 min · Step 30 sec'), findsNothing, reason: 'the 30 sec step grows too');
    expect(find.textContaining(RegExp(r'^Rest 20 min · Step ')), findsOneWidget, reason: 'its rest does not move: it belongs to the place');
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
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = await _harness();
    await h.pump(tester);
    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();
    expect(find.text('Rest unit'), findsOneWidget);

    final slider = tester.getRect(find.byType(Slider).last);
    final gesture = await tester.startGesture(slider.center);
    await tester.pump();
    await _slide(tester, gesture, -120);
    expect(find.text('Rest 10 min · Step 1 min'), findsNothing, reason: 'rests shrink live while held');
    await gesture.up();
    await tester.pumpAndSettle();

    final task = await tester.runAsync(() => h.repo.getTask(h.task.id));
    expect(task!.restUnit, isNotNull);
    expect(task.restUnit!, lessThan(const Duration(minutes: 10)));
    expect(find.textContaining('Rest unit is now'), findsOneWidget);
    // The tiles and the summary follow the saved unit.
    final first = LadderRests.restFor(unit: task.restUnit!, position: 0);
    expect(find.text('Rest ${formatWords(first)} · Step 1 min'), findsOneWidget);
    expect(find.text('Rest unit ${formatWords(task.restUnit!)}, this task\'s own'), findsOneWidget);
    expect(find.text('Use the rest from Settings again'), findsOneWidget);

    await h.tearDown(tester);
  });

  testWidgets('releases within six seconds share one Undo that goes back to before the first', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = await _harness();
    await h.pump(tester);
    final original = (await h.ladder(tester)).map((s) => s.suggestedDuration).toList();
    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();
    final slider = tester.getRect(find.byType(Slider).first);

    Future<void> release() async {
      final gesture = await tester.startGesture(slider.center);
      await tester.pump();
      await _slide(tester, gesture, 120);
      await gesture.up();
      await tester.pumpAndSettle();
    }

    await release();
    expect(find.textContaining('step times changed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await release();
    await tester.pump(const Duration(seconds: 2));
    await release();
    expect(find.text('Undo'), findsOneWidget, reason: 'one bar for the whole burst');
    final scaled = await h.ladder(tester);
    expect(scaled[1].suggestedDuration!, greaterThan(const Duration(minutes: 6)), reason: 'three stretches of 2 min');
    // Six seconds run from the last release, not the first.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await h.ladder(tester)).map((s) => s.suggestedDuration), original, reason: 'back to the hand-set times');
    expect(find.text('Undo'), findsNothing);

    await h.tearDown(tester);
  });

  testWidgets('a slider release never pushes "Step removed" off the screen', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = await _harness();
    await h.pump(tester);
    final before = await h.ladder(tester);

    await tester.drag(find.text('Stand in the bathroom'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Step removed'), findsOneWidget);

    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();
    final slider = tester.getRect(find.byType(Slider).last);
    final gesture = await tester.startGesture(slider.center);
    await tester.pump();
    await _slide(tester, gesture, -120);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Step removed'), findsOneWidget, reason: 'the removed step keeps its way back');
    expect(find.textContaining('Rest unit is now'), findsNothing, reason: 'the slider bar waits its turn');
    expect((await tester.runAsync(() => h.repo.getTask(h.task.id)))!.restUnit, isNotNull, reason: 'saved all the same');

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Stand in the bathroom'), findsOneWidget);
    expect((await h.ladder(tester)).map((s) => s.id), before.map((s) => s.id));

    // Then the slider's own bar has its turn, with its own Undo.
    expect(find.textContaining('Rest unit is now'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await tester.runAsync(() => h.repo.getTask(h.task.id)))!.restUnit, isNull);

    await h.tearDown(tester);
  });

  testWidgets('a task with its own rest unit can follow Settings again', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    expect(find.text('Use the rest from Settings again'), findsNothing);

    await tester.runAsync(() => h.repo.setRestUnit(h.task.id, const Duration(minutes: 5)));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rest unit 5 min, this task\'s own'), findsOneWidget);
    expect(find.text('Rest 5 min · Step 1 min'), findsOneWidget);
    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use the rest from Settings again'));
    await tester.pumpAndSettle();

    expect(find.text('Rest unit 10 min, from Settings'), findsOneWidget);
    expect(find.text('Rest 10 min · Step 1 min'), findsOneWidget);
    expect(find.text('Rest unit follows Settings again'), findsOneWidget);
    expect((await tester.runAsync(() => h.repo.getTask(h.task.id)))!.restUnit, isNull);
    expect(find.text('Use the rest from Settings again'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await tester.runAsync(() => h.repo.getTask(h.task.id)))!.restUnit, const Duration(minutes: 5));
    expect(find.text('Rest unit 5 min, this task\'s own'), findsOneWidget);

    await h.tearDown(tester);
  });

  testWidgets('a release during the bar\'s exit starts a fresh bar with the right way back', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = await _harness();
    await h.pump(tester);
    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();
    final slider = tester.getRect(find.byType(Slider).first);

    Future<void> release() async {
      final gesture = await tester.startGesture(slider.center);
      await tester.pump();
      await _slide(tester, gesture, 120);
      await gesture.up();
      await tester.pumpAndSettle();
    }

    await release();
    final afterFirst = (await h.ladder(tester)).map((s) => s.suggestedDuration).toList();
    // The six seconds run out; the bar is on its way out when the next
    // release lands.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 100));
    await release();
    expect(find.text('Undo'), findsOneWidget, reason: 'a bar of its own, not a word on a bar that is leaving');
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await h.ladder(tester)).map((s) => s.suggestedDuration), afterFirst, reason: 'back to before the second release only');

    await h.tearDown(tester);
  });

  testWidgets('both sliders within six seconds share one Undo that puts both back', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = await _harness();
    await h.pump(tester);
    final original = (await h.ladder(tester)).map((s) => s.suggestedDuration).toList();
    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();

    final rest = await tester.startGesture(tester.getRect(find.byType(Slider).last).center);
    await tester.pump();
    await _slide(tester, rest, -120);
    await rest.up();
    await tester.pumpAndSettle();
    expect(find.textContaining('Rest unit is now'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));

    final step = await tester.startGesture(tester.getRect(find.byType(Slider).first).center);
    await tester.pump();
    await _slide(tester, step, 120);
    await step.up();
    await tester.pumpAndSettle();
    expect(find.text('Step times and rest unit changed'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget, reason: 'one bar, the latest change on it');
    expect((await tester.runAsync(() => h.repo.getTask(h.task.id)))!.restUnit, isNotNull);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await tester.runAsync(() => h.repo.getTask(h.task.id)))!.restUnit, isNull);
    expect((await h.ladder(tester)).map((s) => s.suggestedDuration), original);

    await h.tearDown(tester);
  });

  testWidgets('pushing the rest unit past its longest says so, without an Undo', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = await _harness();
    await tester.runAsync(() => h.repo.setRestUnit(h.task.id, LadderRests.maxUnit));
    await h.pump(tester);
    expect(find.text('Rest unit 30 min, this task\'s own'), findsOneWidget);
    await tester.tap(find.text('Adjust step length and rest unit'));
    await tester.pumpAndSettle();
    expect(find.textContaining('the rest unit stays within 30 sec to 30 min'), findsOneWidget);

    final gesture = await tester.startGesture(tester.getRect(find.byType(Slider).last).center);
    await tester.pump();
    await _slide(tester, gesture, 120);
    expect(find.text('Rest 30 min · Step 1 min'), findsOneWidget, reason: 'the preview is capped like the save');
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('The rest unit stays at 30 min, the longest'), findsOneWidget);
    expect(find.text('Undo'), findsNothing);
    expect((await tester.runAsync(() => h.repo.getTask(h.task.id)))!.restUnit, LadderRests.maxUnit);

    await h.tearDown(tester);
  });

  testWidgets('a Settings rest outside the range is shown as kept to it', (tester) async {
    final h = await _harness(settings: const AppSettings(rest: Duration(minutes: 45)));
    await h.pump(tester);
    expect(find.text('Rest unit 30 min, from Settings (45 min), kept to 30 min'), findsOneWidget);
    expect(find.text('Rest 30 min · Step 1 min'), findsOneWidget);
    expect(find.text('Rest 30 min · Step 2 min'), findsOneWidget);
    expect(find.text('Rest 1 hr · Step 30 sec'), findsOneWidget);
    await h.tearDown(tester);
  });

  testWidgets('the edit dialog says where the rest comes from, and when the climb has stopped', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final h = await _harness();
    await tester.runAsync(() async {
      await h.repo.addStep(h.task.id, 'Dry off');
      await h.repo.addStep(h.task.id, 'Get dressed');
    });
    await h.pump(tester);

    await tester.tap(find.text('Think about a shower'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(
      find.text('Rest before this step: 10 min, from its place in the ladder (step 1). Move the step to change it.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Rest 2 hr 10 min · Step 2 min (the usual length)'), findsOneWidget, reason: 'step 7, ×13');
    await tester.tap(find.text('Get dressed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(
      find.text('Rest before this step: 2 hr 10 min, the longest rest, shared by step 7 and every step after it. '
          'Move it to step 6 or earlier for a shorter one.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

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
