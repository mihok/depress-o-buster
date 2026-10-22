import 'package:depress_o_buster/core/theme.dart';
import 'package:depress_o_buster/data/db/database.dart';
import 'package:depress_o_buster/data/repositories/task_repository.dart';
import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/providers.dart';
import 'package:depress_o_buster/services/settings/settings_service.dart';
import 'package:depress_o_buster/ui/tasks/task_detail_screen.dart';
import 'package:depress_o_buster/ui/tasks/tasks_screen.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<void> pump(WidgetTester tester, {AppSettings settings = const AppSettings()}) async {
    final db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    final repo = TaskRepository(db);
    await repo.createTask('Shower', ladder: StarterLadders.byTitle['Shower']!);
    final settingsService = SettingsService(prefs: InMemoryKeyValueStore(), secrets: InMemorySecretStore());
    await settingsService.save(settings);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(settingsService),
          initialSettingsProvider.overrideWithValue(settings),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const TasksScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('a Settings rest outside the range is previewed as kept to it', (tester) async {
    await pump(tester, settings: const AppSettings(rest: Duration(minutes: 45)));
    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    expect(
      find.text('Rest before each step, from Settings (45 min) kept to 30 min: '
          '30, 30 min, 1 hr, 1 hr 30 min, 2 hr 30 min, 4 hr, 6 hr 30 min, 6 hr 30 min'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('the New task dialog shows the ladder, its step lengths and its rests as the title is typed', (tester) async {
    await pump(tester);

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    // Before a title: the general ladder, with the Settings rest (10 min) as the unit.
    expect(find.text('It gets a ladder of 8 steps, from thinking about it for a minute up to the whole thing.'), findsOneWidget);
    expect(find.text('Steps: 1, 1, 2, 1, 2, 3, 5, 25 min'), findsOneWidget);
    expect(find.text('Rest before each step: 10, 10, 20, 30, 50 min, 1 hr 20 min, 2 hr 10 min, 2 hr 10 min'), findsOneWidget);
    expect(find.text('Every step and the rest unit can be changed on the next screen.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Laundry');
    await tester.pump();
    expect(find.text('It gets the "Laundry" ladder: 9 steps, from about a minute up to the whole thing.'), findsOneWidget);
    expect(find.text('Steps: 1, 1, 2, 2, 5, 3, 5, 10, 30 min'), findsOneWidget);
    expect(
      find.text('Rest before each step: 10, 10, 20, 30, 50 min, 1 hr 20 min, 2 hr 10 min, 2 hr 10 min, 2 hr 10 min'),
      findsOneWidget,
    );

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Think about laundry for 1 minute'), findsOneWidget);
    expect(find.text('Rest 10 min · Step 1 min'), findsNWidgets(2), reason: 'the first two steps rest one unit');

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
