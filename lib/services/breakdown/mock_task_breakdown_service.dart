import '../../domain/entities/ladder_step.dart';
import '../../domain/ladder/starter_ladders.dart';
import 'task_breakdown_service.dart';

/// Offline breakdown from hand-written ladders. Always available, used in
/// tests and whenever no API key is configured.
class MockTaskBreakdownService implements TaskBreakdownService {
  MockTaskBreakdownService({this.latency = Duration.zero});

  /// Simulated delay so the UI's loading state can be exercised.
  final Duration latency;

  @override
  String get name => 'Built-in ladders (offline)';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<BreakdownResult> breakDown(BreakdownRequest request) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final List<MicroStep> steps;
    if (request.goSmaller && (request.currentRung?.trim().isNotEmpty ?? false)) {
      steps = StarterLadders.smallerThan(
        request.currentRung!,
        rungMinutes: request.currentRungMinutes,
      );
    } else {
      steps = StarterLadders.match(request.taskTitle) ??
          StarterLadders.generic(request.taskTitle);
    }
    return BreakdownResult(
      steps: fit(steps, request.maxSteps),
      source: name,
      note: 'Built-in ladder. Edit any step to fit you.',
    );
  }

  /// Keep at most [max] steps, always keeping the first and the last.
  static List<MicroStep> fit(List<MicroStep> steps, int max) {
    if (max <= 0 || steps.length <= max) return steps;
    if (max == 1) return [steps.first];
    final result = <MicroStep>[];
    for (var i = 0; i < max; i++) {
      final idx = (i * (steps.length - 1) / (max - 1)).round();
      result.add(steps[idx]);
    }
    return result;
  }
}
