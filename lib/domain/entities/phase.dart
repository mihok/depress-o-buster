/// The two kinds of interval in an inverted Pomodoro, plus the optional long rest.
enum Phase {
  approach,
  rest,
  longRest;

  bool get isRest => this != Phase.approach;

  String get label => switch (this) {
    Phase.approach => 'Approach',
    Phase.rest => 'Rest',
    Phase.longRest => 'Long rest',
  };

  /// Stable string for persistence.
  String get storageKey => name;

  static Phase fromStorageKey(String key) =>
      Phase.values.firstWhere((p) => p.name == key, orElse: () => Phase.approach);
}
