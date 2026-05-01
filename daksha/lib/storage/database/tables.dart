import 'package:drift/drift.dart';

// Stores the learner's session / streak state
class LearnerProfile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get streakDays => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActiveAt => dateTime().nullable()();
}

// A problem captured from camera or typed
class Problems extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get subject => text()(); // 'math' | 'physics' | ...
  TextColumn get topic => text()(); // classified topic
  TextColumn get rawText => text()(); // OCR'd or typed input
  TextColumn get imageUri => text().nullable()(); // local file URI
  DateTimeColumn get capturedAt => dateTime()();
  BoolColumn get solved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// One turn in a Socratic conversation
class ConversationTurns extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get problemId => text()(); // FK → Problems.id
  TextColumn get role => text()(); // 'user' | 'daksha'
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Spaced-repetition card for a problem
class ReviewCards extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get problemId => text()(); // FK → Problems.id
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get interval => integer().withDefault(const Constant(1))(); // days
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Parent Q&A: question asked via voice + 2-shot pipeline response
class ParentQa extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get question => text()(); // parent's spoken question
  TextColumn get plan => text().nullable()(); // PLAN pass output (internal)
  TextColumn get answer => text()(); // SPEAK pass output (shown to parent)
  DateTimeColumn get askedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Single-row table for parent PIN authentication
class ParentAuth extends Table {
  // Single row (id always 1)
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get pinHash => text()(); // hex-encoded Argon2id hash
  TextColumn get salt => text()(); // hex-encoded random salt (16 bytes)
  IntColumn get failedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lockoutUntil => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
