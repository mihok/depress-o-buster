import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// Schema notes (for a future sync layer):
// * Every row id is a client-generated UUID string, never an autoincrement.
// * Every mutable table has `updatedAt` (UTC). Adding `deletedAt` tombstones
//   and a `dirty` flag would be enough for last-writer-wins sync.
// * DateTimes are stored as ISO-8601 text in UTC (see build.yaml).

@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// The task's own rest unit in seconds; null follows Settings. Schema 3.
  IntColumn get restUnitSeconds => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LadderStepRow')
class LadderSteps extends Table {
  TextColumn get id => text()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get stepText => text()();
  IntColumn get suggestedSeconds => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PresetRow')
class Presets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get approachSeconds => integer()();
  IntColumn get restSeconds => integer()();
  IntColumn get longRestSeconds => integer().nullable()();
  IntColumn get cyclesBeforeLongRest => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get builtIn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get runId => text()();
  // Not a foreign key on purpose: history outlives deleted tasks.
  TextColumn get taskId => text().nullable()();
  TextColumn get taskTitle => text().nullable()();
  // Stable rung identity; positions are only a snapshot (ladders get edited).
  TextColumn get rungId => text().nullable()();
  IntColumn get rungPosition => integer().nullable()();
  TextColumn get rungText => text().nullable()();
  TextColumn get phase => text()();
  IntColumn get plannedSeconds => integer()();
  IntColumn get actualSeconds => integer()();
  TextColumn get outcome => text()();
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  TextColumn get moodBefore => text().nullable()();
  TextColumn get moodAfter => text().nullable()();
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();
  // Comma-separated XpBonus names.
  TextColumn get xpBonuses => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Single row (id = 1) of aggregate state the XP rules need.
@DataClassName('ProgressRow')
class Progress extends Table {
  IntColumn get id => integer()();
  IntColumn get totalXp => integer().withDefault(const Constant(0))();
  RealColumn get consistency => real().withDefault(const Constant(1.0))();
  DateTimeColumn get lastActiveDay => dateTime().nullable()();
  IntColumn get totalCompletedIntervals => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Tasks, LadderSteps, Presets, Sessions, Progress])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The on-device database in the app's documents directory.
  AppDatabase.open()
    : super(
        driftDatabase(
          name: 'depress_o_buster',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.addColumn(sessions, sessions.rungId);
      if (from < 3) await m.addColumn(tasks, tasks.restUnitSeconds);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
