import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/entities.dart';
import '../../domain/ladder/ladder_logic.dart';
import '../../domain/ladder/step_scaling.dart';
import '../db/database.dart';
import '../mappers.dart';

class TaskRepository {
  TaskRepository(this._db, {String Function()? idFactory})
    : _newId = idFactory ?? const Uuid().v4;

  final AppDatabase _db;
  final String Function() _newId;

  Stream<List<Task>> watchActiveTasks() => _activeQuery().watch().map(
    (rows) => rows.map(taskFromRow).toList(),
  );

  Future<List<Task>> activeTasks() async =>
      (await _activeQuery().get()).map(taskFromRow).toList();

  SimpleSelectStatement<$TasksTable, TaskRow> _activeQuery() =>
      _db.select(_db.tasks)
        ..where((t) => t.archived.equals(false))
        ..orderBy([
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.createdAt),
        ]);

  Future<Task?> getTask(String id) async {
    final row = await (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : taskFromRow(row);
  }

  Future<Task> createTask(
    String title, {
    String? note,
    List<MicroStep> ladder = const [],
    int? sortOrder,
    Duration? restUnit,
  }) async {
    final now = clock.now();
    final order = sortOrder ?? await _nextSortOrder();
    final task = Task(
      id: _newId(),
      title: title.trim(),
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
      createdAt: now,
      sortOrder: order,
      restUnit: restUnit,
    );
    final steps = LadderLogic.fromMicroSteps(task.id, ladder, _newId);
    await _db.transaction(() async {
      await _db.into(_db.tasks).insert(taskToCompanion(task, now));
      for (final s in steps) {
        await _db.into(_db.ladderSteps).insert(stepToCompanion(s, now));
      }
    });
    return task;
  }

  Future<int> _nextSortOrder() async {
    final maxOrder = _db.tasks.sortOrder.max();
    final q = _db.selectOnly(_db.tasks)..addColumns([maxOrder]);
    final row = await q.getSingleOrNull();
    return (row?.read(maxOrder) ?? -1) + 1;
  }

  Future<void> updateTask(Task task) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id)))
        .write(taskToCompanion(task, clock.now()));
  }

  /// Set the task's own rest unit (null: follow Settings again).
  Future<void> setRestUnit(String taskId, Duration? unit) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        restUnitSeconds: Value(unit?.inSeconds),
        updatedAt: Value(clock.now().toUtc()),
      ),
    );
  }

  Future<void> archiveTask(String id, {bool archived = true}) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        archived: Value(archived),
        updatedAt: Value(clock.now().toUtc()),
      ),
    );
  }

  Future<void> deleteTask(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.ladderSteps)..where((s) => s.taskId.equals(id))).go();
      await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
    });
  }

  Stream<List<LadderStep>> watchLadder(String taskId) =>
      _ladderQuery(taskId).watch().map((rows) => rows.map(stepFromRow).toList());

  Future<List<LadderStep>> ladder(String taskId) async =>
      (await _ladderQuery(taskId).get()).map(stepFromRow).toList();

  SimpleSelectStatement<$LadderStepsTable, LadderStepRow> _ladderQuery(
    String taskId,
  ) =>
      _db.select(_db.ladderSteps)
        ..where((s) => s.taskId.equals(taskId))
        ..orderBy([(s) => OrderingTerm.asc(s.position)]);

  /// Replace the whole ladder. Positions are renumbered.
  Future<void> replaceLadder(String taskId, List<LadderStep> steps) async {
    final now = clock.now();
    final renumbered = LadderLogic.renumber(steps);
    await _db.transaction(() async {
      await (_db.delete(_db.ladderSteps)..where((s) => s.taskId.equals(taskId))).go();
      for (final s in renumbered) {
        await _db.into(_db.ladderSteps).insert(stepToCompanion(s, now));
      }
    });
  }

  /// Append (or insert at [at]) a new rung and return it.
  Future<LadderStep> addStep(
    String taskId,
    String text, {
    Duration? suggestedDuration,
    int? at,
  }) async {
    final current = await ladder(taskId);
    final step = LadderStep(
      id: _newId(),
      taskId: taskId,
      position: at ?? current.length,
      text: text.trim(),
      suggestedDuration: suggestedDuration,
    );
    final next = LadderLogic.insertAt(current, at ?? current.length, step);
    await replaceLadder(taskId, next);
    return next.firstWhere((s) => s.id == step.id);
  }

  Future<void> updateStep(LadderStep step) async {
    await (_db.update(_db.ladderSteps)..where((s) => s.id.equals(step.id)))
        .write(stepToCompanion(step, clock.now()));
  }

  Future<void> deleteStep(String taskId, String stepId) async {
    final current = await ladder(taskId);
    await replaceLadder(taskId, LadderLogic.remove(current, stepId));
  }

  /// Put a removed step back exactly as it was: same id, same position,
  /// same text and time. Logged sessions and the "highest step" bonus refer
  /// to steps by id, so an undo must not mint a new one. A step that is
  /// already on the ladder is left alone.
  Future<void> restoreStep(String taskId, LadderStep step) async {
    if (await getTask(taskId) == null) return;
    final current = await ladder(taskId);
    if (current.any((s) => s.id == step.id)) return;
    await replaceLadder(taskId, LadderLogic.insertAt(current, step.position, step));
  }

  /// Put back the suggested times of [steps] (matched by id) in one
  /// transaction; steps that no longer exist are skipped. The way back after
  /// the step-length slider.
  Future<void> restoreStepDurations(String taskId, List<LadderStep> steps) async {
    final now = clock.now();
    await _db.transaction(() async {
      final current = {for (final s in await ladder(taskId)) s.id: s};
      for (final old in steps) {
        final live = current[old.id];
        if (live == null || live.suggestedDuration == old.suggestedDuration) continue;
        final restored = live.copyWith(
          suggestedDuration: old.suggestedDuration,
          clearSuggestedDuration: old.suggestedDuration == null,
        );
        await (_db.update(_db.ladderSteps)..where((s) => s.id.equals(old.id)))
            .write(stepToCompanion(restored, now));
      }
    });
  }

  /// Multiply every step's suggested time by [factor] in one transaction,
  /// rounded by [StepScaling.round]. Steps without a time keep none.
  /// Returns how many steps actually changed.
  Future<int> scaleStepDurations(String taskId, double factor) async {
    final now = clock.now();
    return _db.transaction(() async {
      final current = await ladder(taskId);
      final scaled = StepScaling.scaleAll(current, factor);
      var changed = 0;
      for (var i = 0; i < current.length; i++) {
        if (scaled[i].suggestedDuration == current[i].suggestedDuration) continue;
        await (_db.update(_db.ladderSteps)..where((s) => s.id.equals(scaled[i].id)))
            .write(stepToCompanion(scaled[i], now));
        changed++;
      }
      return changed;
    });
  }

  Future<void> reorderSteps(String taskId, int oldIndex, int newIndex) async {
    final current = await ladder(taskId);
    await replaceLadder(taskId, LadderLogic.reorder(current, oldIndex, newIndex));
  }
}
