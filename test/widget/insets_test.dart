import 'package:depress_o_buster/core/theme.dart';
import 'package:depress_o_buster/data/db/database.dart';
import 'package:depress_o_buster/data/repositories/task_repository.dart';
import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/providers.dart';
import 'package:depress_o_buster/services/settings/settings_service.dart';
import 'package:depress_o_buster/ui/tasks/rung_picker_sheet.dart';
import 'package:depress_o_buster/ui/tasks/task_detail_screen.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The app draws behind Android's navigation bar (edge-to-edge), so every
// screen and sheet has to keep what the person taps above it. These tests
// give the test view such a bar and measure.

const _ladder = [
  MicroStep('Think about a shower', suggestedDuration: Duration(minutes: 1)),
  MicroStep('Stand in the bathroom', suggestedDuration: Duration(minutes: 2)),
  MicroStep('Turn the water on', suggestedDuration: Duration(seconds: 30)),
  MicroStep('Step in', suggestedDuration: Duration(minutes: 5)),
  MicroStep('Wash up'),
];

/// The navigation bar's height in logical pixels: a three-button bar on a
/// phone at pixel ratio 3.
const double _inset = 48;

/// Give the test view a navigation bar, as the engine reports one: in
/// physical pixels, both as padding and as view padding (the two differ only
/// while a keyboard is up).
void _drawNavigationBar(WidgetTester tester) {
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(bottom: _inset * 3);
  tester.view.viewPadding = const FakeViewPadding(bottom: _inset * 3);
  addTearDown(tester.view.reset);
}

/// Where the screen ends; the bar covers the last [_inset] of it.
double _screenBottom(WidgetTester tester) => tester.view.physicalSize.height / tester.view.devicePixelRatio;

class _Harness {
  _Harness(this.db, this.repo, this.task, this.settingsService, this.settings);

  final AppDatabase db;
  final TaskRepository repo;
  final Task task;
  final SettingsService settingsService;
  final AppSettings settings;

  Future<void> pump(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(settingsService),
          initialSettingsProvider.overrideWithValue(settings),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: home),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> tearDown(WidgetTester tester) async {
    // Let any Undo bar time out, so no timer is left pending.
    await tester.pump(const Duration(seconds: 7));
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
  const settings = AppSettings();
  await settingsService.save(settings);
  return _Harness(db, repo, task, settingsService, settings);
}

void main() {
  // Each test opens its own in-memory database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('the task screen\'s bottom row stays above the bar, and a floating snack bar above the row', (tester) async {
    _drawNavigationBar(tester);
    final h = await _harness();
    await h.pump(tester, TaskDetailScreen(taskId: h.task.id));
    final clear = _screenBottom(tester) - _inset;

    final add = tester.getRect(find.widgetWithText(OutlinedButton, 'Add'));
    expect(add.bottom, lessThanOrEqualTo(clear));
    expect(tester.getRect(find.text('Break this down smaller')).bottom, lessThanOrEqualTo(clear));

    await tester.drag(find.text('Stand in the bathroom'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Step removed'), findsOneWidget);
    final bar = tester.getRect(find.byType(SnackBar));
    expect(bar.bottom, lessThanOrEqualTo(clear));
    expect(bar.bottom, lessThanOrEqualTo(add.top), reason: 'the bar sits above the buttons, not over them');

    await h.tearDown(tester);
  });

  testWidgets('the step sheet\'s Edit and Remove row clears the bar', (tester) async {
    _drawNavigationBar(tester);
    final h = await _harness();
    await h.pump(tester, TaskDetailScreen(taskId: h.task.id));
    await tester.tap(find.text('Think about a shower'));
    await tester.pumpAndSettle();
    final clear = _screenBottom(tester) - _inset;

    expect(tester.getRect(find.widgetWithText(TextButton, 'Remove')).bottom, lessThanOrEqualTo(clear));
    expect(tester.getRect(find.widgetWithText(TextButton, 'Edit')).bottom, lessThanOrEqualTo(clear));
    // The sheet's own surface still runs to the edge: the bar is drawn over
    // it, not over a gap.
    expect(tester.getRect(find.byType(BottomSheet)).bottom, moreOrLessEquals(_screenBottom(tester)));

    await h.tearDown(tester);
  });

  testWidgets('the breakdown sheet ends where the bar begins', (tester) async {
    _drawNavigationBar(tester);
    final h = await _harness();
    await h.pump(tester, TaskDetailScreen(taskId: h.task.id));
    await tester.tap(find.text('Break this down smaller'));
    await tester.pumpAndSettle();

    expect(find.text('Break it down'), findsOneWidget);
    expect(tester.getRect(find.byType(ListView)).bottom, moreOrLessEquals(_screenBottom(tester) - _inset));

    await h.tearDown(tester);
  });

  testWidgets('the step picker\'s last row clears the bar', (tester) async {
    _drawNavigationBar(tester);
    final h = await _harness();
    await h.pump(
      tester,
      Scaffold(
        body: Center(
          child: Builder(
            builder: (ctx) => TextButton(onPressed: () => showRungPicker(ctx), child: const Text('Pick')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shower'));
    await tester.pumpAndSettle();

    // To the end of the list. A drag first grows the sheet to its full
    // height; only the ones after it scroll the list.
    final list = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
    ScrollPosition position() => tester.state<ScrollableState>(list).position;
    for (var i = 0; i < 5 && position().pixels < position().maxScrollExtent; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    expect(position().pixels, position().maxScrollExtent);

    final last = tester.getRect(find.widgetWithText(ListTile, 'Wash up'));
    expect(last.bottom, lessThanOrEqualTo(_screenBottom(tester) - _inset));

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
