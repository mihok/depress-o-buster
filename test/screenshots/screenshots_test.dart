// Renders the app's screens to docs/screenshots/*.png without a device.
//
//   flutter test test/screenshots/screenshots_test.dart \
//     --dart-define=SCREENSHOTS=true --update-goldens
//
// Skipped in a normal `flutter test` run: the PNGs are documentation, not a
// regression check, and pixel output differs between machines.
import 'dart:io';

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
import 'package:depress_o_buster/ui/progress/progress_screen.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const bool enabled = bool.fromEnvironment('SCREENSHOTS');

class _SilentSoundService extends SoundService {
  @override
  Future<void> play(SoundKind kind, {double volume = 0.7}) async {}

  @override
  Future<void> haptic(SoundKind kind) async {}
}

/// Alarms "work" so the screens carry no permission hints.
class _GrantedAlarmService extends NoopAlarmService {
  @override
  bool get isSupported => true;

  @override
  AlarmCapabilities get capabilities =>
      const AlarmCapabilities(notificationsGranted: true, exactAlarmsAllowed: true);

  @override
  Future<AlarmCapabilities> ensurePermissions({bool request = true}) async => capabilities;
}

/// Real fonts from the Flutter SDK cache, so text renders as it does on a phone.
Future<void> _loadFonts() async {
  // The test runs on flutter_tester, somewhere under <sdk>/bin/cache/; walk up
  // to the cache directory that holds artifacts/material_fonts.
  var dir = File(Platform.resolvedExecutable).parent;
  while (!Directory('${dir.path}/artifacts/material_fonts').existsSync()) {
    if (dir.parent.path == dir.path) {
      throw StateError('material_fonts not found above ${Platform.resolvedExecutable}');
    }
    dir = dir.parent;
  }
  final fonts = Directory('${dir.path}/artifacts/material_fonts');
  Future<ByteData> bytes(String name) async {
    final data = await File('${fonts.path}/$name').readAsBytes();
    return ByteData.view(data.buffer);
  }

  final roboto = FontLoader('Roboto');
  for (final weight in ['Light', 'Regular', 'Medium', 'Bold']) {
    roboto.addFont(bytes('Roboto-$weight.ttf'));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')..addFont(bytes('MaterialIcons-Regular.otf'));
  await icons.load();
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
          alarmServiceProvider.overrideWithValue(_GrantedAlarmService()),
          soundServiceProvider.overrideWithValue(_SilentSoundService()),
        ],
        child: const DepressOBusterApp(),
      ),
    );
    await settle(tester);
  }

  /// Lets real async work (asset decoding) finish, then draws a frame.
  ///
  /// Only the wait runs with real async: taps and pumps stay in the test's
  /// fake-async zone so the timer's own timers are fake and `pump(duration)`
  /// moves them. A timer created inside `runAsync` would be real and never
  /// fire in a test.
  static Future<void> settle(WidgetTester tester, [int rounds = 3]) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      // Advance fake time too, so route transitions and sheets finish animating.
      await tester.pump(const Duration(milliseconds: 200));
    }
  }
}

/// A few quiet days of history, so Progress and History have something to show.
Future<void> _seedHistory(AppDatabase db) async {
  final tasks = TaskRepository(db);
  final sessions = SessionRepository(db);
  final sitUp = (await tasks.activeTasks()).firstWhere((t) => t.title == 'Just sit up');
  final shower = (await tasks.activeTasks()).firstWhere((t) => t.title == 'Shower');
  final sitUpLadder = await tasks.ladder(sitUp.id);
  final showerLadder = await tasks.ladder(shower.id);
  final now = DateTime.now();
  var n = 0;
  Future<void> approach(int daysAgo, int hour, Task task, LadderStep rung, int minutes, int xp,
      {String? before, String? after, List<String> bonuses = const []}) async {
    final end = DateTime(now.year, now.month, now.day - daysAgo, hour, 10);
    n++;
    await sessions.insert(Session(
      id: 'shot-a$n',
      runId: 'shot-run$n',
      phase: Phase.approach,
      planned: Duration(minutes: minutes),
      actual: Duration(minutes: minutes),
      outcome: SessionOutcome.completed,
      startedAt: end.subtract(Duration(minutes: minutes)),
      endedAt: end,
      taskId: task.id,
      taskTitle: task.title,
      rungId: rung.id,
      rungPosition: rung.position,
      rungText: rung.text,
      moodBefore: before,
      moodAfter: after,
      xpEarned: xp,
      xpBonuses: bonuses,
    ));
    await sessions.insert(Session(
      id: 'shot-r$n',
      runId: 'shot-run$n',
      phase: Phase.rest,
      planned: const Duration(minutes: 10),
      actual: const Duration(minutes: 10),
      outcome: SessionOutcome.completed,
      startedAt: end,
      endedAt: end.add(const Duration(minutes: 10)),
      xpEarned: 12,
    ));
  }

  await approach(6, 11, sitUp, sitUpLadder[0], 1, 80, bonuses: ['firstEver'], before: 'heavy');
  await approach(5, 10, sitUp, sitUpLadder[1], 2, 46, bonuses: ['firstToday'], before: 'flat', after: 'ok');
  await approach(5, 16, shower, showerLadder[0], 1, 55, bonuses: ['newPersonalRung']);
  await approach(3, 9, shower, showerLadder[1], 3, 62, bonuses: ['firstToday', 'newPersonalRung'], after: 'lighter');
  await approach(1, 14, sitUp, sitUpLadder[2], 5, 68, bonuses: ['firstToday', 'newPersonalRung'], before: 'tired', after: 'ok');
  await ProgressRepository(db).save(ProgressSnapshot(
    totalXp: 383,
    consistency: 1.17,
    lastActiveDay: DateTime(now.year, now.month, now.day - 1),
    totalCompletedIntervals: 10,
  ));
}

