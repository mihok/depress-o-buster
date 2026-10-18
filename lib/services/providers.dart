import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/repositories/preset_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/task_repository.dart';
import '../domain/entities/entities.dart';
import '../domain/timer/timer_engine.dart';
import 'alarms/alarm_service.dart';
import 'audio/sound_service.dart';
import 'audio_context/audio_context_service.dart';
import 'breakdown/breakdown_config.dart';
import 'breakdown/claude_task_breakdown_service.dart';
import 'breakdown/mock_task_breakdown_service.dart';
import 'breakdown/task_breakdown_service.dart';
import 'companion/companion_service.dart';
import 'settings/settings_service.dart';
import 'timer/timer_controller.dart';
import 'xp/xp_service.dart';

// ---------------------------------------------------------------------------
// Infrastructure. These are overridden in main() (and in tests).
// ---------------------------------------------------------------------------

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => throw UnimplementedError('settingsServiceProvider must be overridden'),
);

final initialSettingsProvider = Provider<AppSettings>(
  (ref) => throw UnimplementedError('initialSettingsProvider must be overridden'),
);

final alarmServiceProvider = Provider<AlarmService>(
  (ref) => throw UnimplementedError('alarmServiceProvider must be overridden'),
);

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(databaseProvider)),
);

final presetRepositoryProvider = Provider<PresetRepository>(
  (ref) => PresetRepository(ref.watch(databaseProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(databaseProvider)),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(databaseProvider)),
);

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  Future<void> update(AppSettings Function(AppSettings current) change) async {
    state = change(state);
    await ref.read(settingsServiceProvider).save(state);
  }

  /// Apply a preset's ratio as the current timer config.
  Future<void> applyPreset(Preset preset) => update(
    (s) => s.copyWith(
      approach: preset.approach,
      rest: preset.rest,
      longRest: preset.longRest,
      clearLongRest: preset.longRest == null,
      cyclesBeforeLongRest: preset.cyclesBeforeLongRest,
      lastPresetId: preset.id,
    ),
  );
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Whether a Claude API key is stored. Refresh after editing it.
final apiKeyPresentProvider = FutureProvider<bool>((ref) async {
  final key = await ref.watch(settingsServiceProvider).apiKey();
  return key != null && key.trim().isNotEmpty;
});

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

final xpServiceProvider = Provider<XpService>(
  (ref) => XpService(
    sessions: ref.watch(sessionRepositoryProvider),
    progress: ref.watch(progressRepositoryProvider),
    tasks: ref.watch(taskRepositoryProvider),
  ),
);

final mockBreakdownProvider = Provider<TaskBreakdownService>(
  (ref) => MockTaskBreakdownService(latency: const Duration(milliseconds: 400)),
);

final claudeBreakdownProvider = Provider<TaskBreakdownService>((ref) {
  final settings = ref.watch(settingsProvider.select((s) => s.breakdownModel));
  final store = ref.watch(settingsServiceProvider);
  return ClaudeTaskBreakdownService(
    apiKeyProvider: store.apiKey,
    config: BreakdownConfig.defaults.copyWith(
      model: settings,
      // Browsers need an explicit opt-in header for direct API calls.
      directBrowserAccess: kIsWeb,
    ),
  );
});

/// Picks Claude when preferred and a key exists, else the offline ladders.
final breakdownServiceProvider = FutureProvider<TaskBreakdownService>((ref) async {
  final prefer = ref.watch(settingsProvider.select((s) => s.preferClaude));
  final claude = ref.watch(claudeBreakdownProvider);
  if (prefer && await claude.isAvailable()) return claude;
  return ref.watch(mockBreakdownProvider);
});

final companionServiceProvider = Provider<CompanionService>(
  (ref) => const NoopCompanionService(),
);

final audioContextServiceProvider = Provider<AudioContextService>(
  (ref) => const NoopAudioContextService(),
);

final timerControllerProvider = NotifierProvider<TimerController, TimerState>(
  TimerController.new,
);

final lastLoggedProvider = NotifierProvider<LastLoggedController, LoggedInterval?>(
  LastLoggedController.new,
);

/// The most recently logged approach (for the optional "mood after" prompt).
final lastApproachLoggedProvider = NotifierProvider<LastLoggedController, LoggedInterval?>(
  LastLoggedController.new,
);

/// Rebuild driver for countdown displays. The timer state itself only changes
/// when a phase changes; the clock is derived from the wall clock.
final nowTickProvider = StreamProvider.autoDispose<DateTime>(
  (ref) => Stream.periodic(const Duration(seconds: 1), (_) => clock.now()),
);

/// Current alarm capabilities, refreshed on demand with `ref.invalidate`.
final alarmCapabilitiesProvider = FutureProvider.autoDispose<AlarmCapabilities>(
  (ref) => ref.watch(alarmServiceProvider).ensurePermissions(request: false),
);

// ---------------------------------------------------------------------------
// Streams for the UI
// ---------------------------------------------------------------------------

final tasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(taskRepositoryProvider).watchActiveTasks(),
);

final ladderProvider = StreamProvider.family<List<LadderStep>, String>(
  (ref, taskId) => ref.watch(taskRepositoryProvider).watchLadder(taskId),
);

final presetsProvider = StreamProvider<List<Preset>>(
  (ref) => ref.watch(presetRepositoryProvider).watchAll(),
);

final progressProvider = StreamProvider<ProgressSnapshot>(
  (ref) => ref.watch(progressRepositoryProvider).watch(),
);

final recentSessionsProvider = StreamProvider<List<Session>>(
  (ref) => ref.watch(sessionRepositoryProvider).watchRecent(),
);

/// Every interval, for the History screen. Quiet days are simply absent.
final allSessionsProvider = StreamProvider<List<Session>>(
  (ref) => ref.watch(sessionRepositoryProvider).watchAll(),
);
