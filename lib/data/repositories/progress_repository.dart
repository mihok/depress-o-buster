import 'package:clock/clock.dart';
import 'package:drift/drift.dart';

import '../../domain/entities/entities.dart';
import '../db/database.dart';
import '../mappers.dart';

class ProgressRepository {
  ProgressRepository(this._db);

  final AppDatabase _db;
  static const int _rowId = 1;

  Future<ProgressSnapshot> get() async {
    final row = await (_db.select(_db.progress)..where((p) => p.id.equals(_rowId)))
        .getSingleOrNull();
    if (row != null) return progressFromRow(row);
    await _db.into(_db.progress).insert(
      ProgressCompanion(
        id: const Value(_rowId),
        updatedAt: Value(clock.now().toUtc()),
      ),
    );
    return const ProgressSnapshot();
  }

  Stream<ProgressSnapshot> watch() {
    // Make sure the row exists, then watch it.
    get();
    return (_db.select(_db.progress)..where((p) => p.id.equals(_rowId)))
        .watchSingleOrNull()
        .map((row) => row == null ? const ProgressSnapshot() : progressFromRow(row));
  }

  Future<void> save(ProgressSnapshot snapshot) async {
    final last = snapshot.lastActiveDay;
    await _db.into(_db.progress).insertOnConflictUpdate(
      ProgressCompanion(
        id: const Value(_rowId),
        totalXp: Value(snapshot.totalXp),
        consistency: Value(snapshot.consistency),
        lastActiveDay: Value(
          last == null ? null : DateTime.utc(last.year, last.month, last.day, 12),
        ),
        totalCompletedIntervals: Value(snapshot.totalCompletedIntervals),
        updatedAt: Value(clock.now().toUtc()),
      ),
    );
  }

  Future<void> reset() => save(const ProgressSnapshot());
}