Future<_Harness> _harness({
  AppThemeMode theme = AppThemeMode.dark,
  bool history = true,
  int? quietDays,
}) async {
  final db = AppDatabase(
    DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
  );
  await SeedData.seedIfEmpty(tasks: TaskRepository(db), presets: PresetRepository(db));
  if (history) await _seedHistory(db);
  if (quietDays != null) {
    final now = DateTime.now();
    await ProgressRepository(db).save(ProgressSnapshot(
      totalXp: 383,
      consistency: 1.1,
      lastActiveDay: DateTime(now.year, now.month, now.day - quietDays),
      totalCompletedIntervals: 10,
    ));
  }
  final settingsService = SettingsService(prefs: InMemoryKeyValueStore(), secrets: InMemorySecretStore());
  await settingsService.save(AppSettings(themeMode: theme, notificationPermissionAsked: true));
  return _Harness(db, settingsService);
}

Future<void> _shot(WidgetTester tester, String name) async {
  await _Harness.settle(tester, 2);
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('../../docs/screenshots/$name.png'));
}

void main() {
  if (!enabled) {
    test(
      'screenshots are regenerated on demand',
      () {},
      skip: 'flutter test test/screenshots --dart-define=SCREENSHOTS=true --update-goldens',
    );
    return;
  }

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(_loadFonts);

  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> tapText(WidgetTester tester, String text, {int rounds = 3}) async {
    await tester.tap(find.text(text).first);
    await _Harness.settle(tester, rounds);
  }

  Future<void> leave(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets('dark: start, timer, tasks, breakdown, progress, history, settings', (tester) async {
    await phone(tester);
    final h = await _harness();
    await h.pump(tester);
    await _shot(tester, '01-start');

    await tapText(tester, 'Sit up for 2 minutes');
    await tester.pump(const Duration(seconds: 7));
    await tester.pump();
    await _shot(tester, '02-rest-first');

    await tester.pump(const Duration(milliseconds: 900));
    await tapText(tester, 'Start the step');
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
    await _shot(tester, '03-approach');

    await tester.pump(const Duration(minutes: 2));
    await _Harness.settle(tester);
    await _shot(tester, '04-round-complete');

    await tapText(tester, 'Done for now');
    await tapText(tester, 'Tasks');
    await _shot(tester, '05-tasks');

    await tapText(tester, 'Shower');
    await _shot(tester, '06-ladder');

    // Shrink one rung: the sheet then offers steps that are not on the ladder.
    await tapText(tester, 'Stand in the bathroom doorway');
    await tapText(tester, 'Break this step down smaller');
    await tapText(tester, 'Break it down', rounds: 6);
    await _shot(tester, '07-breakdown');

    while (find.byType(BottomSheet).evaluate().isNotEmpty) {
      Navigator.of(tester.element(find.byType(BottomSheet).first)).pop();
      await _Harness.settle(tester);
    }
    Navigator.of(tester.element(find.text('Shower').first)).pop();
    await _Harness.settle(tester);
    await tapText(tester, 'Progress');
    await _shot(tester, '08-progress');

    // "All history" sits below the fold of a lazy list.
    await tester.scrollUntilVisible(
      find.text('All history'),
      200,
      scrollable: find.descendant(of: find.byType(ProgressScreen), matching: find.byType(Scrollable)),
    );
    await _Harness.settle(tester);
    await tapText(tester, 'All history');
    await _shot(tester, '09-history');

    Navigator.of(tester.element(find.text('History'))).pop();
    await _Harness.settle(tester);
    await tapText(tester, 'Settings');
    await _shot(tester, '10-settings');
    await leave(tester);
  });

  testWidgets('light: start and progress', (tester) async {
    await phone(tester);
    final h = await _harness(theme: AppThemeMode.light);
    await h.pump(tester);
    await _shot(tester, '11-start-light');
    await tapText(tester, 'Progress');
    await _shot(tester, '12-progress-light');
    await leave(tester);
  });

  testWidgets('dark: start after a few quiet days, and empty states', (tester) async {
    await phone(tester);
    final h = await _harness(history: false, quietDays: 4);
    await h.pump(tester);
    await _shot(tester, '13-start-welcome-back');
    await tapText(tester, 'Progress');
    await _shot(tester, '14-progress-empty');
    await tapText(tester, 'All history');
    await _shot(tester, '15-history-empty');
    await leave(tester);
  });
}
