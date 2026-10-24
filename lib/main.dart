import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/db/database.dart';
import 'data/repositories/preset_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/seed/seed_data.dart';
import 'services/alarms/alarm_service.dart';
import 'services/alarms/local_notifications_alarm_service.dart';
import 'services/providers.dart';
import 'services/settings/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the system bars on every Android version, not only where
  // Android 15 insists on it, so the screens have one set of insets to
  // clear rather than two. The bars themselves are styled in app.dart.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final db = AppDatabase.open();
  final settingsService = SettingsService();
  final settings = await settingsService.load();

  final AlarmService alarms =
      kIsWeb || defaultTargetPlatform == TargetPlatform.windows
          ? NoopAlarmService()
          : LocalNotificationsAlarmService();
  try {
    await alarms.init();
  } catch (e) {
    debugPrint('Alarm init failed: $e');
  }

  // Seed once. A marker, not emptiness, so deleting every starter task or
  // preset does not bring them back on the next launch.
  try {
    if (!await settingsService.isSeeded()) {
      await SeedData.seedIfEmpty(
        tasks: TaskRepository(db),
        presets: PresetRepository(db),
      );
      await settingsService.markSeeded();
    }
  } catch (e) {
    debugPrint('Seeding failed: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsServiceProvider.overrideWithValue(settingsService),
        initialSettingsProvider.overrideWithValue(settings),
        alarmServiceProvider.overrideWithValue(alarms),
      ],
      child: const DepressOBusterApp(),
    ),
  );
}
