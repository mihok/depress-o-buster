import '../../domain/entities/entities.dart';
import '../../domain/ladder/starter_ladders.dart';
import '../repositories/preset_repository.dart';
import '../repositories/task_repository.dart';

/// First-launch content. Everything seeded here can be edited or deleted.
class SeedData {
  SeedData._();

  static const List<String> starterTaskTitles = [
    'Just sit up',
    'Laundry',
    'Shower',
    'Go outside',
    'Reply to someone',
    'Eat something',
  ];

  /// (name, approach, rest, longRest, cyclesBeforeLongRest)
  static final List<Preset> presets = [
    const Preset(
      id: 'preset-just-sit-up',
      name: 'Just sit up',
      approach: Duration(minutes: 2),
      rest: Duration(minutes: 10),
      sortOrder: 0,
      builtIn: true,
    ),
    const Preset(
      id: 'preset-edge-of-bed',
      name: 'Edge of bed',
      approach: Duration(minutes: 3),
      rest: Duration(minutes: 20),
      sortOrder: 1,
      builtIn: true,
    ),
    const Preset(
      id: 'preset-laundry-proximity',
      name: 'Laundry proximity',
      approach: Duration(minutes: 5),
      rest: Duration(minutes: 30),
      sortOrder: 2,
      builtIn: true,
    ),
    const Preset(
      id: 'preset-gentle',
      name: 'Gentle',
      approach: Duration(minutes: 10),
      rest: Duration(minutes: 20),
      sortOrder: 3,
      builtIn: true,
    ),
    const Preset(
      id: 'preset-classic',
      name: 'Classic',
      approach: Duration(minutes: 25),
      rest: Duration(minutes: 5),
      longRest: Duration(minutes: 20),
      cyclesBeforeLongRest: 4,
      sortOrder: 4,
      builtIn: true,
    ),
    const Preset(
      id: 'preset-deep',
      name: 'Deep',
      approach: Duration(minutes: 50),
      rest: Duration(minutes: 10),
      sortOrder: 5,
      builtIn: true,
    ),
  ];

  static Future<void> seedIfEmpty({
    required TaskRepository tasks,
    required PresetRepository presets,
  }) async {
    if ((await presets.all()).isEmpty) {
      for (final p in SeedData.presets) {
        await presets.upsert(p);
      }
    }
    if ((await tasks.activeTasks()).isEmpty) {
      for (var i = 0; i < starterTaskTitles.length; i++) {
        final title = starterTaskTitles[i];
        await tasks.createTask(
          title,
          ladder: StarterLadders.byTitle[title] ?? StarterLadders.generic(title),
          sortOrder: i,
        );
      }
    }
  }
}
