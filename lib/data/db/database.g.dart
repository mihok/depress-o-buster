// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _restUnitSecondsMeta = const VerificationMeta(
    'restUnitSeconds',
  );
  @override
  late final GeneratedColumn<int> restUnitSeconds = GeneratedColumn<int>(
    'rest_unit_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    note,
    createdAt,
    updatedAt,
    archived,
    sortOrder,
    restUnitSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('rest_unit_seconds')) {
      context.handle(
        _restUnitSecondsMeta,
        restUnitSeconds.isAcceptableOrUnknown(
          data['rest_unit_seconds']!,
          _restUnitSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      restUnitSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_unit_seconds'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String title;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;
  final int sortOrder;

  /// The task's own rest unit in seconds; null follows Settings. Schema 3.
  final int? restUnitSeconds;
  const TaskRow({
    required this.id,
    required this.title,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.archived,
    required this.sortOrder,
    this.restUnitSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || restUnitSeconds != null) {
      map['rest_unit_seconds'] = Variable<int>(restUnitSeconds);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
      restUnitSeconds: restUnitSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restUnitSeconds),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      restUnitSeconds: serializer.fromJson<int?>(json['restUnitSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'restUnitSeconds': serializer.toJson<int?>(restUnitSeconds),
    };
  }

  TaskRow copyWith({
    String? id,
    String? title,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
    int? sortOrder,
    Value<int?> restUnitSeconds = const Value.absent(),
  }) => TaskRow(
    id: id ?? this.id,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
    restUnitSeconds: restUnitSeconds.present
        ? restUnitSeconds.value
        : this.restUnitSeconds,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      restUnitSeconds: data.restUnitSeconds.present
          ? data.restUnitSeconds.value
          : this.restUnitSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('restUnitSeconds: $restUnitSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    note,
    createdAt,
    updatedAt,
    archived,
    sortOrder,
    restUnitSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder &&
          other.restUnitSeconds == this.restUnitSeconds);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<int?> restUnitSeconds;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.restUnitSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.restUnitSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<int>? restUnitSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (restUnitSeconds != null) 'rest_unit_seconds': restUnitSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<int?>? restUnitSeconds,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      restUnitSeconds: restUnitSeconds ?? this.restUnitSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (restUnitSeconds.present) {
      map['rest_unit_seconds'] = Variable<int>(restUnitSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('restUnitSeconds: $restUnitSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LadderStepsTable extends LadderSteps
    with TableInfo<$LadderStepsTable, LadderStepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LadderStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepTextMeta = const VerificationMeta(
    'stepText',
  );
  @override
  late final GeneratedColumn<String> stepText = GeneratedColumn<String>(
    'step_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedSecondsMeta = const VerificationMeta(
    'suggestedSeconds',
  );
  @override
  late final GeneratedColumn<int> suggestedSeconds = GeneratedColumn<int>(
    'suggested_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    position,
    stepText,
    suggestedSeconds,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ladder_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<LadderStepRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('step_text')) {
      context.handle(
        _stepTextMeta,
        stepText.isAcceptableOrUnknown(data['step_text']!, _stepTextMeta),
      );
    } else if (isInserting) {
      context.missing(_stepTextMeta);
    }
    if (data.containsKey('suggested_seconds')) {
      context.handle(
        _suggestedSecondsMeta,
        suggestedSeconds.isAcceptableOrUnknown(
          data['suggested_seconds']!,
          _suggestedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LadderStepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LadderStepRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      stepText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_text'],
      )!,
      suggestedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suggested_seconds'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LadderStepsTable createAlias(String alias) {
    return $LadderStepsTable(attachedDatabase, alias);
  }
}

class LadderStepRow extends DataClass implements Insertable<LadderStepRow> {
  final String id;
  final String taskId;
  final int position;
  final String stepText;
  final int? suggestedSeconds;
  final DateTime updatedAt;
  const LadderStepRow({
    required this.id,
    required this.taskId,
    required this.position,
    required this.stepText,
    this.suggestedSeconds,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['position'] = Variable<int>(position);
    map['step_text'] = Variable<String>(stepText);
    if (!nullToAbsent || suggestedSeconds != null) {
      map['suggested_seconds'] = Variable<int>(suggestedSeconds);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LadderStepsCompanion toCompanion(bool nullToAbsent) {
    return LadderStepsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      position: Value(position),
      stepText: Value(stepText),
      suggestedSeconds: suggestedSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedSeconds),
      updatedAt: Value(updatedAt),
    );
  }

  factory LadderStepRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LadderStepRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      position: serializer.fromJson<int>(json['position']),
      stepText: serializer.fromJson<String>(json['stepText']),
      suggestedSeconds: serializer.fromJson<int?>(json['suggestedSeconds']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'position': serializer.toJson<int>(position),
      'stepText': serializer.toJson<String>(stepText),
      'suggestedSeconds': serializer.toJson<int?>(suggestedSeconds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LadderStepRow copyWith({
    String? id,
    String? taskId,
    int? position,
    String? stepText,
    Value<int?> suggestedSeconds = const Value.absent(),
    DateTime? updatedAt,
  }) => LadderStepRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    position: position ?? this.position,
    stepText: stepText ?? this.stepText,
    suggestedSeconds: suggestedSeconds.present
        ? suggestedSeconds.value
        : this.suggestedSeconds,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LadderStepRow copyWithCompanion(LadderStepsCompanion data) {
    return LadderStepRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      position: data.position.present ? data.position.value : this.position,
      stepText: data.stepText.present ? data.stepText.value : this.stepText,
      suggestedSeconds: data.suggestedSeconds.present
          ? data.suggestedSeconds.value
          : this.suggestedSeconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LadderStepRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('position: $position, ')
          ..write('stepText: $stepText, ')
          ..write('suggestedSeconds: $suggestedSeconds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskId, position, stepText, suggestedSeconds, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LadderStepRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.position == this.position &&
          other.stepText == this.stepText &&
          other.suggestedSeconds == this.suggestedSeconds &&
          other.updatedAt == this.updatedAt);
}

class LadderStepsCompanion extends UpdateCompanion<LadderStepRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<int> position;
  final Value<String> stepText;
  final Value<int?> suggestedSeconds;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LadderStepsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.position = const Value.absent(),
    this.stepText = const Value.absent(),
    this.suggestedSeconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LadderStepsCompanion.insert({
    required String id,
    required String taskId,
    required int position,
    required String stepText,
    this.suggestedSeconds = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       position = Value(position),
       stepText = Value(stepText),
       updatedAt = Value(updatedAt);
  static Insertable<LadderStepRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<int>? position,
    Expression<String>? stepText,
    Expression<int>? suggestedSeconds,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (position != null) 'position': position,
      if (stepText != null) 'step_text': stepText,
      if (suggestedSeconds != null) 'suggested_seconds': suggestedSeconds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LadderStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<int>? position,
    Value<String>? stepText,
    Value<int?>? suggestedSeconds,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LadderStepsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      position: position ?? this.position,
      stepText: stepText ?? this.stepText,
      suggestedSeconds: suggestedSeconds ?? this.suggestedSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (stepText.present) {
      map['step_text'] = Variable<String>(stepText.value);
    }
    if (suggestedSeconds.present) {
      map['suggested_seconds'] = Variable<int>(suggestedSeconds.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LadderStepsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('position: $position, ')
          ..write('stepText: $stepText, ')
          ..write('suggestedSeconds: $suggestedSeconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PresetsTable extends Presets with TableInfo<$PresetsTable, PresetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _approachSecondsMeta = const VerificationMeta(
    'approachSeconds',
  );
  @override
  late final GeneratedColumn<int> approachSeconds = GeneratedColumn<int>(
    'approach_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longRestSecondsMeta = const VerificationMeta(
    'longRestSeconds',
  );
  @override
  late final GeneratedColumn<int> longRestSeconds = GeneratedColumn<int>(
    'long_rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cyclesBeforeLongRestMeta =
      const VerificationMeta('cyclesBeforeLongRest');
  @override
  late final GeneratedColumn<int> cyclesBeforeLongRest = GeneratedColumn<int>(
    'cycles_before_long_rest',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _builtInMeta = const VerificationMeta(
    'builtIn',
  );
  @override
  late final GeneratedColumn<bool> builtIn = GeneratedColumn<bool>(
    'built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    approachSeconds,
    restSeconds,
    longRestSeconds,
    cyclesBeforeLongRest,
    sortOrder,
    builtIn,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PresetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('approach_seconds')) {
      context.handle(
        _approachSecondsMeta,
        approachSeconds.isAcceptableOrUnknown(
          data['approach_seconds']!,
          _approachSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_approachSecondsMeta);
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restSecondsMeta);
    }
    if (data.containsKey('long_rest_seconds')) {
      context.handle(
        _longRestSecondsMeta,
        longRestSeconds.isAcceptableOrUnknown(
          data['long_rest_seconds']!,
          _longRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('cycles_before_long_rest')) {
      context.handle(
        _cyclesBeforeLongRestMeta,
        cyclesBeforeLongRest.isAcceptableOrUnknown(
          data['cycles_before_long_rest']!,
          _cyclesBeforeLongRestMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('built_in')) {
      context.handle(
        _builtInMeta,
        builtIn.isAcceptableOrUnknown(data['built_in']!, _builtInMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PresetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PresetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      approachSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}approach_seconds'],
      )!,
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      )!,
      longRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}long_rest_seconds'],
      ),
      cyclesBeforeLongRest: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycles_before_long_rest'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      builtIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}built_in'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PresetsTable createAlias(String alias) {
    return $PresetsTable(attachedDatabase, alias);
  }
}

class PresetRow extends DataClass implements Insertable<PresetRow> {
  final String id;
  final String name;
  final int approachSeconds;
  final int restSeconds;
  final int? longRestSeconds;
  final int cyclesBeforeLongRest;
  final int sortOrder;
  final bool builtIn;
  final DateTime updatedAt;
  const PresetRow({
    required this.id,
    required this.name,
    required this.approachSeconds,
    required this.restSeconds,
    this.longRestSeconds,
    required this.cyclesBeforeLongRest,
    required this.sortOrder,
    required this.builtIn,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['approach_seconds'] = Variable<int>(approachSeconds);
    map['rest_seconds'] = Variable<int>(restSeconds);
    if (!nullToAbsent || longRestSeconds != null) {
      map['long_rest_seconds'] = Variable<int>(longRestSeconds);
    }
    map['cycles_before_long_rest'] = Variable<int>(cyclesBeforeLongRest);
    map['sort_order'] = Variable<int>(sortOrder);
    map['built_in'] = Variable<bool>(builtIn);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PresetsCompanion toCompanion(bool nullToAbsent) {
    return PresetsCompanion(
      id: Value(id),
      name: Value(name),
      approachSeconds: Value(approachSeconds),
      restSeconds: Value(restSeconds),
      longRestSeconds: longRestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(longRestSeconds),
      cyclesBeforeLongRest: Value(cyclesBeforeLongRest),
      sortOrder: Value(sortOrder),
      builtIn: Value(builtIn),
      updatedAt: Value(updatedAt),
    );
  }

  factory PresetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PresetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      approachSeconds: serializer.fromJson<int>(json['approachSeconds']),
      restSeconds: serializer.fromJson<int>(json['restSeconds']),
      longRestSeconds: serializer.fromJson<int?>(json['longRestSeconds']),
      cyclesBeforeLongRest: serializer.fromJson<int>(
        json['cyclesBeforeLongRest'],
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      builtIn: serializer.fromJson<bool>(json['builtIn']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'approachSeconds': serializer.toJson<int>(approachSeconds),
      'restSeconds': serializer.toJson<int>(restSeconds),
      'longRestSeconds': serializer.toJson<int?>(longRestSeconds),
      'cyclesBeforeLongRest': serializer.toJson<int>(cyclesBeforeLongRest),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'builtIn': serializer.toJson<bool>(builtIn),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PresetRow copyWith({
    String? id,
    String? name,
    int? approachSeconds,
    int? restSeconds,
    Value<int?> longRestSeconds = const Value.absent(),
    int? cyclesBeforeLongRest,
    int? sortOrder,
    bool? builtIn,
    DateTime? updatedAt,
  }) => PresetRow(
    id: id ?? this.id,
    name: name ?? this.name,
    approachSeconds: approachSeconds ?? this.approachSeconds,
    restSeconds: restSeconds ?? this.restSeconds,
    longRestSeconds: longRestSeconds.present
        ? longRestSeconds.value
        : this.longRestSeconds,
    cyclesBeforeLongRest: cyclesBeforeLongRest ?? this.cyclesBeforeLongRest,
    sortOrder: sortOrder ?? this.sortOrder,
    builtIn: builtIn ?? this.builtIn,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PresetRow copyWithCompanion(PresetsCompanion data) {
    return PresetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      approachSeconds: data.approachSeconds.present
          ? data.approachSeconds.value
          : this.approachSeconds,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      longRestSeconds: data.longRestSeconds.present
          ? data.longRestSeconds.value
          : this.longRestSeconds,
      cyclesBeforeLongRest: data.cyclesBeforeLongRest.present
          ? data.cyclesBeforeLongRest.value
          : this.cyclesBeforeLongRest,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      builtIn: data.builtIn.present ? data.builtIn.value : this.builtIn,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PresetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('approachSeconds: $approachSeconds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('longRestSeconds: $longRestSeconds, ')
          ..write('cyclesBeforeLongRest: $cyclesBeforeLongRest, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('builtIn: $builtIn, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    approachSeconds,
    restSeconds,
    longRestSeconds,
    cyclesBeforeLongRest,
    sortOrder,
    builtIn,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PresetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.approachSeconds == this.approachSeconds &&
          other.restSeconds == this.restSeconds &&
          other.longRestSeconds == this.longRestSeconds &&
          other.cyclesBeforeLongRest == this.cyclesBeforeLongRest &&
          other.sortOrder == this.sortOrder &&
          other.builtIn == this.builtIn &&
          other.updatedAt == this.updatedAt);
}

class PresetsCompanion extends UpdateCompanion<PresetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> approachSeconds;
  final Value<int> restSeconds;
  final Value<int?> longRestSeconds;
  final Value<int> cyclesBeforeLongRest;
  final Value<int> sortOrder;
  final Value<bool> builtIn;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.approachSeconds = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.longRestSeconds = const Value.absent(),
    this.cyclesBeforeLongRest = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PresetsCompanion.insert({
    required String id,
    required String name,
    required int approachSeconds,
    required int restSeconds,
    this.longRestSeconds = const Value.absent(),
    this.cyclesBeforeLongRest = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.builtIn = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       approachSeconds = Value(approachSeconds),
       restSeconds = Value(restSeconds),
       updatedAt = Value(updatedAt);
  static Insertable<PresetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? approachSeconds,
    Expression<int>? restSeconds,
    Expression<int>? longRestSeconds,
    Expression<int>? cyclesBeforeLongRest,
    Expression<int>? sortOrder,
    Expression<bool>? builtIn,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (approachSeconds != null) 'approach_seconds': approachSeconds,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (longRestSeconds != null) 'long_rest_seconds': longRestSeconds,
      if (cyclesBeforeLongRest != null)
        'cycles_before_long_rest': cyclesBeforeLongRest,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (builtIn != null) 'built_in': builtIn,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? approachSeconds,
    Value<int>? restSeconds,
    Value<int?>? longRestSeconds,
    Value<int>? cyclesBeforeLongRest,
    Value<int>? sortOrder,
    Value<bool>? builtIn,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      approachSeconds: approachSeconds ?? this.approachSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      longRestSeconds: longRestSeconds ?? this.longRestSeconds,
      cyclesBeforeLongRest: cyclesBeforeLongRest ?? this.cyclesBeforeLongRest,
      sortOrder: sortOrder ?? this.sortOrder,
      builtIn: builtIn ?? this.builtIn,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (approachSeconds.present) {
      map['approach_seconds'] = Variable<int>(approachSeconds.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (longRestSeconds.present) {
      map['long_rest_seconds'] = Variable<int>(longRestSeconds.value);
    }
    if (cyclesBeforeLongRest.present) {
      map['cycles_before_long_rest'] = Variable<int>(
        cyclesBeforeLongRest.value,
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (builtIn.present) {
      map['built_in'] = Variable<bool>(builtIn.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('approachSeconds: $approachSeconds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('longRestSeconds: $longRestSeconds, ')
          ..write('cyclesBeforeLongRest: $cyclesBeforeLongRest, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('builtIn: $builtIn, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskTitleMeta = const VerificationMeta(
    'taskTitle',
  );
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
    'task_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rungIdMeta = const VerificationMeta('rungId');
  @override
  late final GeneratedColumn<String> rungId = GeneratedColumn<String>(
    'rung_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rungPositionMeta = const VerificationMeta(
    'rungPosition',
  );
  @override
  late final GeneratedColumn<int> rungPosition = GeneratedColumn<int>(
    'rung_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rungTextMeta = const VerificationMeta(
    'rungText',
  );
  @override
  late final GeneratedColumn<String> rungText = GeneratedColumn<String>(
    'rung_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedSecondsMeta = const VerificationMeta(
    'plannedSeconds',
  );
  @override
  late final GeneratedColumn<int> plannedSeconds = GeneratedColumn<int>(
    'planned_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualSecondsMeta = const VerificationMeta(
    'actualSeconds',
  );
  @override
  late final GeneratedColumn<int> actualSeconds = GeneratedColumn<int>(
    'actual_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snoozeCountMeta = const VerificationMeta(
    'snoozeCount',
  );
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
    'snooze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodBeforeMeta = const VerificationMeta(
    'moodBefore',
  );
  @override
  late final GeneratedColumn<String> moodBefore = GeneratedColumn<String>(
    'mood_before',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodAfterMeta = const VerificationMeta(
    'moodAfter',
  );
  @override
  late final GeneratedColumn<String> moodAfter = GeneratedColumn<String>(
    'mood_after',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _xpBonusesMeta = const VerificationMeta(
    'xpBonuses',
  );
  @override
  late final GeneratedColumn<String> xpBonuses = GeneratedColumn<String>(
    'xp_bonuses',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    taskId,
    taskTitle,
    rungId,
    rungPosition,
    rungText,
    phase,
    plannedSeconds,
    actualSeconds,
    outcome,
    snoozeCount,
    startedAt,
    endedAt,
    moodBefore,
    moodAfter,
    xpEarned,
    xpBonuses,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('task_title')) {
      context.handle(
        _taskTitleMeta,
        taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta),
      );
    }
    if (data.containsKey('rung_id')) {
      context.handle(
        _rungIdMeta,
        rungId.isAcceptableOrUnknown(data['rung_id']!, _rungIdMeta),
      );
    }
    if (data.containsKey('rung_position')) {
      context.handle(
        _rungPositionMeta,
        rungPosition.isAcceptableOrUnknown(
          data['rung_position']!,
          _rungPositionMeta,
        ),
      );
    }
    if (data.containsKey('rung_text')) {
      context.handle(
        _rungTextMeta,
        rungText.isAcceptableOrUnknown(data['rung_text']!, _rungTextMeta),
      );
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('planned_seconds')) {
      context.handle(
        _plannedSecondsMeta,
        plannedSeconds.isAcceptableOrUnknown(
          data['planned_seconds']!,
          _plannedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedSecondsMeta);
    }
    if (data.containsKey('actual_seconds')) {
      context.handle(
        _actualSecondsMeta,
        actualSeconds.isAcceptableOrUnknown(
          data['actual_seconds']!,
          _actualSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualSecondsMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
        _snoozeCountMeta,
        snoozeCount.isAcceptableOrUnknown(
          data['snooze_count']!,
          _snoozeCountMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('mood_before')) {
      context.handle(
        _moodBeforeMeta,
        moodBefore.isAcceptableOrUnknown(data['mood_before']!, _moodBeforeMeta),
      );
    }
    if (data.containsKey('mood_after')) {
      context.handle(
        _moodAfterMeta,
        moodAfter.isAcceptableOrUnknown(data['mood_after']!, _moodAfterMeta),
      );
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    }
    if (data.containsKey('xp_bonuses')) {
      context.handle(
        _xpBonusesMeta,
        xpBonuses.isAcceptableOrUnknown(data['xp_bonuses']!, _xpBonusesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      taskTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_title'],
      ),
      rungId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rung_id'],
      ),
      rungPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rung_position'],
      ),
      rungText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rung_text'],
      ),
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      plannedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_seconds'],
      )!,
      actualSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_seconds'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      snoozeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_count'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      moodBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_before'],
      ),
      moodAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_after'],
      ),
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
      xpBonuses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}xp_bonuses'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String runId;
  final String? taskId;
  final String? taskTitle;
  final String? rungId;
  final int? rungPosition;
  final String? rungText;
  final String phase;
  final int plannedSeconds;
  final int actualSeconds;
  final String outcome;
  final int snoozeCount;
  final DateTime startedAt;
  final DateTime endedAt;
  final String? moodBefore;
  final String? moodAfter;
  final int xpEarned;
  final String xpBonuses;
  final DateTime updatedAt;
  const SessionRow({
    required this.id,
    required this.runId,
    this.taskId,
    this.taskTitle,
    this.rungId,
    this.rungPosition,
    this.rungText,
    required this.phase,
    required this.plannedSeconds,
    required this.actualSeconds,
    required this.outcome,
    required this.snoozeCount,
    required this.startedAt,
    required this.endedAt,
    this.moodBefore,
    this.moodAfter,
    required this.xpEarned,
    required this.xpBonuses,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['run_id'] = Variable<String>(runId);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    if (!nullToAbsent || taskTitle != null) {
      map['task_title'] = Variable<String>(taskTitle);
    }
    if (!nullToAbsent || rungId != null) {
      map['rung_id'] = Variable<String>(rungId);
    }
    if (!nullToAbsent || rungPosition != null) {
      map['rung_position'] = Variable<int>(rungPosition);
    }
    if (!nullToAbsent || rungText != null) {
      map['rung_text'] = Variable<String>(rungText);
    }
    map['phase'] = Variable<String>(phase);
    map['planned_seconds'] = Variable<int>(plannedSeconds);
    map['actual_seconds'] = Variable<int>(actualSeconds);
    map['outcome'] = Variable<String>(outcome);
    map['snooze_count'] = Variable<int>(snoozeCount);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    if (!nullToAbsent || moodBefore != null) {
      map['mood_before'] = Variable<String>(moodBefore);
    }
    if (!nullToAbsent || moodAfter != null) {
      map['mood_after'] = Variable<String>(moodAfter);
    }
    map['xp_earned'] = Variable<int>(xpEarned);
    map['xp_bonuses'] = Variable<String>(xpBonuses);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      runId: Value(runId),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      taskTitle: taskTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(taskTitle),
      rungId: rungId == null && nullToAbsent
          ? const Value.absent()
          : Value(rungId),
      rungPosition: rungPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(rungPosition),
      rungText: rungText == null && nullToAbsent
          ? const Value.absent()
          : Value(rungText),
      phase: Value(phase),
      plannedSeconds: Value(plannedSeconds),
      actualSeconds: Value(actualSeconds),
      outcome: Value(outcome),
      snoozeCount: Value(snoozeCount),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      moodBefore: moodBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(moodBefore),
      moodAfter: moodAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(moodAfter),
      xpEarned: Value(xpEarned),
      xpBonuses: Value(xpBonuses),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      runId: serializer.fromJson<String>(json['runId']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      taskTitle: serializer.fromJson<String?>(json['taskTitle']),
      rungId: serializer.fromJson<String?>(json['rungId']),
      rungPosition: serializer.fromJson<int?>(json['rungPosition']),
      rungText: serializer.fromJson<String?>(json['rungText']),
      phase: serializer.fromJson<String>(json['phase']),
      plannedSeconds: serializer.fromJson<int>(json['plannedSeconds']),
      actualSeconds: serializer.fromJson<int>(json['actualSeconds']),
      outcome: serializer.fromJson<String>(json['outcome']),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      moodBefore: serializer.fromJson<String?>(json['moodBefore']),
      moodAfter: serializer.fromJson<String?>(json['moodAfter']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      xpBonuses: serializer.fromJson<String>(json['xpBonuses']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'runId': serializer.toJson<String>(runId),
      'taskId': serializer.toJson<String?>(taskId),
      'taskTitle': serializer.toJson<String?>(taskTitle),
      'rungId': serializer.toJson<String?>(rungId),
      'rungPosition': serializer.toJson<int?>(rungPosition),
      'rungText': serializer.toJson<String?>(rungText),
      'phase': serializer.toJson<String>(phase),
      'plannedSeconds': serializer.toJson<int>(plannedSeconds),
      'actualSeconds': serializer.toJson<int>(actualSeconds),
      'outcome': serializer.toJson<String>(outcome),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'moodBefore': serializer.toJson<String?>(moodBefore),
      'moodAfter': serializer.toJson<String?>(moodAfter),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'xpBonuses': serializer.toJson<String>(xpBonuses),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionRow copyWith({
    String? id,
    String? runId,
    Value<String?> taskId = const Value.absent(),
    Value<String?> taskTitle = const Value.absent(),
    Value<String?> rungId = const Value.absent(),
    Value<int?> rungPosition = const Value.absent(),
    Value<String?> rungText = const Value.absent(),
    String? phase,
    int? plannedSeconds,
    int? actualSeconds,
    String? outcome,
    int? snoozeCount,
    DateTime? startedAt,
    DateTime? endedAt,
    Value<String?> moodBefore = const Value.absent(),
    Value<String?> moodAfter = const Value.absent(),
    int? xpEarned,
    String? xpBonuses,
    DateTime? updatedAt,
  }) => SessionRow(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    taskId: taskId.present ? taskId.value : this.taskId,
    taskTitle: taskTitle.present ? taskTitle.value : this.taskTitle,
    rungId: rungId.present ? rungId.value : this.rungId,
    rungPosition: rungPosition.present ? rungPosition.value : this.rungPosition,
    rungText: rungText.present ? rungText.value : this.rungText,
    phase: phase ?? this.phase,
    plannedSeconds: plannedSeconds ?? this.plannedSeconds,
    actualSeconds: actualSeconds ?? this.actualSeconds,
    outcome: outcome ?? this.outcome,
    snoozeCount: snoozeCount ?? this.snoozeCount,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    moodBefore: moodBefore.present ? moodBefore.value : this.moodBefore,
    moodAfter: moodAfter.present ? moodAfter.value : this.moodAfter,
    xpEarned: xpEarned ?? this.xpEarned,
    xpBonuses: xpBonuses ?? this.xpBonuses,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      rungId: data.rungId.present ? data.rungId.value : this.rungId,
      rungPosition: data.rungPosition.present
          ? data.rungPosition.value
          : this.rungPosition,
      rungText: data.rungText.present ? data.rungText.value : this.rungText,
      phase: data.phase.present ? data.phase.value : this.phase,
      plannedSeconds: data.plannedSeconds.present
          ? data.plannedSeconds.value
          : this.plannedSeconds,
      actualSeconds: data.actualSeconds.present
          ? data.actualSeconds.value
          : this.actualSeconds,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      snoozeCount: data.snoozeCount.present
          ? data.snoozeCount.value
          : this.snoozeCount,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      moodBefore: data.moodBefore.present
          ? data.moodBefore.value
          : this.moodBefore,
      moodAfter: data.moodAfter.present ? data.moodAfter.value : this.moodAfter,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      xpBonuses: data.xpBonuses.present ? data.xpBonuses.value : this.xpBonuses,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('rungId: $rungId, ')
          ..write('rungPosition: $rungPosition, ')
          ..write('rungText: $rungText, ')
          ..write('phase: $phase, ')
          ..write('plannedSeconds: $plannedSeconds, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('outcome: $outcome, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('moodBefore: $moodBefore, ')
          ..write('moodAfter: $moodAfter, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('xpBonuses: $xpBonuses, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runId,
    taskId,
    taskTitle,
    rungId,
    rungPosition,
    rungText,
    phase,
    plannedSeconds,
    actualSeconds,
    outcome,
    snoozeCount,
    startedAt,
    endedAt,
    moodBefore,
    moodAfter,
    xpEarned,
    xpBonuses,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.taskId == this.taskId &&
          other.taskTitle == this.taskTitle &&
          other.rungId == this.rungId &&
          other.rungPosition == this.rungPosition &&
          other.rungText == this.rungText &&
          other.phase == this.phase &&
          other.plannedSeconds == this.plannedSeconds &&
          other.actualSeconds == this.actualSeconds &&
          other.outcome == this.outcome &&
          other.snoozeCount == this.snoozeCount &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.moodBefore == this.moodBefore &&
          other.moodAfter == this.moodAfter &&
          other.xpEarned == this.xpEarned &&
          other.xpBonuses == this.xpBonuses &&
          other.updatedAt == this.updatedAt);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> runId;
  final Value<String?> taskId;
  final Value<String?> taskTitle;
  final Value<String?> rungId;
  final Value<int?> rungPosition;
  final Value<String?> rungText;
  final Value<String> phase;
  final Value<int> plannedSeconds;
  final Value<int> actualSeconds;
  final Value<String> outcome;
  final Value<int> snoozeCount;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<String?> moodBefore;
  final Value<String?> moodAfter;
  final Value<int> xpEarned;
  final Value<String> xpBonuses;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.rungId = const Value.absent(),
    this.rungPosition = const Value.absent(),
    this.rungText = const Value.absent(),
    this.phase = const Value.absent(),
    this.plannedSeconds = const Value.absent(),
    this.actualSeconds = const Value.absent(),
    this.outcome = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.moodBefore = const Value.absent(),
    this.moodAfter = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.xpBonuses = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String runId,
    this.taskId = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.rungId = const Value.absent(),
    this.rungPosition = const Value.absent(),
    this.rungText = const Value.absent(),
    required String phase,
    required int plannedSeconds,
    required int actualSeconds,
    required String outcome,
    this.snoozeCount = const Value.absent(),
    required DateTime startedAt,
    required DateTime endedAt,
    this.moodBefore = const Value.absent(),
    this.moodAfter = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.xpBonuses = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       runId = Value(runId),
       phase = Value(phase),
       plannedSeconds = Value(plannedSeconds),
       actualSeconds = Value(actualSeconds),
       outcome = Value(outcome),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       updatedAt = Value(updatedAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? runId,
    Expression<String>? taskId,
    Expression<String>? taskTitle,
    Expression<String>? rungId,
    Expression<int>? rungPosition,
    Expression<String>? rungText,
    Expression<String>? phase,
    Expression<int>? plannedSeconds,
    Expression<int>? actualSeconds,
    Expression<String>? outcome,
    Expression<int>? snoozeCount,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? moodBefore,
    Expression<String>? moodAfter,
    Expression<int>? xpEarned,
    Expression<String>? xpBonuses,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (taskId != null) 'task_id': taskId,
      if (taskTitle != null) 'task_title': taskTitle,
      if (rungId != null) 'rung_id': rungId,
      if (rungPosition != null) 'rung_position': rungPosition,
      if (rungText != null) 'rung_text': rungText,
      if (phase != null) 'phase': phase,
      if (plannedSeconds != null) 'planned_seconds': plannedSeconds,
      if (actualSeconds != null) 'actual_seconds': actualSeconds,
      if (outcome != null) 'outcome': outcome,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (moodBefore != null) 'mood_before': moodBefore,
      if (moodAfter != null) 'mood_after': moodAfter,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (xpBonuses != null) 'xp_bonuses': xpBonuses,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? runId,
    Value<String?>? taskId,
    Value<String?>? taskTitle,
    Value<String?>? rungId,
    Value<int?>? rungPosition,
    Value<String?>? rungText,
    Value<String>? phase,
    Value<int>? plannedSeconds,
    Value<int>? actualSeconds,
    Value<String>? outcome,
    Value<int>? snoozeCount,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<String?>? moodBefore,
    Value<String?>? moodAfter,
    Value<int>? xpEarned,
    Value<String>? xpBonuses,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      rungId: rungId ?? this.rungId,
      rungPosition: rungPosition ?? this.rungPosition,
      rungText: rungText ?? this.rungText,
      phase: phase ?? this.phase,
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      actualSeconds: actualSeconds ?? this.actualSeconds,
      outcome: outcome ?? this.outcome,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      xpEarned: xpEarned ?? this.xpEarned,
      xpBonuses: xpBonuses ?? this.xpBonuses,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (rungId.present) {
      map['rung_id'] = Variable<String>(rungId.value);
    }
    if (rungPosition.present) {
      map['rung_position'] = Variable<int>(rungPosition.value);
    }
    if (rungText.present) {
      map['rung_text'] = Variable<String>(rungText.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (plannedSeconds.present) {
      map['planned_seconds'] = Variable<int>(plannedSeconds.value);
    }
    if (actualSeconds.present) {
      map['actual_seconds'] = Variable<int>(actualSeconds.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (moodBefore.present) {
      map['mood_before'] = Variable<String>(moodBefore.value);
    }
    if (moodAfter.present) {
      map['mood_after'] = Variable<String>(moodAfter.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (xpBonuses.present) {
      map['xp_bonuses'] = Variable<String>(xpBonuses.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('rungId: $rungId, ')
          ..write('rungPosition: $rungPosition, ')
          ..write('rungText: $rungText, ')
          ..write('phase: $phase, ')
          ..write('plannedSeconds: $plannedSeconds, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('outcome: $outcome, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('moodBefore: $moodBefore, ')
          ..write('moodAfter: $moodAfter, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('xpBonuses: $xpBonuses, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgressTable extends Progress
    with TableInfo<$ProgressTable, ProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _consistencyMeta = const VerificationMeta(
    'consistency',
  );
  @override
  late final GeneratedColumn<double> consistency = GeneratedColumn<double>(
    'consistency',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _lastActiveDayMeta = const VerificationMeta(
    'lastActiveDay',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveDay =
      GeneratedColumn<DateTime>(
        'last_active_day',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalCompletedIntervalsMeta =
      const VerificationMeta('totalCompletedIntervals');
  @override
  late final GeneratedColumn<int> totalCompletedIntervals =
      GeneratedColumn<int>(
        'total_completed_intervals',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    totalXp,
    consistency,
    lastActiveDay,
    totalCompletedIntervals,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('consistency')) {
      context.handle(
        _consistencyMeta,
        consistency.isAcceptableOrUnknown(
          data['consistency']!,
          _consistencyMeta,
        ),
      );
    }
    if (data.containsKey('last_active_day')) {
      context.handle(
        _lastActiveDayMeta,
        lastActiveDay.isAcceptableOrUnknown(
          data['last_active_day']!,
          _lastActiveDayMeta,
        ),
      );
    }
    if (data.containsKey('total_completed_intervals')) {
      context.handle(
        _totalCompletedIntervalsMeta,
        totalCompletedIntervals.isAcceptableOrUnknown(
          data['total_completed_intervals']!,
          _totalCompletedIntervalsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      consistency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consistency'],
      )!,
      lastActiveDay: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_day'],
      ),
      totalCompletedIntervals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_completed_intervals'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProgressTable createAlias(String alias) {
    return $ProgressTable(attachedDatabase, alias);
  }
}

class ProgressRow extends DataClass implements Insertable<ProgressRow> {
  final int id;
  final int totalXp;
  final double consistency;
  final DateTime? lastActiveDay;
  final int totalCompletedIntervals;
  final DateTime updatedAt;
  const ProgressRow({
    required this.id,
    required this.totalXp,
    required this.consistency,
    this.lastActiveDay,
    required this.totalCompletedIntervals,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['total_xp'] = Variable<int>(totalXp);
    map['consistency'] = Variable<double>(consistency);
    if (!nullToAbsent || lastActiveDay != null) {
      map['last_active_day'] = Variable<DateTime>(lastActiveDay);
    }
    map['total_completed_intervals'] = Variable<int>(totalCompletedIntervals);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProgressCompanion toCompanion(bool nullToAbsent) {
    return ProgressCompanion(
      id: Value(id),
      totalXp: Value(totalXp),
      consistency: Value(consistency),
      lastActiveDay: lastActiveDay == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveDay),
      totalCompletedIntervals: Value(totalCompletedIntervals),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressRow(
      id: serializer.fromJson<int>(json['id']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      consistency: serializer.fromJson<double>(json['consistency']),
      lastActiveDay: serializer.fromJson<DateTime?>(json['lastActiveDay']),
      totalCompletedIntervals: serializer.fromJson<int>(
        json['totalCompletedIntervals'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'totalXp': serializer.toJson<int>(totalXp),
      'consistency': serializer.toJson<double>(consistency),
      'lastActiveDay': serializer.toJson<DateTime?>(lastActiveDay),
      'totalCompletedIntervals': serializer.toJson<int>(
        totalCompletedIntervals,
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProgressRow copyWith({
    int? id,
    int? totalXp,
    double? consistency,
    Value<DateTime?> lastActiveDay = const Value.absent(),
    int? totalCompletedIntervals,
    DateTime? updatedAt,
  }) => ProgressRow(
    id: id ?? this.id,
    totalXp: totalXp ?? this.totalXp,
    consistency: consistency ?? this.consistency,
    lastActiveDay: lastActiveDay.present
        ? lastActiveDay.value
        : this.lastActiveDay,
    totalCompletedIntervals:
        totalCompletedIntervals ?? this.totalCompletedIntervals,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProgressRow copyWithCompanion(ProgressCompanion data) {
    return ProgressRow(
      id: data.id.present ? data.id.value : this.id,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      consistency: data.consistency.present
          ? data.consistency.value
          : this.consistency,
      lastActiveDay: data.lastActiveDay.present
          ? data.lastActiveDay.value
          : this.lastActiveDay,
      totalCompletedIntervals: data.totalCompletedIntervals.present
          ? data.totalCompletedIntervals.value
          : this.totalCompletedIntervals,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressRow(')
          ..write('id: $id, ')
          ..write('totalXp: $totalXp, ')
          ..write('consistency: $consistency, ')
          ..write('lastActiveDay: $lastActiveDay, ')
          ..write('totalCompletedIntervals: $totalCompletedIntervals, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    totalXp,
    consistency,
    lastActiveDay,
    totalCompletedIntervals,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressRow &&
          other.id == this.id &&
          other.totalXp == this.totalXp &&
          other.consistency == this.consistency &&
          other.lastActiveDay == this.lastActiveDay &&
          other.totalCompletedIntervals == this.totalCompletedIntervals &&
          other.updatedAt == this.updatedAt);
}

class ProgressCompanion extends UpdateCompanion<ProgressRow> {
  final Value<int> id;
  final Value<int> totalXp;
  final Value<double> consistency;
  final Value<DateTime?> lastActiveDay;
  final Value<int> totalCompletedIntervals;
  final Value<DateTime> updatedAt;
  const ProgressCompanion({
    this.id = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.consistency = const Value.absent(),
    this.lastActiveDay = const Value.absent(),
    this.totalCompletedIntervals = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProgressCompanion.insert({
    this.id = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.consistency = const Value.absent(),
    this.lastActiveDay = const Value.absent(),
    this.totalCompletedIntervals = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<ProgressRow> custom({
    Expression<int>? id,
    Expression<int>? totalXp,
    Expression<double>? consistency,
    Expression<DateTime>? lastActiveDay,
    Expression<int>? totalCompletedIntervals,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (totalXp != null) 'total_xp': totalXp,
      if (consistency != null) 'consistency': consistency,
      if (lastActiveDay != null) 'last_active_day': lastActiveDay,
      if (totalCompletedIntervals != null)
        'total_completed_intervals': totalCompletedIntervals,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? totalXp,
    Value<double>? consistency,
    Value<DateTime?>? lastActiveDay,
    Value<int>? totalCompletedIntervals,
    Value<DateTime>? updatedAt,
  }) {
    return ProgressCompanion(
      id: id ?? this.id,
      totalXp: totalXp ?? this.totalXp,
      consistency: consistency ?? this.consistency,
      lastActiveDay: lastActiveDay ?? this.lastActiveDay,
      totalCompletedIntervals:
          totalCompletedIntervals ?? this.totalCompletedIntervals,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (consistency.present) {
      map['consistency'] = Variable<double>(consistency.value);
    }
    if (lastActiveDay.present) {
      map['last_active_day'] = Variable<DateTime>(lastActiveDay.value);
    }
    if (totalCompletedIntervals.present) {
      map['total_completed_intervals'] = Variable<int>(
        totalCompletedIntervals.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressCompanion(')
          ..write('id: $id, ')
          ..write('totalXp: $totalXp, ')
          ..write('consistency: $consistency, ')
          ..write('lastActiveDay: $lastActiveDay, ')
          ..write('totalCompletedIntervals: $totalCompletedIntervals, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $LadderStepsTable ladderSteps = $LadderStepsTable(this);
  late final $PresetsTable presets = $PresetsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ProgressTable progress = $ProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    ladderSteps,
    presets,
    sessions,
    progress,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ladder_steps', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String title,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> archived,
  Value<int> sortOrder,
  Value<int?> restUnitSeconds,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> archived,
  Value<int> sortOrder,
  Value<int?> restUnitSeconds,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskRow> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LadderStepsTable, List<LadderStepRow>>
  _ladderStepsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ladderSteps,
    aliasName: 'tasks__id__ladder_steps__task_id',
  );

  $$LadderStepsTableProcessedTableManager get ladderStepsRefs {
    final manager = $$LadderStepsTableTableManager(
      $_db,
      $_db.ladderSteps,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ladderStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restUnitSeconds => $composableBuilder(
    column: $table.restUnitSeconds,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ladderStepsRefs(
    Expression<bool> Function($$LadderStepsTableFilterComposer f) f,
  ) {
    final $$LadderStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ladderSteps,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LadderStepsTableFilterComposer(
            $db: $db,
            $table: $db.ladderSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restUnitSeconds => $composableBuilder(
    column: $table.restUnitSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get restUnitSeconds => $composableBuilder(
    column: $table.restUnitSeconds,
    builder: (column) => column,
  );

  Expression<T> ladderStepsRefs<T extends Object>(
    Expression<T> Function($$LadderStepsTableAnnotationComposer a) f,
  ) {
    final $$LadderStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ladderSteps,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LadderStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.ladderSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, $$TasksTableReferences),
          TaskRow,
          PrefetchHooks Function({bool ladderStepsRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> restUnitSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
                sortOrder: sortOrder,
                restUnitSeconds: restUnitSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> restUnitSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
                sortOrder: sortOrder,
                restUnitSeconds: restUnitSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskRow>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ladderStepsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ladderStepsRefs) db.ladderSteps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ladderStepsRefs)
                    await $_getPrefetchedData<
                      TaskRow,
                      $TasksTable,
                      LadderStepRow
                    >(
                      currentTable: table,
                      referencedTable: $$TasksTableReferences
                          ._ladderStepsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TasksTableReferences(db, table, p0).ladderStepsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, $$TasksTableReferences),
      TaskRow,
      PrefetchHooks Function({bool ladderStepsRefs})
    >;
typedef $$LadderStepsTableCreateCompanionBuilder =
    LadderStepsCompanion Function({
      required String id,
      required String taskId,
      required int position,
      required String stepText,
      Value<int?> suggestedSeconds,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LadderStepsTableUpdateCompanionBuilder =
    LadderStepsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<int> position,
      Value<String> stepText,
      Value<int?> suggestedSeconds,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LadderStepsTableReferences
    extends BaseReferences<_$AppDatabase, $LadderStepsTable, LadderStepRow> {
  $$LadderStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('ladder_steps__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LadderStepsTableFilterComposer
    extends Composer<_$AppDatabase, $LadderStepsTable> {
  $$LadderStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepText => $composableBuilder(
    column: $table.stepText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get suggestedSeconds => $composableBuilder(
    column: $table.suggestedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LadderStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $LadderStepsTable> {
  $$LadderStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepText => $composableBuilder(
    column: $table.stepText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get suggestedSeconds => $composableBuilder(
    column: $table.suggestedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LadderStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LadderStepsTable> {
  $$LadderStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get stepText =>
      $composableBuilder(column: $table.stepText, builder: (column) => column);

  GeneratedColumn<int> get suggestedSeconds => $composableBuilder(
    column: $table.suggestedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LadderStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LadderStepsTable,
          LadderStepRow,
          $$LadderStepsTableFilterComposer,
          $$LadderStepsTableOrderingComposer,
          $$LadderStepsTableAnnotationComposer,
          $$LadderStepsTableCreateCompanionBuilder,
          $$LadderStepsTableUpdateCompanionBuilder,
          (LadderStepRow, $$LadderStepsTableReferences),
          LadderStepRow,
          PrefetchHooks Function({bool taskId})
        > {
  $$LadderStepsTableTableManager(_$AppDatabase db, $LadderStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LadderStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LadderStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LadderStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> stepText = const Value.absent(),
                Value<int?> suggestedSeconds = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LadderStepsCompanion(
                id: id,
                taskId: taskId,
                position: position,
                stepText: stepText,
                suggestedSeconds: suggestedSeconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required int position,
                required String stepText,
                Value<int?> suggestedSeconds = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LadderStepsCompanion.insert(
                id: id,
                taskId: taskId,
                position: position,
                stepText: stepText,
                suggestedSeconds: suggestedSeconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LadderStepsTable, LadderStepRow>(table),
                  $$LadderStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$LadderStepsTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$LadderStepsTableReferences
                            ._taskIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LadderStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LadderStepsTable,
      LadderStepRow,
      $$LadderStepsTableFilterComposer,
      $$LadderStepsTableOrderingComposer,
      $$LadderStepsTableAnnotationComposer,
      $$LadderStepsTableCreateCompanionBuilder,
      $$LadderStepsTableUpdateCompanionBuilder,
      (LadderStepRow, $$LadderStepsTableReferences),
      LadderStepRow,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$PresetsTableCreateCompanionBuilder = PresetsCompanion Function({
  required String id,
  required String name,
  required int approachSeconds,
  required int restSeconds,
  Value<int?> longRestSeconds,
  Value<int> cyclesBeforeLongRest,
  Value<int> sortOrder,
  Value<bool> builtIn,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PresetsTableUpdateCompanionBuilder = PresetsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> approachSeconds,
  Value<int> restSeconds,
  Value<int?> longRestSeconds,
  Value<int> cyclesBeforeLongRest,
  Value<int> sortOrder,
  Value<bool> builtIn,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PresetsTableFilterComposer
    extends Composer<_$AppDatabase, $PresetsTable> {
  $$PresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get approachSeconds => $composableBuilder(
    column: $table.approachSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longRestSeconds => $composableBuilder(
    column: $table.longRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cyclesBeforeLongRest => $composableBuilder(
    column: $table.cyclesBeforeLongRest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $PresetsTable> {
  $$PresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get approachSeconds => $composableBuilder(
    column: $table.approachSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longRestSeconds => $composableBuilder(
    column: $table.longRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cyclesBeforeLongRest => $composableBuilder(
    column: $table.cyclesBeforeLongRest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PresetsTable> {
  $$PresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get approachSeconds => $composableBuilder(
    column: $table.approachSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longRestSeconds => $composableBuilder(
    column: $table.longRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cyclesBeforeLongRest => $composableBuilder(
    column: $table.cyclesBeforeLongRest,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PresetsTable,
          PresetRow,
          $$PresetsTableFilterComposer,
          $$PresetsTableOrderingComposer,
          $$PresetsTableAnnotationComposer,
          $$PresetsTableCreateCompanionBuilder,
          $$PresetsTableUpdateCompanionBuilder,
          (PresetRow, BaseReferences<_$AppDatabase, $PresetsTable, PresetRow>),
          PresetRow,
          PrefetchHooks Function()
        > {
  $$PresetsTableTableManager(_$AppDatabase db, $PresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> approachSeconds = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
                Value<int?> longRestSeconds = const Value.absent(),
                Value<int> cyclesBeforeLongRest = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PresetsCompanion(
                id: id,
                name: name,
                approachSeconds: approachSeconds,
                restSeconds: restSeconds,
                longRestSeconds: longRestSeconds,
                cyclesBeforeLongRest: cyclesBeforeLongRest,
                sortOrder: sortOrder,
                builtIn: builtIn,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int approachSeconds,
                required int restSeconds,
                Value<int?> longRestSeconds = const Value.absent(),
                Value<int> cyclesBeforeLongRest = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PresetsCompanion.insert(
                id: id,
                name: name,
                approachSeconds: approachSeconds,
                restSeconds: restSeconds,
                longRestSeconds: longRestSeconds,
                cyclesBeforeLongRest: cyclesBeforeLongRest,
                sortOrder: sortOrder,
                builtIn: builtIn,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PresetsTable, PresetRow>(table),
                  BaseReferences<_$AppDatabase, $PresetsTable, PresetRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PresetsTable,
      PresetRow,
      $$PresetsTableFilterComposer,
      $$PresetsTableOrderingComposer,
      $$PresetsTableAnnotationComposer,
      $$PresetsTableCreateCompanionBuilder,
      $$PresetsTableUpdateCompanionBuilder,
      (PresetRow, BaseReferences<_$AppDatabase, $PresetsTable, PresetRow>),
      PresetRow,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String runId,
  Value<String?> taskId,
  Value<String?> taskTitle,
  Value<String?> rungId,
  Value<int?> rungPosition,
  Value<String?> rungText,
  required String phase,
  required int plannedSeconds,
  required int actualSeconds,
  required String outcome,
  Value<int> snoozeCount,
  required DateTime startedAt,
  required DateTime endedAt,
  Value<String?> moodBefore,
  Value<String?> moodAfter,
  Value<int> xpEarned,
  Value<String> xpBonuses,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> runId,
  Value<String?> taskId,
  Value<String?> taskTitle,
  Value<String?> rungId,
  Value<int?> rungPosition,
  Value<String?> rungText,
  Value<String> phase,
  Value<int> plannedSeconds,
  Value<int> actualSeconds,
  Value<String> outcome,
  Value<int> snoozeCount,
  Value<DateTime> startedAt,
  Value<DateTime> endedAt,
  Value<String?> moodBefore,
  Value<String?> moodAfter,
  Value<int> xpEarned,
  Value<String> xpBonuses,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rungId => $composableBuilder(
    column: $table.rungId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rungPosition => $composableBuilder(
    column: $table.rungPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rungText => $composableBuilder(
    column: $table.rungText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedSeconds => $composableBuilder(
    column: $table.plannedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodBefore => $composableBuilder(
    column: $table.moodBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodAfter => $composableBuilder(
    column: $table.moodAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get xpBonuses => $composableBuilder(
    column: $table.xpBonuses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rungId => $composableBuilder(
    column: $table.rungId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rungPosition => $composableBuilder(
    column: $table.rungPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rungText => $composableBuilder(
    column: $table.rungText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedSeconds => $composableBuilder(
    column: $table.plannedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodBefore => $composableBuilder(
    column: $table.moodBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodAfter => $composableBuilder(
    column: $table.moodAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get xpBonuses => $composableBuilder(
    column: $table.xpBonuses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<String> get rungId =>
      $composableBuilder(column: $table.rungId, builder: (column) => column);

  GeneratedColumn<int> get rungPosition => $composableBuilder(
    column: $table.rungPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rungText =>
      $composableBuilder(column: $table.rungText, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<int> get plannedSeconds => $composableBuilder(
    column: $table.plannedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get moodBefore => $composableBuilder(
    column: $table.moodBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moodAfter =>
      $composableBuilder(column: $table.moodAfter, builder: (column) => column);

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  GeneratedColumn<String> get xpBonuses =>
      $composableBuilder(column: $table.xpBonuses, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (
            SessionRow,
            BaseReferences<_$AppDatabase, $SessionsTable, SessionRow>,
          ),
          SessionRow,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> runId = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<String?> taskTitle = const Value.absent(),
                Value<String?> rungId = const Value.absent(),
                Value<int?> rungPosition = const Value.absent(),
                Value<String?> rungText = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<int> plannedSeconds = const Value.absent(),
                Value<int> actualSeconds = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<String?> moodBefore = const Value.absent(),
                Value<String?> moodAfter = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<String> xpBonuses = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                runId: runId,
                taskId: taskId,
                taskTitle: taskTitle,
                rungId: rungId,
                rungPosition: rungPosition,
                rungText: rungText,
                phase: phase,
                plannedSeconds: plannedSeconds,
                actualSeconds: actualSeconds,
                outcome: outcome,
                snoozeCount: snoozeCount,
                startedAt: startedAt,
                endedAt: endedAt,
                moodBefore: moodBefore,
                moodAfter: moodAfter,
                xpEarned: xpEarned,
                xpBonuses: xpBonuses,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String runId,
                Value<String?> taskId = const Value.absent(),
                Value<String?> taskTitle = const Value.absent(),
                Value<String?> rungId = const Value.absent(),
                Value<int?> rungPosition = const Value.absent(),
                Value<String?> rungText = const Value.absent(),
                required String phase,
                required int plannedSeconds,
                required int actualSeconds,
                required String outcome,
                Value<int> snoozeCount = const Value.absent(),
                required DateTime startedAt,
                required DateTime endedAt,
                Value<String?> moodBefore = const Value.absent(),
                Value<String?> moodAfter = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<String> xpBonuses = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                runId: runId,
                taskId: taskId,
                taskTitle: taskTitle,
                rungId: rungId,
                rungPosition: rungPosition,
                rungText: rungText,
                phase: phase,
                plannedSeconds: plannedSeconds,
                actualSeconds: actualSeconds,
                outcome: outcome,
                snoozeCount: snoozeCount,
                startedAt: startedAt,
                endedAt: endedAt,
                moodBefore: moodBefore,
                moodAfter: moodAfter,
                xpEarned: xpEarned,
                xpBonuses: xpBonuses,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, SessionRow>(table),
                  BaseReferences<_$AppDatabase, $SessionsTable, SessionRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, BaseReferences<_$AppDatabase, $SessionsTable, SessionRow>),
      SessionRow,
      PrefetchHooks Function()
    >;
typedef $$ProgressTableCreateCompanionBuilder = ProgressCompanion Function({
  Value<int> id,
  Value<int> totalXp,
  Value<double> consistency,
  Value<DateTime?> lastActiveDay,
  Value<int> totalCompletedIntervals,
  required DateTime updatedAt,
});
typedef $$ProgressTableUpdateCompanionBuilder = ProgressCompanion Function({
  Value<int> id,
  Value<int> totalXp,
  Value<double> consistency,
  Value<DateTime?> lastActiveDay,
  Value<int> totalCompletedIntervals,
  Value<DateTime> updatedAt,
});

class $$ProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consistency => $composableBuilder(
    column: $table.consistency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveDay => $composableBuilder(
    column: $table.lastActiveDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCompletedIntervals => $composableBuilder(
    column: $table.totalCompletedIntervals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consistency => $composableBuilder(
    column: $table.consistency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveDay => $composableBuilder(
    column: $table.lastActiveDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCompletedIntervals => $composableBuilder(
    column: $table.totalCompletedIntervals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<double> get consistency => $composableBuilder(
    column: $table.consistency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActiveDay => $composableBuilder(
    column: $table.lastActiveDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCompletedIntervals => $composableBuilder(
    column: $table.totalCompletedIntervals,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressTable,
          ProgressRow,
          $$ProgressTableFilterComposer,
          $$ProgressTableOrderingComposer,
          $$ProgressTableAnnotationComposer,
          $$ProgressTableCreateCompanionBuilder,
          $$ProgressTableUpdateCompanionBuilder,
          (
            ProgressRow,
            BaseReferences<_$AppDatabase, $ProgressTable, ProgressRow>,
          ),
          ProgressRow,
          PrefetchHooks Function()
        > {
  $$ProgressTableTableManager(_$AppDatabase db, $ProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<double> consistency = const Value.absent(),
                Value<DateTime?> lastActiveDay = const Value.absent(),
                Value<int> totalCompletedIntervals = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProgressCompanion(
                id: id,
                totalXp: totalXp,
                consistency: consistency,
                lastActiveDay: lastActiveDay,
                totalCompletedIntervals: totalCompletedIntervals,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<double> consistency = const Value.absent(),
                Value<DateTime?> lastActiveDay = const Value.absent(),
                Value<int> totalCompletedIntervals = const Value.absent(),
                required DateTime updatedAt,
              }) => ProgressCompanion.insert(
                id: id,
                totalXp: totalXp,
                consistency: consistency,
                lastActiveDay: lastActiveDay,
                totalCompletedIntervals: totalCompletedIntervals,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProgressTable, ProgressRow>(table),
                  BaseReferences<_$AppDatabase, $ProgressTable, ProgressRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressTable,
      ProgressRow,
      $$ProgressTableFilterComposer,
      $$ProgressTableOrderingComposer,
      $$ProgressTableAnnotationComposer,
      $$ProgressTableCreateCompanionBuilder,
      $$ProgressTableUpdateCompanionBuilder,
      (ProgressRow, BaseReferences<_$AppDatabase, $ProgressTable, ProgressRow>),
      ProgressRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$LadderStepsTableTableManager get ladderSteps =>
      $$LadderStepsTableTableManager(_db, _db.ladderSteps);
  $$PresetsTableTableManager get presets =>
      $$PresetsTableTableManager(_db, _db.presets);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ProgressTableTableManager get progress =>
      $$ProgressTableTableManager(_db, _db.progress);
}
