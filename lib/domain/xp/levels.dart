import 'package:meta/meta.dart';

/// Calm level names and thresholds. Level L (L >= 2) is reached at
/// `40 * (L - 1) * (L + 2)` cumulative XP: 160, 400, 720, 1120, 1600, ...
class Levels {
  Levels._();

  static const int maxLevel = 99;

  static const List<String> names = [
    'Resting',
    'Stirring',
    'Noticing',
    'Sitting up',
    'Feet on the floor',
    'Standing',
    'Doorway',
    'Across the room',
    'Curtains open',
    'Daylight',
    'Kettle on',
    'Outside air',
    'Around the block',
    'Steady',
    'Quiet momentum',
    'Rooted',
    'Weathering',
    'Tending',
    'Settled',
    'Here',
  ];

  static int xpToReach(int level) => level <= 1 ? 0 : 40 * (level - 1) * (level + 2);

  static int levelFor(int xp) {
    var level = 1;
    while (level < maxLevel && xpToReach(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  static String nameFor(int level) {
    if (level < 1) return names.first;
    if (level <= names.length) return names[level - 1];
    return '${names.last}, still ($level)';
  }

  static LevelProgress progressFor(int xp) {
    final level = levelFor(xp);
    final floor = xpToReach(level);
    final next = level >= maxLevel ? floor : xpToReach(level + 1);
    final span = next - floor;
    return LevelProgress(
      level: level,
      name: nameFor(level),
      xpIntoLevel: xp - floor,
      xpSpan: span,
      nextName: level >= maxLevel ? null : nameFor(level + 1),
    );
  }
}

@immutable
class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.name,
    required this.xpIntoLevel,
    required this.xpSpan,
    this.nextName,
  });

  final int level;
  final String name;
  final int xpIntoLevel;
  final int xpSpan;
  final String? nextName;

  double get fraction => xpSpan <= 0 ? 1 : (xpIntoLevel / xpSpan).clamp(0.0, 1.0);
  int get xpToNext => xpSpan <= 0 ? 0 : xpSpan - xpIntoLevel;

  @override
  String toString() => 'LevelProgress($level $name $xpIntoLevel/$xpSpan)';
}
