import 'package:meta/meta.dart';

/// One rung on a task's ladder. Position 0 is the smallest step.
@immutable
class LadderStep {
  const LadderStep({
    required this.id,
    required this.taskId,
    required this.position,
    required this.text,
    this.suggestedDuration,
  });

  final String id;
  final String taskId;
  final int position;
  final String text;

  /// An optional approach length that suits this rung ("sit up for 2 minutes").
  final Duration? suggestedDuration;

  LadderStep copyWith({
    int? position,
    String? text,
    Duration? suggestedDuration,
    bool clearSuggestedDuration = false,
  }) {
    return LadderStep(
      id: id,
      taskId: taskId,
      position: position ?? this.position,
      text: text ?? this.text,
      suggestedDuration: clearSuggestedDuration
          ? null
          : (suggestedDuration ?? this.suggestedDuration),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LadderStep &&
      other.id == id &&
      other.taskId == taskId &&
      other.position == position &&
      other.text == text &&
      other.suggestedDuration == suggestedDuration;

  @override
  int get hashCode => Object.hash(id, taskId, position, text, suggestedDuration);

  @override
  String toString() => 'LadderStep($position: $text)';
}

/// A rung that has not been saved yet, for example one returned by a breakdown.
@immutable
class MicroStep {
  const MicroStep(this.text, {this.suggestedDuration});

  final String text;
  final Duration? suggestedDuration;

  @override
  bool operator ==(Object other) =>
      other is MicroStep &&
      other.text == text &&
      other.suggestedDuration == suggestedDuration;

  @override
  int get hashCode => Object.hash(text, suggestedDuration);

  @override
  String toString() => 'MicroStep($text)';
}
