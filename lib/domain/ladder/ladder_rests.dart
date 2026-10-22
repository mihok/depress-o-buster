import '../entities/task.dart';
import 'step_scaling.dart';

/// The rest before each step climbs a ladder of its own.
///
/// Rests follow the step's place in the ladder, not the step's length: the
/// first two steps get one rest unit, then two, three, five, eight and
/// thirteen units (a Fibonacci climb, capped so a long ladder does not run
/// away). A short step late in the ladder still gets the long rest its place
/// earns; moving a step moves its rest with it. The unit is the task's own
/// ([Task.restUnit]) or, when the task has none, the rest from Settings.
class LadderRests {
  LadderRests._();

  static const List<int> multipliers = [1, 1, 2, 3, 5, 8, 13];

  static int multiplierFor(int position) =>
      multipliers[position < 0 ? 0 : (position >= multipliers.length ? multipliers.length - 1 : position)];

  /// The rest unit a task uses: its own, or the fallback (the Settings rest).
  static Duration unitFor(Task task, Duration fallback) => task.restUnit ?? fallback;

  /// The rest before the step at [position].
  static Duration restFor({required Duration unit, required int position}) =>
      unit * multiplierFor(position);

  /// A new unit from the slider, rounded the way step times are.
  static Duration scaleUnit(Duration unit, double factor) => StepScaling.scale(unit, factor);

  /// The unit never goes below 30 seconds or above 4 hours (×13 of which is
  /// still a long afternoon, not a lost day).
  static const Duration minUnit = Duration(seconds: 30);
  static const Duration maxUnit = Duration(hours: 4);

  static Duration clampUnit(Duration unit) =>
      unit < minUnit ? minUnit : (unit > maxUnit ? maxUnit : unit);

  /// "10, 10, 20, 30, 50 min, …" for a given unit, [count] steps long.
  static String describe(Duration unit, {int count = 5}) {
    String minutes(Duration d) =>
        d.inSeconds % 60 == 0 ? '${d.inMinutes}' : (d.inSeconds / 60).toStringAsFixed(1);
    final parts = [for (var i = 0; i < count; i++) minutes(restFor(unit: unit, position: i))];
    return '${parts.join(', ')} min, …';
  }
}
