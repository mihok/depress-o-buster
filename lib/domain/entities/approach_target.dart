import 'package:meta/meta.dart';

/// What an approach interval is about. Everything is optional: "just sit up"
/// has no task and no rung.
@immutable
class ApproachTarget {
  const ApproachTarget({
    this.taskId,
    this.taskTitle,
    this.rungPosition,
    this.rungText,
  });

  final String? taskId;
  final String? taskTitle;
  final int? rungPosition;
  final String? rungText;

  bool get isEmpty => taskId == null && rungText == null && taskTitle == null;

  /// A short human description: the rung text if there is one, else the task.
  String get description => rungText ?? taskTitle ?? 'Just this';

  @override
  bool operator ==(Object other) =>
      other is ApproachTarget &&
      other.taskId == taskId &&
      other.taskTitle == taskTitle &&
      other.rungPosition == rungPosition &&
      other.rungText == rungText;

  @override
  int get hashCode => Object.hash(taskId, taskTitle, rungPosition, rungText);

  @override
  String toString() => 'ApproachTarget($description)';
}
