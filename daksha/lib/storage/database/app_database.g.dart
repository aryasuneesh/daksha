// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LearnerProfileTable extends LearnerProfile
    with TableInfo<$LearnerProfileTable, LearnerProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearnerProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streakDaysMeta = const VerificationMeta(
    'streakDays',
  );
  @override
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
    'streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastActiveAtMeta = const VerificationMeta(
    'lastActiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveAt = GeneratedColumn<DateTime>(
    'last_active_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, streakDays, lastActiveAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learner_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearnerProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('streak_days')) {
      context.handle(
        _streakDaysMeta,
        streakDays.isAcceptableOrUnknown(data['streak_days']!, _streakDaysMeta),
      );
    }
    if (data.containsKey('last_active_at')) {
      context.handle(
        _lastActiveAtMeta,
        lastActiveAt.isAcceptableOrUnknown(
          data['last_active_at']!,
          _lastActiveAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearnerProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnerProfileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      streakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_days'],
      )!,
      lastActiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_at'],
      ),
    );
  }

  @override
  $LearnerProfileTable createAlias(String alias) {
    return $LearnerProfileTable(attachedDatabase, alias);
  }
}

class LearnerProfileData extends DataClass
    implements Insertable<LearnerProfileData> {
  final int id;
  final String name;
  final int streakDays;
  final DateTime? lastActiveAt;
  const LearnerProfileData({
    required this.id,
    required this.name,
    required this.streakDays,
    this.lastActiveAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['streak_days'] = Variable<int>(streakDays);
    if (!nullToAbsent || lastActiveAt != null) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt);
    }
    return map;
  }

  LearnerProfileCompanion toCompanion(bool nullToAbsent) {
    return LearnerProfileCompanion(
      id: Value(id),
      name: Value(name),
      streakDays: Value(streakDays),
      lastActiveAt: lastActiveAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveAt),
    );
  }

  factory LearnerProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnerProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      streakDays: serializer.fromJson<int>(json['streakDays']),
      lastActiveAt: serializer.fromJson<DateTime?>(json['lastActiveAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'streakDays': serializer.toJson<int>(streakDays),
      'lastActiveAt': serializer.toJson<DateTime?>(lastActiveAt),
    };
  }

  LearnerProfileData copyWith({
    int? id,
    String? name,
    int? streakDays,
    Value<DateTime?> lastActiveAt = const Value.absent(),
  }) => LearnerProfileData(
    id: id ?? this.id,
    name: name ?? this.name,
    streakDays: streakDays ?? this.streakDays,
    lastActiveAt: lastActiveAt.present ? lastActiveAt.value : this.lastActiveAt,
  );
  LearnerProfileData copyWithCompanion(LearnerProfileCompanion data) {
    return LearnerProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      streakDays: data.streakDays.present
          ? data.streakDays.value
          : this.streakDays,
      lastActiveAt: data.lastActiveAt.present
          ? data.lastActiveAt.value
          : this.lastActiveAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnerProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActiveAt: $lastActiveAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, streakDays, lastActiveAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnerProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.streakDays == this.streakDays &&
          other.lastActiveAt == this.lastActiveAt);
}

class LearnerProfileCompanion extends UpdateCompanion<LearnerProfileData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> streakDays;
  final Value<DateTime?> lastActiveAt;
  const LearnerProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
  });
  LearnerProfileCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.streakDays = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<LearnerProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? streakDays,
    Expression<DateTime>? lastActiveAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (streakDays != null) 'streak_days': streakDays,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
    });
  }

  LearnerProfileCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? streakDays,
    Value<DateTime?>? lastActiveAt,
  }) {
    return LearnerProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      streakDays: streakDays ?? this.streakDays,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearnerProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActiveAt: $lastActiveAt')
          ..write(')'))
        .toString();
  }
}

