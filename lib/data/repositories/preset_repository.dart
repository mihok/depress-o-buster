import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/entities.dart';
import '../db/database.dart';
import '../mappers.dart';

class PresetRepository {
  PresetRepository(this._db, {String Function()? idFactory})
    : _newId = idFactory ?? const Uuid().v4;

  final AppDatabase _db;
  final String Function() _newId;

  Stream<List<Preset>> watchAll() =>
      _query().watch().map((rows) => rows.map(presetFromRow).toList());

  Future<List<Preset>> all() async => (await _query().get()).map(presetFromRow).toList();

  SimpleSelectStatement<$PresetsTable, PresetRow> _query() =>
      _db.select(_db.presets)..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]);

  Future<Preset?> get(String id) async {
    final row = await (_db.select(_db.presets)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : presetFromRow(row);
  }

  Future<Preset> create({
    required String name,
    required Duration approach,
    required Duration rest,
    Duration? longRest,
    int cyclesBeforeLongRest = 0,
  }) async {
    final maxOrder = _db.presets.sortOrder.max();
    final q = _db.selectOnly(_db.presets)..addColumns([maxOrder]);
    final order = ((await q.getSingleOrNull())?.read(maxOrder) ?? -1) + 1;
    final preset = Preset(
      id: _newId(),
      name: name.trim(),
      approach: approach,
      rest: rest,
      longRest: longRest,
      cyclesBeforeLongRest: cyclesBeforeLongRest,
      sortOrder: order,
    );
    await upsert(preset);
    return preset;
  }

  Future<void> upsert(Preset preset) async {
    await _db
        .into(_db.presets)
        .insertOnConflictUpdate(presetToCompanion(preset, clock.now()));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.presets)..where((p) => p.id.equals(id))).go();
  }
}
