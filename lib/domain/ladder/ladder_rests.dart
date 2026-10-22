import '../../core/format.dart';
import '../entities/ladder_step.dart';
import '../entities/task.dart';
import '../timer/timer_engine.dart';
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

  /// The rest unit a task uses: its own, or the fallback (the Settings
  /// rest), kept within [minUnit]..[maxUnit] either way.
  static Duration unitFor(Task task, Duration fallback) => clampUnit(task.restUnit ?? fallback);

  /// The rest before the step at [position].
  static Duration restFor({required Duration unit, required int position}) =>
      unit * multiplierFor(position);

  /// The rests before the first [count] steps.
  static List<Duration> restsFor(Duration unit, int count) =>
      [for (var i = 0; i < count; i++) restFor(unit: unit, position: i)];

  /// The longest rest any step gets: [maxUnit] times the last multiplier.
  static Duration get maxRest => maxUnit * multipliers.last;

  /// The round for one step of a ladder: the step's own length (or the
  /// usual approach), the rest its place earns, and no long rest. The
  /// ladder's climb is the whole rest schedule, so a later round never swaps
  /// in a long rest from Settings that the screen never showed.
  static TimerConfig roundFor({
    required TimerConfig base,
    required Task task,
    required LadderStep step,
    required Duration fallbackUnit,
  }) => base.copyWith(
    approach: step.suggestedDuration ?? base.approach,
    rest: restFor(unit: unitFor(task, fallbackUnit), position: step.position),
    clearLongRest: true,
    cyclesBeforeLongRest: 0,
  );

  /// A new unit from the slider, rounded the way step times are.
  static Duration scaleUnit(Duration unit, double factor) => StepScaling.scale(unit, factor);

  /// The unit never goes below 30 seconds or above 30 minutes: ×13 of the
  /// cap is six and a half hours, a long afternoon rather than a lost day.
  static const Duration minUnit = Duration(seconds: 30);
  static const Duration maxUnit = Duration(minutes: 30);

  static Duration clampUnit(Duration unit) =>
      unit < minUnit ? minUnit : (unit > maxUnit ? maxUnit : unit);

  /// The whole climb for a unit, in the words used everywhere else:
  /// "10, 10, 20, 30, 50 min, 1 hr 20 min, then 2 hr 10 min from step 7 on".
  static String describe(Duration unit) {
    final climb = restsFor(unit, multipliers.length);
    return '${formatSeries(climb.take(climb.length - 1))}, '
        'then ${formatWords(climb.last)} from step ${multipliers.length} on';
  }
}