class $ProblemsTable extends Problems with TableInfo<$ProblemsTable, Problem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProblemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUriMeta = const VerificationMeta(
    'imageUri',
  );
  @override
  late final GeneratedColumn<String> imageUri = GeneratedColumn<String>(
    'image_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _solvedMeta = const VerificationMeta('solved');
  @override
  late final GeneratedColumn<bool> solved = GeneratedColumn<bool>(
    'solved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("solved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subject,
    topic,
    rawText,
    imageUri,
    capturedAt,
    solved,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'problems';
  @override
  VerificationContext validateIntegrity(
    Insertable<Problem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('image_uri')) {
      context.handle(
        _imageUriMeta,
        imageUri.isAcceptableOrUnknown(data['image_uri']!, _imageUriMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('solved')) {
      context.handle(
        _solvedMeta,
        solved.isAcceptableOrUnknown(data['solved']!, _solvedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Problem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Problem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      imageUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_uri'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      solved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}solved'],
      )!,
    );
  }

  @override
  $ProblemsTable createAlias(String alias) {
    return $ProblemsTable(attachedDatabase, alias);
  }
}

class Problem extends DataClass implements Insertable<Problem> {
  final String id;
  final String subject;
  final String topic;
  final String rawText;
  final String? imageUri;
  final DateTime capturedAt;
  final bool solved;
  const Problem({
    required this.id,
    required this.subject,
    required this.topic,
    required this.rawText,
    this.imageUri,
    required this.capturedAt,
    required this.solved,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject'] = Variable<String>(subject);
    map['topic'] = Variable<String>(topic);
    map['raw_text'] = Variable<String>(rawText);
    if (!nullToAbsent || imageUri != null) {
      map['image_uri'] = Variable<String>(imageUri);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['solved'] = Variable<bool>(solved);
    return map;
  }

  ProblemsCompanion toCompanion(bool nullToAbsent) {
    return ProblemsCompanion(
      id: Value(id),
      subject: Value(subject),
      topic: Value(topic),
      rawText: Value(rawText),
      imageUri: imageUri == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUri),
      capturedAt: Value(capturedAt),
      solved: Value(solved),
    );
  }

  factory Problem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Problem(
      id: serializer.fromJson<String>(json['id']),
      subject: serializer.fromJson<String>(json['subject']),
      topic: serializer.fromJson<String>(json['topic']),
      rawText: serializer.fromJson<String>(json['rawText']),
      imageUri: serializer.fromJson<String?>(json['imageUri']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      solved: serializer.fromJson<bool>(json['solved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subject': serializer.toJson<String>(subject),
      'topic': serializer.toJson<String>(topic),
      'rawText': serializer.toJson<String>(rawText),
      'imageUri': serializer.toJson<String?>(imageUri),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'solved': serializer.toJson<bool>(solved),
    };
  }

  Problem copyWith({
    String? id,
    String? subject,
    String? topic,
    String? rawText,
    Value<String?> imageUri = const Value.absent(),
    DateTime? capturedAt,
    bool? solved,
  }) => Problem(
    id: id ?? this.id,
    subject: subject ?? this.subject,
    topic: topic ?? this.topic,
    rawText: rawText ?? this.rawText,
    imageUri: imageUri.present ? imageUri.value : this.imageUri,
    capturedAt: capturedAt ?? this.capturedAt,
    solved: solved ?? this.solved,
  );
  Problem copyWithCompanion(ProblemsCompanion data) {
    return Problem(
      id: data.id.present ? data.id.value : this.id,
      subject: data.subject.present ? data.subject.value : this.subject,
      topic: data.topic.present ? data.topic.value : this.topic,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      imageUri: data.imageUri.present ? data.imageUri.value : this.imageUri,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      solved: data.solved.present ? data.solved.value : this.solved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Problem(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('rawText: $rawText, ')
          ..write('imageUri: $imageUri, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('solved: $solved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, subject, topic, rawText, imageUri, capturedAt, solved);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Problem &&
          other.id == this.id &&
          other.subject == this.subject &&
          other.topic == this.topic &&
          other.rawText == this.rawText &&
          other.imageUri == this.imageUri &&
          other.capturedAt == this.capturedAt &&
          other.solved == this.solved);
}

class ProblemsCompanion extends UpdateCompanion<Problem> {
  final Value<String> id;
  final Value<String> subject;
  final Value<String> topic;
  final Value<String> rawText;
  final Value<String?> imageUri;
  final Value<DateTime> capturedAt;
  final Value<bool> solved;
  final Value<int> rowid;
  const ProblemsCompanion({
    this.id = const Value.absent(),
    this.subject = const Value.absent(),
    this.topic = const Value.absent(),
    this.rawText = const Value.absent(),
    this.imageUri = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.solved = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProblemsCompanion.insert({
    required String id,
    required String subject,
    required String topic,
    required String rawText,
    this.imageUri = const Value.absent(),
    required DateTime capturedAt,
    this.solved = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subject = Value(subject),
       topic = Value(topic),
       rawText = Value(rawText),
       capturedAt = Value(capturedAt);
  static Insertable<Problem> custom({
    Expression<String>? id,
    Expression<String>? subject,
    Expression<String>? topic,
    Expression<String>? rawText,
    Expression<String>? imageUri,
    Expression<DateTime>? capturedAt,
    Expression<bool>? solved,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subject != null) 'subject': subject,
      if (topic != null) 'topic': topic,
      if (rawText != null) 'raw_text': rawText,
      if (imageUri != null) 'image_uri': imageUri,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (solved != null) 'solved': solved,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProblemsCompanion copyWith({
    Value<String>? id,
    Value<String>? subject,
    Value<String>? topic,
    Value<String>? rawText,
    Value<String?>? imageUri,
    Value<DateTime>? capturedAt,
    Value<bool>? solved,
    Value<int>? rowid,
  }) {
    return ProblemsCompanion(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      rawText: rawText ?? this.rawText,
      imageUri: imageUri ?? this.imageUri,
      capturedAt: capturedAt ?? this.capturedAt,
      solved: solved ?? this.solved,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (imageUri.present) {
      map['image_uri'] = Variable<String>(imageUri.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (solved.present) {
      map['solved'] = Variable<bool>(solved.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProblemsCompanion(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('rawText: $rawText, ')
          ..write('imageUri: $imageUri, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('solved: $solved, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationTurnsTable extends ConversationTurns
    with TableInfo<$ConversationTurnsTable, ConversationTurn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationTurnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _problemIdMeta = const VerificationMeta(
    'problemId',
  );
  @override
  late final GeneratedColumn<String> problemId = GeneratedColumn<String>(
    'problem_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    problemId,
    role,
    content,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_turns';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationTurn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('problem_id')) {
      context.handle(
        _problemIdMeta,
        problemId.isAcceptableOrUnknown(data['problem_id']!, _problemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_problemIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationTurn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationTurn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      problemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ConversationTurnsTable createAlias(String alias) {
    return $ConversationTurnsTable(attachedDatabase, alias);
  }
}

class ConversationTurn extends DataClass
    implements Insertable<ConversationTurn> {
  final String id;
  final String problemId;
  final String role;
  final String content;
  final DateTime createdAt;
  const ConversationTurn({
    required this.id,
    required this.problemId,
    required this.role,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['problem_id'] = Variable<String>(problemId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ConversationTurnsCompanion toCompanion(bool nullToAbsent) {
    return ConversationTurnsCompanion(
      id: Value(id),
      problemId: Value(problemId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory ConversationTurn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationTurn(
      id: serializer.fromJson<String>(json['id']),
      problemId: serializer.fromJson<String>(json['problemId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'problemId': serializer.toJson<String>(problemId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ConversationTurn copyWith({
    String? id,
    String? problemId,
    String? role,
    String? content,
    DateTime? createdAt,
  }) => ConversationTurn(
    id: id ?? this.id,
    problemId: problemId ?? this.problemId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  ConversationTurn copyWithCompanion(ConversationTurnsCompanion data) {
    return ConversationTurn(
      id: data.id.present ? data.id.value : this.id,
      problemId: data.problemId.present ? data.problemId.value : this.problemId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationTurn(')
          ..write('id: $id, ')
          ..write('problemId: $problemId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, problemId, role, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationTurn &&
          other.id == this.id &&
          other.problemId == this.problemId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class ConversationTurnsCompanion extends UpdateCompanion<ConversationTurn> {
  final Value<String> id;
  final Value<String> problemId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ConversationTurnsCompanion({
    this.id = const Value.absent(),
    this.problemId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationTurnsCompanion.insert({
    required String id,
    required String problemId,
    required String role,
    required String content,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       problemId = Value(problemId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ConversationTurn> custom({
    Expression<String>? id,
    Expression<String>? problemId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (problemId != null) 'problem_id': problemId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationTurnsCompanion copyWith({
    Value<String>? id,
    Value<String>? problemId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ConversationTurnsCompanion(
      id: id ?? this.id,
      problemId: problemId ?? this.problemId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (problemId.present) {
      map['problem_id'] = Variable<String>(problemId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationTurnsCompanion(')
          ..write('id: $id, ')
          ..write('problemId: $problemId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewCardsTable extends ReviewCards
    with TableInfo<$ReviewCardsTable, ReviewCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _problemIdMeta = const VerificationMeta(
    'problemId',
  );
  @override
  late final GeneratedColumn<String> problemId = GeneratedColumn<String>(
    'problem_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    problemId,
    easeFactor,
    interval,
    repetitions,
    nextReviewAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('problem_id')) {
      context.handle(
        _problemIdMeta,
        problemId.isAcceptableOrUnknown(data['problem_id']!, _problemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_problemIdMeta);
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      problemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem_id'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      )!,
    );
  }

  @override
  $ReviewCardsTable createAlias(String alias) {
    return $ReviewCardsTable(attachedDatabase, alias);
  }
}

class ReviewCard extends DataClass implements Insertable<ReviewCard> {
  final String id;
  final String problemId;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReviewAt;
  const ReviewCard({
    required this.id,
    required this.problemId,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReviewAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['problem_id'] = Variable<String>(problemId);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval'] = Variable<int>(interval);
    map['repetitions'] = Variable<int>(repetitions);
    map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    return map;
  }

  ReviewCardsCompanion toCompanion(bool nullToAbsent) {
    return ReviewCardsCompanion(
      id: Value(id),
      problemId: Value(problemId),
      easeFactor: Value(easeFactor),
      interval: Value(interval),
      repetitions: Value(repetitions),
      nextReviewAt: Value(nextReviewAt),
    );
  }

  factory ReviewCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewCard(
      id: serializer.fromJson<String>(json['id']),
      problemId: serializer.fromJson<String>(json['problemId']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      interval: serializer.fromJson<int>(json['interval']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      nextReviewAt: serializer.fromJson<DateTime>(json['nextReviewAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'problemId': serializer.toJson<String>(problemId),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'interval': serializer.toJson<int>(interval),
      'repetitions': serializer.toJson<int>(repetitions),
      'nextReviewAt': serializer.toJson<DateTime>(nextReviewAt),
    };
  }

  ReviewCard copyWith({
    String? id,
    String? problemId,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? nextReviewAt,
  }) => ReviewCard(
    id: id ?? this.id,
    problemId: problemId ?? this.problemId,
    easeFactor: easeFactor ?? this.easeFactor,
    interval: interval ?? this.interval,
    repetitions: repetitions ?? this.repetitions,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
  );
  ReviewCard copyWithCompanion(ReviewCardsCompanion data) {
    return ReviewCard(
      id: data.id.present ? data.id.value : this.id,
      problemId: data.problemId.present ? data.problemId.value : this.problemId,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      interval: data.interval.present ? data.interval.value : this.interval,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewCard(')
          ..write('id: $id, ')
          ..write('problemId: $problemId, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextReviewAt: $nextReviewAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    problemId,
    easeFactor,
    interval,
    repetitions,
    nextReviewAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewCard &&
          other.id == this.id &&
          other.problemId == this.problemId &&
          other.easeFactor == this.easeFactor &&
          other.interval == this.interval &&
          other.repetitions == this.repetitions &&
          other.nextReviewAt == this.nextReviewAt);
}

class ReviewCardsCompanion extends UpdateCompanion<ReviewCard> {
  final Value<String> id;
  final Value<String> problemId;
  final Value<double> easeFactor;
  final Value<int> interval;
  final Value<int> repetitions;
  final Value<DateTime> nextReviewAt;
  final Value<int> rowid;
  const ReviewCardsCompanion({
    this.id = const Value.absent(),
    this.problemId = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewCardsCompanion.insert({
    required String id,
    required String problemId,
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
    required DateTime nextReviewAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       problemId = Value(problemId),
       nextReviewAt = Value(nextReviewAt);
  static Insertable<ReviewCard> custom({
    Expression<String>? id,
    Expression<String>? problemId,
    Expression<double>? easeFactor,
    Expression<int>? interval,
    Expression<int>? repetitions,
    Expression<DateTime>? nextReviewAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (problemId != null) 'problem_id': problemId,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (interval != null) 'interval': interval,
      if (repetitions != null) 'repetitions': repetitions,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? problemId,
    Value<double>? easeFactor,
    Value<int>? interval,
    Value<int>? repetitions,
    Value<DateTime>? nextReviewAt,
    Value<int>? rowid,
  }) {
    return ReviewCardsCompanion(
      id: id ?? this.id,
      problemId: problemId ?? this.problemId,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (problemId.present) {
      map['problem_id'] = Variable<String>(problemId.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewCardsCompanion(')
          ..write('id: $id, ')
          ..write('problemId: $problemId, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParentAuthTable extends ParentAuth
    with TableInfo<$ParentAuthTable, ParentAuthData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParentAuthTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _failedCountMeta = const VerificationMeta(
    'failedCount',
  );
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
    'failed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lockoutUntilMeta = const VerificationMeta(
    'lockoutUntil',
  );
  @override
  late final GeneratedColumn<DateTime> lockoutUntil = GeneratedColumn<DateTime>(
    'lockout_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pinHash,
    salt,
    failedCount,
    lockoutUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parent_auth';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParentAuthData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('failed_count')) {
      context.handle(
        _failedCountMeta,
        failedCount.isAcceptableOrUnknown(
          data['failed_count']!,
          _failedCountMeta,
        ),
      );
    }
    if (data.containsKey('lockout_until')) {
      context.handle(
        _lockoutUntilMeta,
        lockoutUntil.isAcceptableOrUnknown(
          data['lockout_until']!,
          _lockoutUntilMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParentAuthData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParentAuthData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salt'],
      )!,
      failedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_count'],
      )!,
      lockoutUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lockout_until'],
      ),
    );
  }

  @override
  $ParentAuthTable createAlias(String alias) {
    return $ParentAuthTable(attachedDatabase, alias);
  }
}

class ParentAuthData extends DataClass implements Insertable<ParentAuthData> {
  final int id;
  final String pinHash;
  final String salt;
  final int failedCount;
  final DateTime? lockoutUntil;
  const ParentAuthData({
    required this.id,
    required this.pinHash,
    required this.salt,
    required this.failedCount,
    this.lockoutUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pin_hash'] = Variable<String>(pinHash);
    map['salt'] = Variable<String>(salt);
    map['failed_count'] = Variable<int>(failedCount);
    if (!nullToAbsent || lockoutUntil != null) {
      map['lockout_until'] = Variable<DateTime>(lockoutUntil);
    }
    return map;
  }

  ParentAuthCompanion toCompanion(bool nullToAbsent) {
    return ParentAuthCompanion(
      id: Value(id),
      pinHash: Value(pinHash),
      salt: Value(salt),
      failedCount: Value(failedCount),
      lockoutUntil: lockoutUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockoutUntil),
    );
  }

  factory ParentAuthData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParentAuthData(
      id: serializer.fromJson<int>(json['id']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      salt: serializer.fromJson<String>(json['salt']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
      lockoutUntil: serializer.fromJson<DateTime?>(json['lockoutUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pinHash': serializer.toJson<String>(pinHash),
      'salt': serializer.toJson<String>(salt),
      'failedCount': serializer.toJson<int>(failedCount),
      'lockoutUntil': serializer.toJson<DateTime?>(lockoutUntil),
    };
  }

  ParentAuthData copyWith({
    int? id,
    String? pinHash,
    String? salt,
    int? failedCount,
    Value<DateTime?> lockoutUntil = const Value.absent(),
  }) => ParentAuthData(
    id: id ?? this.id,
    pinHash: pinHash ?? this.pinHash,
    salt: salt ?? this.salt,
    failedCount: failedCount ?? this.failedCount,
    lockoutUntil: lockoutUntil.present ? lockoutUntil.value : this.lockoutUntil,
  );
  ParentAuthData copyWithCompanion(ParentAuthCompanion data) {
    return ParentAuthData(
      id: data.id.present ? data.id.value : this.id,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      salt: data.salt.present ? data.salt.value : this.salt,
      failedCount: data.failedCount.present
          ? data.failedCount.value
          : this.failedCount,
      lockoutUntil: data.lockoutUntil.present
          ? data.lockoutUntil.value
          : this.lockoutUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParentAuthData(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('salt: $salt, ')
          ..write('failedCount: $failedCount, ')
          ..write('lockoutUntil: $lockoutUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pinHash, salt, failedCount, lockoutUntil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParentAuthData &&
          other.id == this.id &&
          other.pinHash == this.pinHash &&
          other.salt == this.salt &&
          other.failedCount == this.failedCount &&
          other.lockoutUntil == this.lockoutUntil);
}

class ParentAuthCompanion extends UpdateCompanion<ParentAuthData> {
  final Value<int> id;
  final Value<String> pinHash;
  final Value<String> salt;
  final Value<int> failedCount;
  final Value<DateTime?> lockoutUntil;
  const ParentAuthCompanion({
    this.id = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.salt = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.lockoutUntil = const Value.absent(),
  });
  ParentAuthCompanion.insert({
    this.id = const Value.absent(),
    required String pinHash,
    required String salt,
    this.failedCount = const Value.absent(),
    this.lockoutUntil = const Value.absent(),
  }) : pinHash = Value(pinHash),
       salt = Value(salt);
  static Insertable<ParentAuthData> custom({
    Expression<int>? id,
    Expression<String>? pinHash,
    Expression<String>? salt,
    Expression<int>? failedCount,
    Expression<DateTime>? lockoutUntil,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pinHash != null) 'pin_hash': pinHash,
      if (salt != null) 'salt': salt,
      if (failedCount != null) 'failed_count': failedCount,
      if (lockoutUntil != null) 'lockout_until': lockoutUntil,
    });
  }

  ParentAuthCompanion copyWith({
    Value<int>? id,
    Value<String>? pinHash,
    Value<String>? salt,
    Value<int>? failedCount,
    Value<DateTime?>? lockoutUntil,
  }) {
    return ParentAuthCompanion(
      id: id ?? this.id,
      pinHash: pinHash ?? this.pinHash,
      salt: salt ?? this.salt,
      failedCount: failedCount ?? this.failedCount,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    if (lockoutUntil.present) {
      map['lockout_until'] = Variable<DateTime>(lockoutUntil.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParentAuthCompanion(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('salt: $salt, ')
          ..write('failedCount: $failedCount, ')
          ..write('lockoutUntil: $lockoutUntil')
          ..write(')'))
        .toString();
  }
}

class $ParentQaTable extends ParentQa
    with TableInfo<$ParentQaTable, ParentQaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParentQaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
    'plan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _askedAtMeta = const VerificationMeta(
    'askedAt',
  );
  @override
  late final GeneratedColumn<DateTime> askedAt = GeneratedColumn<DateTime>(
    'asked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, question, plan, answer, askedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parent_qa';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParentQaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('plan')) {
      context.handle(
        _planMeta,
        plan.isAcceptableOrUnknown(data['plan']!, _planMeta),
      );
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('asked_at')) {
      context.handle(
        _askedAtMeta,
        askedAt.isAcceptableOrUnknown(data['asked_at']!, _askedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_askedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParentQaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParentQaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question'],
      )!,
      plan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan'],
      ),
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      askedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}asked_at'],
      )!,
    );
  }

  @override
  $ParentQaTable createAlias(String alias) {
    return $ParentQaTable(attachedDatabase, alias);
  }
}

class ParentQaData extends DataClass implements Insertable<ParentQaData> {
  final String id;
  final String question;
  final String? plan;
  final String answer;
  final DateTime askedAt;
  const ParentQaData({
    required this.id,
    required this.question,
    this.plan,
    required this.answer,
    required this.askedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question'] = Variable<String>(question);
    if (!nullToAbsent || plan != null) {
      map['plan'] = Variable<String>(plan);
    }
    map['answer'] = Variable<String>(answer);
    map['asked_at'] = Variable<DateTime>(askedAt);
    return map;
  }

  ParentQaCompanion toCompanion(bool nullToAbsent) {
    return ParentQaCompanion(
      id: Value(id),
      question: Value(question),
      plan: plan == null && nullToAbsent ? const Value.absent() : Value(plan),
      answer: Value(answer),
      askedAt: Value(askedAt),
    );
  }

  factory ParentQaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParentQaData(
      id: serializer.fromJson<String>(json['id']),
      question: serializer.fromJson<String>(json['question']),
      plan: serializer.fromJson<String?>(json['plan']),
      answer: serializer.fromJson<String>(json['answer']),
      askedAt: serializer.fromJson<DateTime>(json['askedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'question': serializer.toJson<String>(question),
      'plan': serializer.toJson<String?>(plan),
      'answer': serializer.toJson<String>(answer),
      'askedAt': serializer.toJson<DateTime>(askedAt),
    };
  }

  ParentQaData copyWith({
    String? id,
    String? question,
    Value<String?> plan = const Value.absent(),
    String? answer,
    DateTime? askedAt,
  }) => ParentQaData(
    id: id ?? this.id,
    question: question ?? this.question,
    plan: plan.present ? plan.value : this.plan,
    answer: answer ?? this.answer,
    askedAt: askedAt ?? this.askedAt,
  );
  ParentQaData copyWithCompanion(ParentQaCompanion data) {
    return ParentQaData(
      id: data.id.present ? data.id.value : this.id,
      question: data.question.present ? data.question.value : this.question,
      plan: data.plan.present ? data.plan.value : this.plan,
      answer: data.answer.present ? data.answer.value : this.answer,
      askedAt: data.askedAt.present ? data.askedAt.value : this.askedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParentQaData(')
          ..write('id: $id, ')
          ..write('question: $question, ')
          ..write('plan: $plan, ')
          ..write('answer: $answer, ')
          ..write('askedAt: $askedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, question, plan, answer, askedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParentQaData &&
          other.id == this.id &&
          other.question == this.question &&
          other.plan == this.plan &&
          other.answer == this.answer &&
          other.askedAt == this.askedAt);
}

class ParentQaCompanion extends UpdateCompanion<ParentQaData> {
  final Value<String> id;
  final Value<String> question;
  final Value<String?> plan;
  final Value<String> answer;
  final Value<DateTime> askedAt;
  final Value<int> rowid;
  const ParentQaCompanion({
    this.id = const Value.absent(),
    this.question = const Value.absent(),
    this.plan = const Value.absent(),
    this.answer = const Value.absent(),
    this.askedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParentQaCompanion.insert({
    required String id,
    required String question,
    this.plan = const Value.absent(),
    required String answer,
    required DateTime askedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       question = Value(question),
       answer = Value(answer),
       askedAt = Value(askedAt);
  static Insertable<ParentQaData> custom({
    Expression<String>? id,
    Expression<String>? question,
    Expression<String>? plan,
    Expression<String>? answer,
    Expression<DateTime>? askedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (question != null) 'question': question,
      if (plan != null) 'plan': plan,
      if (answer != null) 'answer': answer,
      if (askedAt != null) 'asked_at': askedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParentQaCompanion copyWith({
    Value<String>? id,
    Value<String>? question,
    Value<String?>? plan,
    Value<String>? answer,
    Value<DateTime>? askedAt,
    Value<int>? rowid,
  }) {
    return ParentQaCompanion(
      id: id ?? this.id,
      question: question ?? this.question,
      plan: plan ?? this.plan,
      answer: answer ?? this.answer,
      askedAt: askedAt ?? this.askedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (askedAt.present) {
      map['asked_at'] = Variable<DateTime>(askedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParentQaCompanion(')
          ..write('id: $id, ')
          ..write('question: $question, ')
          ..write('plan: $plan, ')
          ..write('answer: $answer, ')
          ..write('askedAt: $askedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LearnerProfileTable learnerProfile = $LearnerProfileTable(this);
  late final $ProblemsTable problems = $ProblemsTable(this);
  late final $ConversationTurnsTable conversationTurns =
      $ConversationTurnsTable(this);
  late final $ReviewCardsTable reviewCards = $ReviewCardsTable(this);
  late final $ParentAuthTable parentAuth = $ParentAuthTable(this);
  late final $ParentQaTable parentQa = $ParentQaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    learnerProfile,
    problems,
    conversationTurns,
    reviewCards,
    parentAuth,
    parentQa,
  ];
}

typedef $$LearnerProfileTableCreateCompanionBuilder =
    LearnerProfileCompanion Function({
      Value<int> id,
      required String name,
      Value<int> streakDays,
      Value<DateTime?> lastActiveAt,
    });
typedef $$LearnerProfileTableUpdateCompanionBuilder =
    LearnerProfileCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> streakDays,
      Value<DateTime?> lastActiveAt,
    });

class $$LearnerProfileTableFilterComposer
    extends Composer<_$AppDatabase, $LearnerProfileTable> {
  $$LearnerProfileTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LearnerProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $LearnerProfileTable> {
  $$LearnerProfileTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LearnerProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearnerProfileTable> {
  $$LearnerProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => column,
  );
}

class $$LearnerProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearnerProfileTable,
          LearnerProfileData,
          $$LearnerProfileTableFilterComposer,
          $$LearnerProfileTableOrderingComposer,
          $$LearnerProfileTableAnnotationComposer,
          $$LearnerProfileTableCreateCompanionBuilder,
          $$LearnerProfileTableUpdateCompanionBuilder,
          (
            LearnerProfileData,
            BaseReferences<
              _$AppDatabase,
              $LearnerProfileTable,
              LearnerProfileData
            >,
          ),
          LearnerProfileData,
          PrefetchHooks Function()
        > {
  $$LearnerProfileTableTableManager(
    _$AppDatabase db,
    $LearnerProfileTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearnerProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearnerProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearnerProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<DateTime?> lastActiveAt = const Value.absent(),
              }) => LearnerProfileCompanion(
                id: id,
                name: name,
                streakDays: streakDays,
                lastActiveAt: lastActiveAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> streakDays = const Value.absent(),
                Value<DateTime?> lastActiveAt = const Value.absent(),
              }) => LearnerProfileCompanion.insert(
                id: id,
                name: name,
                streakDays: streakDays,
                lastActiveAt: lastActiveAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LearnerProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearnerProfileTable,
      LearnerProfileData,
      $$LearnerProfileTableFilterComposer,
      $$LearnerProfileTableOrderingComposer,
      $$LearnerProfileTableAnnotationComposer,
      $$LearnerProfileTableCreateCompanionBuilder,
      $$LearnerProfileTableUpdateCompanionBuilder,
      (
        LearnerProfileData,
        BaseReferences<_$AppDatabase, $LearnerProfileTable, LearnerProfileData>,
      ),
      LearnerProfileData,
      PrefetchHooks Function()
    >;
typedef $$ProblemsTableCreateCompanionBuilder =
    ProblemsCompanion Function({
      required String id,
      required String subject,
      required String topic,
      required String rawText,
      Value<String?> imageUri,
      required DateTime capturedAt,
      Value<bool> solved,
      Value<int> rowid,
    });
typedef $$ProblemsTableUpdateCompanionBuilder =
    ProblemsCompanion Function({
      Value<String> id,
      Value<String> subject,
      Value<String> topic,
      Value<String> rawText,
      Value<String?> imageUri,
      Value<DateTime> capturedAt,
      Value<bool> solved,
      Value<int> rowid,
    });

class $$ProblemsTableFilterComposer
    extends Composer<_$AppDatabase, $ProblemsTable> {
  $$ProblemsTableFilterComposer({
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

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUri => $composableBuilder(
    column: $table.imageUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get solved => $composableBuilder(
    column: $table.solved,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProblemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProblemsTable> {
  $$ProblemsTableOrderingComposer({
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

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUri => $composableBuilder(
    column: $table.imageUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get solved => $composableBuilder(
    column: $table.solved,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProblemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProblemsTable> {
  $$ProblemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get imageUri =>
      $composableBuilder(column: $table.imageUri, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get solved =>
      $composableBuilder(column: $table.solved, builder: (column) => column);
}

class $$ProblemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProblemsTable,
          Problem,
          $$ProblemsTableFilterComposer,
          $$ProblemsTableOrderingComposer,
          $$ProblemsTableAnnotationComposer,
          $$ProblemsTableCreateCompanionBuilder,
          $$ProblemsTableUpdateCompanionBuilder,
          (Problem, BaseReferences<_$AppDatabase, $ProblemsTable, Problem>),
          Problem,
          PrefetchHooks Function()
        > {
  $$ProblemsTableTableManager(_$AppDatabase db, $ProblemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProblemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProblemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProblemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<String?> imageUri = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<bool> solved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProblemsCompanion(
                id: id,
                subject: subject,
                topic: topic,
                rawText: rawText,
                imageUri: imageUri,
                capturedAt: capturedAt,
                solved: solved,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subject,
                required String topic,
                required String rawText,
                Value<String?> imageUri = const Value.absent(),
                required DateTime capturedAt,
                Value<bool> solved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProblemsCompanion.insert(
                id: id,
                subject: subject,
                topic: topic,
                rawText: rawText,
                imageUri: imageUri,
                capturedAt: capturedAt,
                solved: solved,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProblemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProblemsTable,
      Problem,
      $$ProblemsTableFilterComposer,
      $$ProblemsTableOrderingComposer,
      $$ProblemsTableAnnotationComposer,
      $$ProblemsTableCreateCompanionBuilder,
      $$ProblemsTableUpdateCompanionBuilder,
      (Problem, BaseReferences<_$AppDatabase, $ProblemsTable, Problem>),
      Problem,
      PrefetchHooks Function()
    >;
typedef $$ConversationTurnsTableCreateCompanionBuilder =
    ConversationTurnsCompanion Function({
      required String id,
      required String problemId,
      required String role,
      required String content,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ConversationTurnsTableUpdateCompanionBuilder =
    ConversationTurnsCompanion Function({
      Value<String> id,
      Value<String> problemId,
      Value<String> role,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ConversationTurnsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationTurnsTable> {
  $$ConversationTurnsTableFilterComposer({
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

  ColumnFilters<String> get problemId => $composableBuilder(
    column: $table.problemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationTurnsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationTurnsTable> {
  $$ConversationTurnsTableOrderingComposer({
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

  ColumnOrderings<String> get problemId => $composableBuilder(
    column: $table.problemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationTurnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationTurnsTable> {
  $$ConversationTurnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get problemId =>
      $composableBuilder(column: $table.problemId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ConversationTurnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationTurnsTable,
          ConversationTurn,
          $$ConversationTurnsTableFilterComposer,
          $$ConversationTurnsTableOrderingComposer,
          $$ConversationTurnsTableAnnotationComposer,
          $$ConversationTurnsTableCreateCompanionBuilder,
          $$ConversationTurnsTableUpdateCompanionBuilder,
          (
            ConversationTurn,
            BaseReferences<
              _$AppDatabase,
              $ConversationTurnsTable,
              ConversationTurn
            >,
          ),
          ConversationTurn,
          PrefetchHooks Function()
        > {
  $$ConversationTurnsTableTableManager(
    _$AppDatabase db,
    $ConversationTurnsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationTurnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationTurnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationTurnsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> problemId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationTurnsCompanion(
                id: id,
                problemId: problemId,
                role: role,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String problemId,
                required String role,
                required String content,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ConversationTurnsCompanion.insert(
                id: id,
                problemId: problemId,
                role: role,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationTurnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationTurnsTable,
      ConversationTurn,
      $$ConversationTurnsTableFilterComposer,
      $$ConversationTurnsTableOrderingComposer,
      $$ConversationTurnsTableAnnotationComposer,
      $$ConversationTurnsTableCreateCompanionBuilder,
      $$ConversationTurnsTableUpdateCompanionBuilder,
      (
        ConversationTurn,
        BaseReferences<
          _$AppDatabase,
          $ConversationTurnsTable,
          ConversationTurn
        >,
      ),
      ConversationTurn,
      PrefetchHooks Function()
    >;
typedef $$ReviewCardsTableCreateCompanionBuilder =
    ReviewCardsCompanion Function({
      required String id,
      required String problemId,
      Value<double> easeFactor,
      Value<int> interval,
      Value<int> repetitions,
      required DateTime nextReviewAt,
      Value<int> rowid,
    });
typedef $$ReviewCardsTableUpdateCompanionBuilder =
    ReviewCardsCompanion Function({
      Value<String> id,
      Value<String> problemId,
      Value<double> easeFactor,
      Value<int> interval,
      Value<int> repetitions,
      Value<DateTime> nextReviewAt,
      Value<int> rowid,
    });

class $$ReviewCardsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewCardsTable> {
  $$ReviewCardsTableFilterComposer({
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

  ColumnFilters<String> get problemId => $composableBuilder(
    column: $table.problemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewCardsTable> {
  $$ReviewCardsTableOrderingComposer({
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

  ColumnOrderings<String> get problemId => $composableBuilder(
    column: $table.problemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewCardsTable> {
  $$ReviewCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get problemId =>
      $composableBuilder(column: $table.problemId, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );
}

class $$ReviewCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewCardsTable,
          ReviewCard,
          $$ReviewCardsTableFilterComposer,
          $$ReviewCardsTableOrderingComposer,
          $$ReviewCardsTableAnnotationComposer,
          $$ReviewCardsTableCreateCompanionBuilder,
          $$ReviewCardsTableUpdateCompanionBuilder,
          (
            ReviewCard,
            BaseReferences<_$AppDatabase, $ReviewCardsTable, ReviewCard>,
          ),
          ReviewCard,
          PrefetchHooks Function()
        > {
  $$ReviewCardsTableTableManager(_$AppDatabase db, $ReviewCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> problemId = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<DateTime> nextReviewAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewCardsCompanion(
                id: id,
                problemId: problemId,
                easeFactor: easeFactor,
                interval: interval,
                repetitions: repetitions,
                nextReviewAt: nextReviewAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String problemId,
                Value<double> easeFactor = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                required DateTime nextReviewAt,
                Value<int> rowid = const Value.absent(),
              }) => ReviewCardsCompanion.insert(
                id: id,
                problemId: problemId,
                easeFactor: easeFactor,
                interval: interval,
                repetitions: repetitions,
                nextReviewAt: nextReviewAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewCardsTable,
      ReviewCard,
      $$ReviewCardsTableFilterComposer,
      $$ReviewCardsTableOrderingComposer,
      $$ReviewCardsTableAnnotationComposer,
      $$ReviewCardsTableCreateCompanionBuilder,
      $$ReviewCardsTableUpdateCompanionBuilder,
      (
        ReviewCard,
        BaseReferences<_$AppDatabase, $ReviewCardsTable, ReviewCard>,
      ),
      ReviewCard,
      PrefetchHooks Function()
    >;
typedef $$ParentAuthTableCreateCompanionBuilder =
    ParentAuthCompanion Function({
      Value<int> id,
      required String pinHash,
      required String salt,
      Value<int> failedCount,
      Value<DateTime?> lockoutUntil,
    });
typedef $$ParentAuthTableUpdateCompanionBuilder =
    ParentAuthCompanion Function({
      Value<int> id,
      Value<String> pinHash,
      Value<String> salt,
      Value<int> failedCount,
      Value<DateTime?> lockoutUntil,
    });

class $$ParentAuthTableFilterComposer
    extends Composer<_$AppDatabase, $ParentAuthTable> {
  $$ParentAuthTableFilterComposer({
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

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockoutUntil => $composableBuilder(
    column: $table.lockoutUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ParentAuthTableOrderingComposer
    extends Composer<_$AppDatabase, $ParentAuthTable> {
  $$ParentAuthTableOrderingComposer({
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

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockoutUntil => $composableBuilder(
    column: $table.lockoutUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParentAuthTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParentAuthTable> {
  $$ParentAuthTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockoutUntil => $composableBuilder(
    column: $table.lockoutUntil,
    builder: (column) => column,
  );
}

class $$ParentAuthTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParentAuthTable,
          ParentAuthData,
          $$ParentAuthTableFilterComposer,
          $$ParentAuthTableOrderingComposer,
          $$ParentAuthTableAnnotationComposer,
          $$ParentAuthTableCreateCompanionBuilder,
          $$ParentAuthTableUpdateCompanionBuilder,
          (
            ParentAuthData,
            BaseReferences<_$AppDatabase, $ParentAuthTable, ParentAuthData>,
          ),
          ParentAuthData,
          PrefetchHooks Function()
        > {
  $$ParentAuthTableTableManager(_$AppDatabase db, $ParentAuthTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParentAuthTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParentAuthTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParentAuthTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pinHash = const Value.absent(),
                Value<String> salt = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<DateTime?> lockoutUntil = const Value.absent(),
              }) => ParentAuthCompanion(
                id: id,
                pinHash: pinHash,
                salt: salt,
                failedCount: failedCount,
                lockoutUntil: lockoutUntil,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pinHash,
                required String salt,
                Value<int> failedCount = const Value.absent(),
                Value<DateTime?> lockoutUntil = const Value.absent(),
              }) => ParentAuthCompanion.insert(
                id: id,
                pinHash: pinHash,
                salt: salt,
                failedCount: failedCount,
                lockoutUntil: lockoutUntil,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ParentAuthTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParentAuthTable,
      ParentAuthData,
      $$ParentAuthTableFilterComposer,
      $$ParentAuthTableOrderingComposer,
      $$ParentAuthTableAnnotationComposer,
      $$ParentAuthTableCreateCompanionBuilder,
      $$ParentAuthTableUpdateCompanionBuilder,
      (
        ParentAuthData,
        BaseReferences<_$AppDatabase, $ParentAuthTable, ParentAuthData>,
      ),
      ParentAuthData,
      PrefetchHooks Function()
    >;
typedef $$ParentQaTableCreateCompanionBuilder =
    ParentQaCompanion Function({
      required String id,
      required String question,
      Value<String?> plan,
      required String answer,
      required DateTime askedAt,
      Value<int> rowid,
    });
typedef $$ParentQaTableUpdateCompanionBuilder =
    ParentQaCompanion Function({
      Value<String> id,
      Value<String> question,
      Value<String?> plan,
      Value<String> answer,
      Value<DateTime> askedAt,
      Value<int> rowid,
    });

class $$ParentQaTableFilterComposer
    extends Composer<_$AppDatabase, $ParentQaTable> {
  $$ParentQaTableFilterComposer({
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

  ColumnFilters<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get askedAt => $composableBuilder(
    column: $table.askedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ParentQaTableOrderingComposer
    extends Composer<_$AppDatabase, $ParentQaTable> {
  $$ParentQaTableOrderingComposer({
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

  ColumnOrderings<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get askedAt => $composableBuilder(
    column: $table.askedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParentQaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParentQaTable> {
  $$ParentQaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<DateTime> get askedAt =>
      $composableBuilder(column: $table.askedAt, builder: (column) => column);
}

class $$ParentQaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParentQaTable,
          ParentQaData,
          $$ParentQaTableFilterComposer,
          $$ParentQaTableOrderingComposer,
          $$ParentQaTableAnnotationComposer,
          $$ParentQaTableCreateCompanionBuilder,
          $$ParentQaTableUpdateCompanionBuilder,
          (
            ParentQaData,
            BaseReferences<_$AppDatabase, $ParentQaTable, ParentQaData>,
          ),
          ParentQaData,
          PrefetchHooks Function()
        > {
  $$ParentQaTableTableManager(_$AppDatabase db, $ParentQaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParentQaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParentQaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParentQaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> question = const Value.absent(),
                Value<String?> plan = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<DateTime> askedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParentQaCompanion(
                id: id,
                question: question,
                plan: plan,
                answer: answer,
                askedAt: askedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String question,
                Value<String?> plan = const Value.absent(),
                required String answer,
                required DateTime askedAt,
                Value<int> rowid = const Value.absent(),
              }) => ParentQaCompanion.insert(
                id: id,
                question: question,
                plan: plan,
                answer: answer,
                askedAt: askedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ParentQaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParentQaTable,
      ParentQaData,
      $$ParentQaTableFilterComposer,
      $$ParentQaTableOrderingComposer,
      $$ParentQaTableAnnotationComposer,
      $$ParentQaTableCreateCompanionBuilder,
      $$ParentQaTableUpdateCompanionBuilder,
      (
        ParentQaData,
        BaseReferences<_$AppDatabase, $ParentQaTable, ParentQaData>,
      ),
      ParentQaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LearnerProfileTableTableManager get learnerProfile =>
      $$LearnerProfileTableTableManager(_db, _db.learnerProfile);
  $$ProblemsTableTableManager get problems =>
      $$ProblemsTableTableManager(_db, _db.problems);
  $$ConversationTurnsTableTableManager get conversationTurns =>
      $$ConversationTurnsTableTableManager(_db, _db.conversationTurns);
  $$ReviewCardsTableTableManager get reviewCards =>
      $$ReviewCardsTableTableManager(_db, _db.reviewCards);
  $$ParentAuthTableTableManager get parentAuth =>
      $$ParentAuthTableTableManager(_db, _db.parentAuth);
  $$ParentQaTableTableManager get parentQa =>
      $$ParentQaTableTableManager(_db, _db.parentQa);
}
