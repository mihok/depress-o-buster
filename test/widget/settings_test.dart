import 'package:depress_o_buster/app.dart';
import 'package:depress_o_buster/data/db/database.dart';
import 'package:depress_o_buster/data/repositories/preset_repository.dart';
import 'package:depress_o_buster/data/repositories/task_repository.dart';
import 'package:depress_o_buster/data/seed/seed_data.dart';
import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/alarms/alarm_service.dart';
import 'package:depress_o_buster/services/audio/sound_service.dart';
import 'package:depress_o_buster/services/providers.dart';
import 'package:depress_o_buster/services/settings/settings_service.dart';
import 'package:depress_o_buster/ui/settings/settings_screen.dart';
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
          alarmServiceProvider.overrideWithValue(NoopAlarmService()),
          soundServiceProvider.overrideWithValue(_SilentSoundService()),
        ],
        child: const DepressOBusterApp(),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

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
  await SeedData.seedIfEmpty(tasks: TaskRepository(db), presets: PresetRepository(db));
  final settingsService = SettingsService(prefs: InMemoryKeyValueStore(), secrets: InMemorySecretStore());
  await settingsService.save(const AppSettings());
  return _Harness(db, settingsService);
}

/// Settings is the last tab of the bottom navigation.
Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Settings'));
  await tester.pump();
  await tester.pump();
}

/// The settings list is lazy and taller than the test viewport, so a row is
/// only built once it is scrolled near.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    100,
    scrollable: find.descendant(of: find.byType(SettingsScreen), matching: find.byType(Scrollable)),
  );
  await tester.pump();
}

/// Lets the 200 ms expansion animation run to its end.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  // Each test opens its own in-memory database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const claudeTiles = ['Claude API key', 'Model', 'Use Claude when a key is set'];

  testWidgets('the Claude breakdown settings stay behind Advanced until it is tapped', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    await _openSettings(tester);

    await _scrollTo(tester, find.text('Advanced'));
    expect(find.text('Claude-assisted breakdown: model and API key'), findsOneWidget);
    expect(find.text('AI breakdown'), findsNothing, reason: 'the old section header is gone');
    for (final tile in claudeTiles) {
      expect(find.text(tile), findsNothing, reason: '$tile is folded away while Advanced is collapsed');
    }

    await tester.tap(find.text('Advanced'));
    await _settle(tester);
    for (final tile in claudeTiles) {
      expect(find.text(tile), findsOneWidget, reason: '$tile rolls out when Advanced is tapped');
    }
    expect(find.text('No key. Built-in ladders are used.'), findsOneWidget);
    expect(
      find.textContaining('stored in the device keychain'),
      findsOneWidget,
      reason: 'the key note rolls out with the tiles',
    );

    await tester.tap(find.text('Advanced'));
    await _settle(tester);
    for (final tile in claudeTiles) {
      expect(find.text(tile), findsNothing, reason: '$tile folds away again');
    }

    await h.tearDown(tester);
  });

  testWidgets('the Advanced row is a full-size tap target with no divider lines', (tester) async {
    final h = await _harness();
    await h.pump(tester);
    await _openSettings(tester);
    await _scrollTo(tester, find.text('Advanced'));

    final header = find.widgetWithText(ListTile, 'Advanced');
    expect(header, findsOneWidget);
    expect(tester.getSize(header).height, greaterThanOrEqualTo(56));

    final tile = tester.widget<ExpansionTile>(find.byType(ExpansionTile));
    expect(tile.shape, const Border(), reason: 'no divider lines once expanded');
    expect(tile.collapsedShape, const Border());
    expect(tile.backgroundColor, isNull, reason: 'no tinted background');
    expect(tile.collapsedBackgroundColor, isNull);

    await h.tearDown(tester);
  });
}
