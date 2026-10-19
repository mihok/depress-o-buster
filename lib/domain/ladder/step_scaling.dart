import '../entities/ladder_step.dart';

/// Pure rules for stretching or shrinking the suggested time on every step
/// of a ladder together.
class StepScaling {
  StepScaling._();

  /// The stops of the "step length" slider, as multipliers. ×1 sits in the
  /// middle so the control reads as "shorter" to the left, "longer" to the
  /// right.
  static const List<double> factors = [0.25, 0.5, 0.75, 1, 1.5, 2, 3];

  /// No step is ever suggested for less than this.
  static const Duration minimum = Duration(seconds: 30);

  /// Below this, times are rounded to the nearest 30 seconds; from here on,
  /// to the nearest minute.
  static const Duration fineGrainBelow = Duration(minutes: 5);

  /// Round a raw time to something a person would set by hand: never below
  /// 30 seconds, to the nearest 30 seconds under 5 minutes, to the nearest
  /// minute at or above 5 minutes. Halves round up.
  static Duration round(Duration raw) {
    final unit = raw < fineGrainBelow ? 30 : 60;
    final seconds = (raw.inMilliseconds / 1000 / unit).round() * unit;
    final rounded = Duration(seconds: seconds);
    return rounded < minimum ? minimum : rounded;
  }

  /// [duration] multiplied by [factor], then rounded with [round].
  static Duration scale(Duration duration, double factor) =>
      round(duration * factor);

  /// Every step with a suggested time gets it scaled; a step without one
  /// stays without one. Ids, positions and text are untouched.
  static List<LadderStep> scaleAll(List<LadderStep> steps, double factor) => [
    for (final s in steps)
      s.suggestedDuration == null
          ? s
          : s.copyWith(suggestedDuration: scale(s.suggestedDuration!, factor)),
  ];

  /// "×0.5", "×1", "×1.5", "×1.88": whole numbers plain, otherwise two
  /// decimals with trailing zeros dropped.
  static String label(double factor) {
    final text = factor == factor.roundToDouble()
        ? '${factor.toInt()}'
        : factor.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
    return '×$text';
  }
}
