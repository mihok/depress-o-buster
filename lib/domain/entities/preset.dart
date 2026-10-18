import 'package:meta/meta.dart';

/// A named approach/rest ratio, e.g. "Edge of bed 2/20".
@immutable
class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.approach,
    required this.rest,
    this.longRest,
    this.cyclesBeforeLongRest = 0,
    this.sortOrder = 0,
    this.builtIn = false,
  });

  final String id;
  final String name;
  final Duration approach;
  final Duration rest;

  /// Optional longer rest after [cyclesBeforeLongRest] approaches.
  final Duration? longRest;

  /// 0 means "never use a long rest".
  final int cyclesBeforeLongRest;
  final int sortOrder;

  /// Built-in presets are seeded on first launch and can still be edited.
  final bool builtIn;

  /// "5/30" style label built from whole minutes, or seconds when shorter.
  String get ratioLabel => '${_short(approach)}/${_short(rest)}';

  static String _short(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    if (d.inSeconds % 60 == 0) return '${d.inMinutes}';
    return '${d.inMinutes}m${d.inSeconds % 60}s';
  }

  Preset copyWith({
    String? name,
    Duration? approach,
    Duration? rest,
    Duration? longRest,
    bool clearLongRest = false,
    int? cyclesBeforeLongRest,
    int? sortOrder,
    bool? builtIn,
  }) {
    return Preset(
      id: id,
      name: name ?? this.name,
      approach: approach ?? this.approach,
      rest: rest ?? this.rest,
      longRest: clearLongRest ? null : (longRest ?? this.longRest),
      cyclesBeforeLongRest: cyclesBeforeLongRest ?? this.cyclesBeforeLongRest,
      sortOrder: sortOrder ?? this.sortOrder,
      builtIn: builtIn ?? this.builtIn,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Preset &&
      other.id == id &&
      other.name == name &&
      other.approach == approach &&
      other.rest == rest &&
      other.longRest == longRest &&
      other.cyclesBeforeLongRest == cyclesBeforeLongRest &&
      other.sortOrder == sortOrder &&
      other.builtIn == builtIn;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    approach,
    rest,
    longRest,
    cyclesBeforeLongRest,
    sortOrder,
    builtIn,
  );

  @override
  String toString() => 'Preset($name $ratioLabel)';
}
