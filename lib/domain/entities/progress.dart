import 'package:meta/meta.dart';

/// The small amount of aggregate state XP rules need, kept in one row.
@immutable
class ProgressSnapshot {
  const ProgressSnapshot({
    this.totalXp = 0,
    this.consistency = 1.0,
    this.lastActiveDay,
    this.totalCompletedIntervals = 0,
  });

  final int totalXp;

  /// Consistency multiplier in [1.0, 1.5]. Never shown as "broken".
  final double consistency;

  /// Date (local, time stripped) of the last day with a completed interval.
  final DateTime? lastActiveDay;
  final int totalCompletedIntervals;

  bool get hasEverCompleted => totalCompletedIntervals > 0;

  ProgressSnapshot copyWith({
    int? totalXp,
    double? consistency,
    DateTime? lastActiveDay,
    int? totalCompletedIntervals,
  }) {
    return ProgressSnapshot(
      totalXp: totalXp ?? this.totalXp,
      consistency: consistency ?? this.consistency,
      lastActiveDay: lastActiveDay ?? this.lastActiveDay,
      totalCompletedIntervals:
          totalCompletedIntervals ?? this.totalCompletedIntervals,
    );
  }

  @override
  String toString() =>
      'ProgressSnapshot(xp=$totalXp, c=$consistency, last=$lastActiveDay)';
}
