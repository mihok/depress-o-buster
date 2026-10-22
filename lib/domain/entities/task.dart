import 'package:meta/meta.dart';

/// Anything the person might approach: "laundry", "shower", "reply to Sam".
@immutable
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.note,
    this.archived = false,
    this.sortOrder = 0,
    this.restUnit,
  });

  final String id;
  final String title;
  final String? note;
  final DateTime createdAt;
  final bool archived;
  final int sortOrder;

  /// The rest unit this task's steps climb from (see `LadderRests`). Null
  /// means "the rest from Settings".
  final Duration? restUnit;

  Task copyWith({
    String? title,
    String? note,
    bool clearNote = false,
    bool? archived,
    int? sortOrder,
    Duration? restUnit,
    bool clearRestUnit = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      restUnit: clearRestUnit ? null : (restUnit ?? this.restUnit),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.id == id &&
      other.title == title &&
      other.note == note &&
      other.createdAt == createdAt &&
      other.archived == archived &&
      other.sortOrder == sortOrder &&
      other.restUnit == restUnit;

  @override
  int get hashCode => Object.hash(id, title, note, createdAt, archived, sortOrder, restUnit);

  @override
  String toString() => 'Task($id, $title)';
}
