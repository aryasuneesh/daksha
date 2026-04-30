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
