import 'package:drift/drift.dart';

import '../domain/entities/entities.dart';
import 'db/database.dart';

Task taskFromRow(TaskRow r) => Task(
  id: r.id,
  title: r.title,
  note: r.note,
  createdAt: r.createdAt.toLocal(),
  archived: r.archived,
  sortOrder: r.sortOrder,
);

TasksCompanion taskToCompanion(Task t, DateTime now) => TasksCompanion(
  id: Value(t.id),
  title: Value(t.title),
  note: Value(t.note),
  createdAt: Value(t.createdAt.toUtc()),
  updatedAt: Value(now.toUtc()),
  archived: Value(t.archived),
  sortOrder: Value(t.sortOrder),
);

LadderStep stepFromRow(LadderStepRow r) => LadderStep(
  id: r.id,
  taskId: r.taskId,
  position: r.position,
  text: r.stepText,
  suggestedDuration:
      r.suggestedSeconds == null ? null : Duration(seconds: r.suggestedSeconds!),
);

LadderStepsCompanion stepToCompanion(LadderStep s, DateTime now) =>
    LadderStepsCompanion(
      id: Value(s.id),
      taskId: Value(s.taskId),
      position: Value(s.position),
      stepText: Value(s.text),
      suggestedSeconds: Value(s.suggestedDuration?.inSeconds),
      updatedAt: Value(now.toUtc()),
    );

Preset presetFromRow(PresetRow r) => Preset(
  id: r.id,
  name: r.name,
  approach: Duration(seconds: r.approachSeconds),
  rest: Duration(seconds: r.restSeconds),
  longRest: r.longRestSeconds == null ? null : Duration(seconds: r.longRestSeconds!),
  cyclesBeforeLongRest: r.cyclesBeforeLongRest,
  sortOrder: r.sortOrder,
  builtIn: r.builtIn,
);

PresetsCompanion presetToCompanion(Preset p, DateTime now) => PresetsCompanion(
  id: Value(p.id),
  name: Value(p.name),
  approachSeconds: Value(p.approach.inSeconds),
  restSeconds: Value(p.rest.inSeconds),
  longRestSeconds: Value(p.longRest?.inSeconds),
  cyclesBeforeLongRest: Value(p.cyclesBeforeLongRest),
  sortOrder: Value(p.sortOrder),
  builtIn: Value(p.builtIn),
  updatedAt: Value(now.toUtc()),
);

Session sessionFromRow(SessionRow r) => Session(
  id: r.id,
  runId: r.runId,
  taskId: r.taskId,
  taskTitle: r.taskTitle,
  rungPosition: r.rungPosition,
  rungText: r.rungText,
  phase: Phase.fromStorageKey(r.phase),
  planned: Duration(seconds: r.plannedSeconds),
  actual: Duration(seconds: r.actualSeconds),
  outcome: SessionOutcome.fromStorageKey(r.outcome),
  snoozeCount: r.snoozeCount,
  startedAt: r.startedAt.toLocal(),
  endedAt: r.endedAt.toLocal(),
  moodBefore: r.moodBefore,
  moodAfter: r.moodAfter,
  xpEarned: r.xpEarned,
  xpBonuses: r.xpBonuses.isEmpty ? const [] : r.xpBonuses.split(','),
);

SessionsCompanion sessionToCompanion(Session s, DateTime now) => SessionsCompanion(
  id: Value(s.id),
  runId: Value(s.runId),
  taskId: Value(s.taskId),
  taskTitle: Value(s.taskTitle),
  rungPosition: Value(s.rungPosition),
  rungText: Value(s.rungText),
  phase: Value(s.phase.storageKey),
  plannedSeconds: Value(s.planned.inSeconds),
  actualSeconds: Value(s.actual.inSeconds),
  outcome: Value(s.outcome.name),
  snoozeCount: Value(s.snoozeCount),
  startedAt: Value(s.startedAt.toUtc()),
  endedAt: Value(s.endedAt.toUtc()),
  moodBefore: Value(s.moodBefore),
  moodAfter: Value(s.moodAfter),
  xpEarned: Value(s.xpEarned),
  xpBonuses: Value(s.xpBonuses.join(',')),
  updatedAt: Value(now.toUtc()),
);

ProgressSnapshot progressFromRow(ProgressRow r) => ProgressSnapshot(
  totalXp: r.totalXp,
  consistency: r.consistency,
  lastActiveDay: r.lastActiveDay == null
      ? null
      : DateTime(r.lastActiveDay!.toLocal().year, r.lastActiveDay!.toLocal().month,
          r.lastActiveDay!.toLocal().day),
  totalCompletedIntervals: r.totalCompletedIntervals,
);
