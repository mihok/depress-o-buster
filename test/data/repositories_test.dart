import 'package:clock/clock.dart';
import 'package:depress_o_buster/data/db/database.dart';
import 'package:depress_o_buster/data/mappers.dart';
import 'package:depress_o_buster/data/repositories/preset_repository.dart';
import 'package:depress_o_buster/data/repositories/progress_repository.dart';
import 'package:depress_o_buster/data/repositories/session_repository.dart';
import 'package:depress_o_buster/data/repositories/task_repository.dart';
import 'package:depress_o_buster/data/seed/seed_data.dart';
import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/xp/xp_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TaskRepository tasks;
  late PresetRepository presets;
  late SessionRepository sessions;
  late ProgressRepository progress;
  final now = DateTime(2026, 10, 18, 10);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    var n = 0;
    tasks = TaskRepository(db, idFactory: () => 'id-${n++}');
    presets = PresetRepository(db, idFactory: () => 'p-${n++}');
    sessions = SessionRepository(db);
    progress = ProgressRepository(db);
  });

  tearDown(() async => db.close());

  Session session({
    required String id,
    String? taskId,
    int? rung,
    String? rungId,
    Phase phase = Phase.approach,
    SessionOutcome outcome = SessionOutcome.completed,
    Duration actual = const Duration(minutes: 5),
    DateTime? endedAt,
    int xp = 0,
  }) {
    final end = endedAt ?? now;
    return Session(
      id: id,
      runId: 'run-$id',
      taskId: taskId,
      taskTitle: taskId == null ? null : 'Task $taskId',
      rungId: rungId,
      rungPosition: rung,
      rungText: rung == null ? null : 'Rung $rung',
      phase: phase,
      planned: const Duration(minutes: 5),
      actual: actual,
      outcome: outcome,
      startedAt: end.subtract(actual),
      endedAt: end,
      xpEarned: xp,
    );
  }

  group('TaskRepository', () {
    test('creates a task with a ladder and streams it', () async {
      final task = await withClock(Clock.fixed(now), () => tasks.createTask(
        'Laundry',
        note: '',
        ladder: StarterLadders.byTitle['Laundry']!,
      ));
      expect(task.title, 'Laundry');
      expect(task.note, isNull);
      expect(task.createdAt, now);
      final list = await tasks.activeTasks();
      expect(list, [task]);
      final ladder = await tasks.ladder(task.id);
      expect(ladder, hasLength(9));
      expect(ladder.map((s) => s.position), List.generate(9, (i) => i));
      expect(ladder.first.text, 'Think about laundry for 1 minute');
      expect(ladder.first.suggestedDuration, const Duration(minutes: 1));
      expect(await tasks.watchLadder(task.id).first, ladder);
      expect((await tasks.getTask(task.id)), task);
      expect(await tasks.getTask('nope'), isNull);
    });

    test('sort order grows and tasks come back in order', () async {
      final a = await tasks.createTask('A');
      final b = await tasks.createTask('B');
      expect(a.sortOrder, 0);
      expect(b.sortOrder, 1);
      expect((await tasks.activeTasks()).map((t) => t.title), ['A', 'B']);
    });

    test('edits ladders: add, reorder, update, delete', () async {
      final task = await tasks.createTask('Shower', ladder: const [MicroStep('a'), MicroStep('b'), MicroStep('c')]);
      final added = await tasks.addStep(task.id, 'd', suggestedDuration: const Duration(minutes: 3));
      expect(added.position, 3);
      await tasks.reorderSteps(task.id, 3, 0);
      var ladder = await tasks.ladder(task.id);
      expect(ladder.map((s) => s.text), ['d', 'a', 'b', 'c']);
      await tasks.reorderSteps(task.id, 0, 3);
      expect((await tasks.ladder(task.id)).map((s) => s.text), ['a', 'b', 'c', 'd']);
      await tasks.reorderSteps(task.id, 3, 0);
      ladder = await tasks.ladder(task.id);
      expect(ladder.map((s) => s.position), [0, 1, 2, 3]);
      await tasks.updateStep(ladder[1].copyWith(text: 'A!'));
      await tasks.deleteStep(task.id, ladder[2].id);
      ladder = await tasks.ladder(task.id);
      expect(ladder.map((s) => s.text), ['d', 'A!', 'c']);
      expect(ladder.map((s) => s.position), [0, 1, 2]);
      final inserted = await tasks.addStep(task.id, 'first', at: 0);
      expect(inserted.position, 0);
      expect((await tasks.ladder(task.id)).first.text, 'first');
    });

    test('restoreStep puts a removed step back with its id, position and time', () async {
      final task = await tasks.createTask('Shower', ladder: const [
        MicroStep('a'),
        MicroStep('b', suggestedDuration: Duration(seconds: 90)),
        MicroStep('c'),
      ]);
      final before = await tasks.ladder(task.id);
      final b = before[1];
      await tasks.deleteStep(task.id, b.id);
      expect((await tasks.ladder(task.id)).map((s) => s.id), [before[0].id, before[2].id]);

      await tasks.restoreStep(task.id, b);
      expect(await tasks.ladder(task.id), before, reason: 'same id, position, text and time');

      await tasks.restoreStep(task.id, b);
      expect(await tasks.ladder(task.id), before, reason: 'restoring twice does not duplicate');

      // A remembered position past the end lands at the end.
      await tasks.deleteStep(task.id, before[0].id);
      await tasks.restoreStep(task.id, before[0].copyWith(position: 9));
      final moved = await tasks.ladder(task.id);
      expect(moved.map((s) => s.id), [before[1].id, before[2].id, before[0].id]);
      expect(moved.map((s) => s.position), [0, 1, 2]);
    });

    test('scaleStepDurations scales every timed step at once and rounds', () async {
      final task = await tasks.createTask('Shower', ladder: const [
        MicroStep('a', suggestedDuration: Duration(seconds: 30)),
        MicroStep('b', suggestedDuration: Duration(minutes: 1)),
        MicroStep('c'),
        MicroStep('d', suggestedDuration: Duration(minutes: 5)),
        MicroStep('e', suggestedDuration: Duration(minutes: 7)),
      ]);
      final before = await tasks.ladder(task.id);

      expect(
        await tasks.scaleStepDurations(task.id, 0.5),
        3,
        reason: 'a 30-second step cannot shrink and an untimed step stays untimed',
      );
      final half = await tasks.ladder(task.id);
      expect(half.map((s) => s.suggestedDuration), const [
        Duration(seconds: 30),
        Duration(seconds: 30),
        null,
        Duration(minutes: 2, seconds: 30),
        Duration(minutes: 3, seconds: 30),
      ]);
      expect(half.map((s) => s.id), before.map((s) => s.id));
      expect(half.map((s) => s.text), ['a', 'b', 'c', 'd', 'e']);
      expect(half.map((s) => s.position), [0, 1, 2, 3, 4]);

      expect(await tasks.scaleStepDurations(task.id, 3), 4);
      expect((await tasks.ladder(task.id)).map((s) => s.suggestedDuration), const [
        Duration(minutes: 1, seconds: 30),
        Duration(minutes: 1, seconds: 30),
        null,
        Duration(minutes: 8),
        Duration(minutes: 11),
      ]);

      expect(await tasks.scaleStepDurations(task.id, 1), 0, reason: 'nothing changes, nothing is written');
      expect(await tasks.watchLadder(task.id).first, await tasks.ladder(task.id));
    });

    test('archive hides, delete cascades to steps', () async {
      final task = await tasks.createTask('Dishes', ladder: const [MicroStep('x')]);
      await tasks.archiveTask(task.id);
      expect(await tasks.activeTasks(), isEmpty);
      expect((await tasks.getTask(task.id))!.archived, isTrue);
      await tasks.archiveTask(task.id, archived: false);
      expect(await tasks.activeTasks(), hasLength(1));
      await tasks.deleteTask(task.id);
      expect(await tasks.getTask(task.id), isNull);
      expect(await tasks.ladder(task.id), isEmpty);
    });

    test('updateTask changes title and note', () async {
      final task = await tasks.createTask('Old');
      await tasks.updateTask(task.copyWith(title: 'New', note: 'a note'));
      final t = await tasks.getTask(task.id);
      expect(t!.title, 'New');
      expect(t.note, 'a note');
    });
  });

  group('PresetRepository', () {
    test('create, order, update, delete', () async {
      final a = await presets.create(name: 'Edge of bed', approach: const Duration(minutes: 2), rest: const Duration(minutes: 20));
      final b = await presets.create(
        name: 'Classic',
        approach: const Duration(minutes: 25),
        rest: const Duration(minutes: 5),
        longRest: const Duration(minutes: 20),
        cyclesBeforeLongRest: 4,
      );
      expect(a.sortOrder, 0);
      expect(b.sortOrder, 1);
      expect(b.ratioLabel, '25/5');
      final all = await presets.all();
      expect(all.map((p) => p.name), ['Edge of bed', 'Classic']);
      expect(all.last.longRest, const Duration(minutes: 20));
      expect(all.last.cyclesBeforeLongRest, 4);
      await presets.upsert(a.copyWith(name: 'Edge', rest: const Duration(seconds: 90)));
      final got = await presets.get(a.id);
      expect(got!.name, 'Edge');
      expect(got.rest, const Duration(seconds: 90));
      expect(got.ratioLabel, '2/1m30s');
      await presets.delete(a.id);
      expect((await presets.all()).map((p) => p.id), [b.id]);
      expect(await presets.watchAll().first, hasLength(1));
    });
  });

  group('SessionRepository', () {
    test('round-trips timestamps to the second and streams newest first', () async {
      final s = session(id: 's1', endedAt: DateTime(2026, 10, 18, 9, 5, 7));
      await sessions.insert(s);
      final got = await sessions.get('s1');
      expect(got!.endedAt, s.endedAt);
      expect(got.startedAt, s.startedAt);
      expect(got.endedAt.isUtc, isFalse);
      await sessions.insert(session(id: 's2', endedAt: DateTime(2026, 10, 18, 11)));
      final recent = await sessions.watchRecent().first;
      expect(recent.map((x) => x.id), ['s2', 's1']);
      expect(await sessions.totalCount(), 2);
    });

    test('task queries: last approach, max rung, longest, per task', () async {
      await sessions.insert(session(id: 'a', taskId: 't1', rung: 2, endedAt: now.subtract(const Duration(days: 2))));
      await sessions.insert(session(id: 'b', taskId: 't1', rung: 5, outcome: SessionOutcome.abandoned, actual: const Duration(minutes: 40), endedAt: now.subtract(const Duration(days: 1))));
      await sessions.insert(session(id: 'c', taskId: 't1', rung: 3, actual: const Duration(minutes: 8), endedAt: now));
      await sessions.insert(session(id: 'r', taskId: 't1', phase: Phase.rest, actual: const Duration(minutes: 60), endedAt: now));
      await sessions.insert(session(id: 'd', taskId: 't2', rung: 0, actual: const Duration(minutes: 1), endedAt: now));
      expect((await sessions.lastApproachOnTask('t1'))!.id, 'c');
      expect(await sessions.maxRungOnTask('t1'), 5);
      expect(await sessions.maxRungOnTask('t9'), isNull);
      expect(await sessions.lastApproachOnTask('t9'), isNull);
      expect(await sessions.longestApproach(), const Duration(minutes: 8), reason: 'abandoned and rests excluded');
      expect((await sessions.approachesForTask('t1')).map((s) => s.id), ['a', 'b', 'c']);
      expect(await sessions.totalCompleted(), 4);
      // Without a ladder the stored positions are used as they are.
      final progressByTask = await sessions.rungProgressByTask();
      expect(progressByTask['t1']!.bestRung, 5);
      expect(progressByTask['t1']!.latestRung, 3);
      expect(progressByTask['t1']!.attempts, 3);
      expect(progressByTask['t2']!.bestRung, 0);
    });

    test('rung progress follows the current ladder by rung id', () async {
      final task = await tasks.createTask('Laundry', ladder: const [MicroStep('a'), MicroStep('b'), MicroStep('c'), MicroStep('d')]);
      final ladder = await tasks.ladder(task.id);
      await sessions.insert(session(id: 's1', taskId: task.id, rung: 1, rungId: ladder[1].id, endedAt: now.subtract(const Duration(days: 2))));
      await sessions.insert(session(id: 's2', taskId: task.id, rung: 3, rungId: ladder[3].id, endedAt: now.subtract(const Duration(days: 1))));
      await sessions.insert(session(id: 'legacy', taskId: task.id, rung: 9, endedAt: now));
      // Insert a smaller rung at the top: every stored position is now stale.
      await tasks.addStep(task.id, 'tiny', at: 0);
      final current = await tasks.ladder(task.id);
      final byTask = await sessions.rungProgressByTask(ladders: {task.id: current});
      final p = byTask[task.id]!;
      expect(p.bestRung, 4, reason: 'rung d moved from 3 to 4');
      expect(p.bestRungText, 'd');
      expect(p.latestRung, 4, reason: 'legacy position 9 is clamped to the ladder');
      expect(p.attempts, 3);
      // Remove rung d: sessions on it no longer count.
      await tasks.deleteStep(task.id, ladder[3].id);
      final after = await sessions.rungProgressByTask(ladders: {task.id: await tasks.ladder(task.id)});
      expect(after[task.id]!.bestRung, 3, reason: 'legacy session clamped to the new top rung');
      expect(SessionRepository.resolveRung(session(id: 'x', taskId: task.id, rung: 2, rungId: 'gone'), current), isNull);
      expect(SessionRepository.resolveRung(session(id: 'y', taskId: task.id, rung: 2), null)!.position, 2);
    });

    test('per-day counts cover the window with zeros', () async {
      await sessions.insert(session(id: 'a', endedAt: DateTime(2026, 10, 18, 8)));
      await sessions.insert(session(id: 'b', endedAt: DateTime(2026, 10, 18, 23, 59)));
      await sessions.insert(session(id: 'c', endedAt: DateTime(2026, 10, 16, 0, 0, 1)));
      await sessions.insert(session(id: 'old', endedAt: DateTime(2026, 9, 1)));
      await sessions.insert(session(id: 'rest', phase: Phase.rest, endedAt: DateTime(2026, 10, 18, 9)));
      final days = await sessions.approachesPerDay(days: 3, now: now);
      expect(days.map((d) => d.day), [DateTime(2026, 10, 16), DateTime(2026, 10, 17), DateTime(2026, 10, 18)]);
      expect(days.map((d) => d.count), [1, 0, 2]);
      expect(await sessions.countCompletedOn(DateTime(2026, 10, 18)), 3);
      expect(await sessions.countCompletedOn(DateTime(2026, 10, 17)), 0);
    });

    test('mood updates only touch the given fields', () async {
      await sessions.insert(session(id: 's'));
      await sessions.updateMood('s', before: 'flat');
      await sessions.updateMood('s', after: 'okay');
      final got = await sessions.get('s');
      expect(got!.moodBefore, 'flat');
      expect(got.moodAfter, 'okay');
    });
  });

  group('ProgressRepository', () {
    test('lastActiveDay is a calendar date in UTC, whatever the local zone', () {
      // Written as noon UTC of the date; read back in UTC, never via toLocal().
      expect(activeDayToStored(DateTime(2026, 10, 17)), DateTime.utc(2026, 10, 17, 12));
      expect(activeDayFromStored(DateTime.utc(2026, 10, 17, 12)), DateTime(2026, 10, 17));
      // A +13:00 zone would read noon UTC as the 18th through toLocal(); the
      // UTC frame keeps the 17th.
      final asSeenAtPlus13 = DateTime.utc(2026, 10, 17, 12).add(const Duration(hours: 13));
      expect(asSeenAtPlus13.day, 18);
      expect(activeDayFromStored(DateTime.utc(2026, 10, 17, 12)).day, 17);
    });

    test('get creates the default row; save round-trips a date-only last active day', () async {
      expect(await progress.get(), const ProgressSnapshot());
      await progress.save(const ProgressSnapshot(totalXp: 120, consistency: 1.15, totalCompletedIntervals: 3).copyWith(lastActiveDay: DateTime(2026, 10, 17)));
      final got = await progress.get();
      expect(got.totalXp, 120);
      expect(got.consistency, 1.15);
      expect(got.lastActiveDay, DateTime(2026, 10, 17));
      expect(got.totalCompletedIntervals, 3);
      expect((await progress.watch().first).totalXp, 120);
      await progress.reset();
      expect((await progress.get()).totalXp, 0);
    });
  });

  group('SeedData', () {
    test('seeds starter tasks and presets once', () async {
      await SeedData.seedIfEmpty(tasks: tasks, presets: presets);
      await SeedData.seedIfEmpty(tasks: tasks, presets: presets);
      final t = await tasks.activeTasks();
      expect(t.map((x) => x.title), SeedData.starterTaskTitles);
      expect((await tasks.ladder(t.first.id)).first.text, contains('eyes open'));
      final p = await presets.all();
      expect(p, hasLength(SeedData.presets.length));
      expect(p.first.name, 'Just sit up');
      expect(p.every((x) => x.builtIn), isTrue);
    });
  });

  group('XpService', () {
    late XpService xp;
    setUp(() {
      var n = 0;
      xp = XpService(sessions: sessions, progress: progress, tasks: tasks, idFactory: () => 'x-${n++}');
    });

    PhaseEnded ended({
      Phase phase = Phase.approach,
      SessionOutcome outcome = SessionOutcome.completed,
      Duration actual = const Duration(minutes: 1),
      ApproachTarget? target,
      DateTime? at,
      String runId = 'run',
    }) {
      final end = at ?? now;
      return PhaseEnded(
        runId: runId,
        phase: phase,
        target: target,
        planned: const Duration(minutes: 1),
        actual: actual,
        extended: Duration.zero,
        snoozeCount: 0,
        outcome: outcome,
        startedAt: end.subtract(actual),
        endedAt: end,
        auto: true,
        cycleIndex: 1,
      );
    }

    test('first interval ever gets the big bonus and bumps consistency', () async {
      final logged = await xp.logPhase(ended(), moodBefore: 'flat');
      expect(logged.isFirstEver, isTrue);
      expect(logged.award.base, 30);
      expect(logged.award.multiplier, 1.05);
      expect(logged.award.bonuses, [XpBonus.firstEver, XpBonus.firstToday]);
      expect(logged.award.total, 32 + 60);
      expect(logged.totalXp, 92);
      expect(logged.session.moodBefore, 'flat');
      expect(logged.session.xpBonuses, ['firstEver', 'firstToday']);
      expect(logged.levelBefore, 1);
      expect(logged.levelAfter, 1);
      final p = await progress.get();
      expect(p.totalXp, 92);
      expect(p.consistency, 1.05);
      expect(p.lastActiveDay, DateTime(2026, 10, 18));
      expect(p.totalCompletedIntervals, 1);
      expect(await sessions.totalCount(), 1);
    });

    test('second interval the same day: no daily bonus, same multiplier', () async {
      await xp.logPhase(ended());
      final rest = await xp.logPhase(ended(phase: Phase.rest, at: now.add(const Duration(minutes: 10))));
      expect(rest.award.base, 12);
      expect(rest.award.bonuses, isEmpty);
      expect(rest.award.multiplier, 1.05);
      expect(rest.isFirstEver, isFalse);
      expect((await progress.get()).consistency, 1.05);
    });

    test('coming back after four days is welcomed, consistency decays gently', () async {
      await xp.logPhase(ended(at: DateTime(2026, 10, 10, 9)));
      final back = await xp.logPhase(ended(at: DateTime(2026, 10, 14, 9)));
      expect(back.isWelcomeBack, isTrue);
      expect(back.award.bonuses, [XpBonus.welcomeBack, XpBonus.firstToday]);
      // 1.05 - 3 * 0.03 = 0.96 -> clamped 1.0, then +0.05
      expect(back.award.multiplier, 1.05);
      expect((await progress.get()).lastActiveDay, DateTime(2026, 10, 14));
    });

    test('abandoned approaches earn start XP, do not mark the day active', () async {
      final logged = await xp.logPhase(ended(outcome: SessionOutcome.abandoned, actual: Duration.zero));
      expect(logged.award.base, 10);
      expect(logged.award.bonuses, [XpBonus.firstEver]);
      final p = await progress.get();
      expect(p.lastActiveDay, isNull);
      expect(p.totalCompletedIntervals, 0);
      expect(p.totalXp, 60);
      expect(p.consistency, 1.0);
    });

    test('rung bonuses come from the task history, by rung id', () async {
      final task = await tasks.createTask('Laundry', ladder: StarterLadders.byTitle['Laundry']!);
      final ladder = await tasks.ladder(task.id);
      ApproachTarget at(int position) => ApproachTarget(
        taskId: task.id,
        taskTitle: task.title,
        rungId: ladder[position].id,
        rungPosition: position,
        rungText: ladder[position].text,
      );
      await xp.logPhase(ended(target: at(2), at: now.subtract(const Duration(days: 1))));
      final higher = await xp.logPhase(ended(target: at(4), at: now));
      expect(higher.award.bonuses, contains(XpBonus.newPersonalRung));
      final lower = await xp.logPhase(ended(target: at(3), at: now.add(const Duration(hours: 1))));
      expect(lower.award.bonuses, isEmpty, reason: 'lower than last time, not a new max');
      final climb = await xp.logPhase(ended(target: at(4), at: now.add(const Duration(hours: 2))));
      expect(climb.award.bonuses, [XpBonus.climbedLadder]);
      expect(climb.session.taskTitle, 'Laundry');
      expect(climb.session.rungPosition, 4);
      expect(climb.session.rungId, ladder[4].id);

      // Replace the ladder: old rungs are gone, so the first attempt on the
      // new ladder has nothing to compare with and earns no rung bonus; the
      // next higher one does.
      await tasks.replaceLadder(task.id, LadderLogic.fromMicroSteps(task.id, const [MicroStep('x'), MicroStep('y'), MicroStep('z')], () => 'new-${DateTime.now().microsecondsSinceEpoch}'));
      final fresh = await tasks.ladder(task.id);
      ApproachTarget fresher(int position) => ApproachTarget(
        taskId: task.id,
        taskTitle: task.title,
        rungId: fresh[position].id,
        rungPosition: position,
        rungText: fresh[position].text,
      );
      final first = await xp.logPhase(ended(target: fresher(0), at: now.add(const Duration(hours: 3))));
      expect(first.award.bonuses, isEmpty);
      final second = await xp.logPhase(ended(target: fresher(2), at: now.add(const Duration(hours: 4))));
      expect(second.award.bonuses, [XpBonus.newPersonalRung]);
    });

    test('levelling up is reported', () async {
      await progress.save(const ProgressSnapshot(totalXp: 150));
      final logged = await xp.logPhase(ended(at: now));
      expect(logged.levelBefore, 1);
      expect(logged.levelAfter, 2);
      expect(logged.leveledUp, isTrue);
    });

    test('daysSinceLastActive', () async {
      expect(await xp.daysSinceLastActive(now: now), isNull);
      await xp.logPhase(ended(at: DateTime(2026, 10, 15, 9)));
      expect(await xp.daysSinceLastActive(now: now), 3);
    });
  });
}
