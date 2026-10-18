import 'package:meta/meta.dart';

import '../domain/entities/approach_target.dart';
import '../domain/entities/phase.dart';

/// The small bundle of facts a side service (companion voice, music) gets
/// when an interval starts. Nothing in here is required to be non-null.
@immutable
class SessionContext {
  const SessionContext({
    required this.runId,
    required this.phase,
    required this.planned,
    this.target,
    this.moodBefore,
  });

  final String runId;
  final Phase phase;
  final Duration planned;
  final ApproachTarget? target;
  final String? moodBefore;
}
