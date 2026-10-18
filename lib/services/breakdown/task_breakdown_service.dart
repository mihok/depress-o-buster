import 'package:meta/meta.dart';

import '../../domain/entities/ladder_step.dart';

/// What the person wants broken down. Everything but the title is optional.
@immutable
class BreakdownRequest {
  const BreakdownRequest({
    required this.taskTitle,
    this.taskNote,
    this.currentLadder = const [],
    this.currentRung,
    this.currentRungMinutes,
    this.feelingNote,
    this.goSmaller = false,
    this.maxSteps = 8,
  });

  final String taskTitle;
  final String? taskNote;

  /// Existing rung texts, smallest first, so the service can go below them.
  final List<String> currentLadder;

  /// The rung the person is looking at. With [goSmaller] the result must be
  /// steps that are smaller than or equal to it.
  final String? currentRung;
  final int? currentRungMinutes;

  /// One line on how the person is feeling. Sets how small to start.
  final String? feelingNote;
  final bool goSmaller;
  final int maxSteps;
}

@immutable
class BreakdownResult {
  const BreakdownResult({required this.steps, required this.source, this.note});

  final List<MicroStep> steps;

  /// Human-readable origin, e.g. "Built-in ladders" or "Claude (model)".
  final String source;

  /// A short neutral note from the service, if any. Never motivational copy.
  final String? note;
}

class BreakdownException implements Exception {
  BreakdownException(this.message, {this.cause, this.retryable = false});

  final String message;
  final Object? cause;
  final bool retryable;

  @override
  String toString() => 'BreakdownException: $message';
}

/// Breaks a task into a ladder of micro-steps. Implementations must be async
/// and must never be awaited by the timer.
abstract class TaskBreakdownService {
  String get name;

  /// Cheap check used to decide which service the UI offers.
  Future<bool> isAvailable();

  Future<BreakdownResult> breakDown(BreakdownRequest request);
}
