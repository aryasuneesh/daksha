import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:daksha/domain/tutor_service.dart';
import 'package:daksha/services/parent/parent_auth_service.dart';
import 'package:daksha/services/parent/parent_service.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [LearnerProfile, Problems, ConversationTurns, ReviewCards, ParentAuth, ParentQa],
)
class AppDatabase extends _$AppDatabase implements ProblemStore, AuthStore, ParentQaStore {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(parentAuth);
      }
      if (from < 3) {
        await m.createTable(parentQa);
      }
    },
  );

  // ---------------------------------------------------------------------------
  // ProblemStore implementation
  // ---------------------------------------------------------------------------

  @override
  Future<String> insertProblem({
    required String text,
    required String subject,
    required String topicSlug,
    required DateTime createdAt,
  }) async {
    final id = const Uuid().v4();
    await into(problems).insert(
      ProblemsCompanion.insert(
        id: id,
        subject: subject,
        topic: topicSlug,
        rawText: text,
        capturedAt: createdAt,
      ),
    );
    return id;
  }

  @override
  Future<void> updateProblem(String id, {bool? solved}) async {
    if (solved != null) {
      await (update(problems)..where((t) => t.id.equals(id))).write(
        ProblemsCompanion(solved: Value(solved)),
      );
    }
  }

  @override
  Future<void> insertTurn({
    required String problemId,
    required String role,
    required String content,
    required DateTime createdAt,
  }) async {
    final id = const Uuid().v4();
    await into(conversationTurns).insert(
      ConversationTurnsCompanion.insert(
        id: id,
        problemId: problemId,
        role: role,
        content: content,
        createdAt: createdAt,
      ),
    );
  }

  @override
  Future<List<StoredTurn>> readTurns(String problemId) async {
    final rows = await (select(conversationTurns)
          ..where((t) => t.problemId.equals(problemId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows
        .map((r) => StoredTurn(
              role: r.role,
              content: r.content,
              createdAt: r.createdAt,
            ))
        .toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // History queries
  // ---------------------------------------------------------------------------

  /// All problems, most recent first.  Emits whenever any row changes.
  Stream<List<Problem>> watchAllProblems() {
    return (select(problems)
          ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
        .watch();
  }

  /// Turns for a single problem, ordered oldest-first for chat replay.
  Stream<List<ConversationTurn>> watchTurns(String problemId) {
    return (select(conversationTurns)
          ..where((t) => t.problemId.equals(problemId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Deletes a problem and its conversation turns atomically.
  /// The schema has no FK cascade, so we wipe turns in the same transaction.
  Future<void> deleteProblem(String id) async {
    await transaction(() async {
      await (delete(conversationTurns)
            ..where((t) => t.problemId.equals(id)))
          .go();
      await (delete(problems)..where((t) => t.id.equals(id))).go();
    });
  }

  // ---------------------------------------------------------------------------
  // Learner profile / streak
  // ---------------------------------------------------------------------------

  /// Returns the current streak in days, or 0 if no learner profile row.
  Future<int> getStreakDays() async {
    final row = await (select(learnerProfile)..limit(1)).getSingleOrNull();
    return row?.streakDays ?? 0;
  }

  /// Stream of the streak — emits on any change to learner_profile.
  Stream<int> watchStreakDays() {
    return (select(learnerProfile)..limit(1))
        .watchSingleOrNull()
        .map((row) => row?.streakDays ?? 0);
  }

  /// Records that the learner did something today. Updates streak based on
  /// the calendar-day delta from the last activity:
  ///   - same calendar day → streak unchanged
  ///   - exactly 1 day ago → streak + 1
  ///   - never / > 1 day ago → streak resets to 1
  /// Always bumps `lastActiveAt` to [now]. Single-row table (id=1).
  @override
  Future<void> recordActivity(DateTime now) async {
    final existing = await (select(learnerProfile)..limit(1)).getSingleOrNull();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak;
    if (existing == null || existing.lastActiveAt == null) {
      newStreak = 1;
    } else {
      final last = existing.lastActiveAt!;
      final lastDay = DateTime(last.year, last.month, last.day);
      final diffDays = today.difference(lastDay).inDays;
      if (diffDays == 0) {
        newStreak = existing.streakDays;
      } else if (diffDays == 1) {
        newStreak = existing.streakDays + 1;
      } else {
        newStreak = 1;
      }
    }

    if (existing == null) {
      await into(learnerProfile).insert(
        LearnerProfileCompanion.insert(
          name: 'Learner',
          streakDays: Value(newStreak),
          lastActiveAt: Value(now),
        ),
      );
    } else {
      await (update(learnerProfile)..where((t) => t.id.equals(existing.id)))
          .write(
        LearnerProfileCompanion(
          streakDays: Value(newStreak),
          lastActiveAt: Value(now),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // AuthStore implementation
  // ---------------------------------------------------------------------------

  @override
  Future<ParentAuthRow?> getAuthRow() async {
    final row = await (select(parentAuth)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (row == null) return null;
    return ParentAuthRow(
      pinHash: row.pinHash,
      salt: row.salt,
      failedCount: row.failedCount,
      lockoutUntil: row.lockoutUntil,
    );
  }

  @override
  Future<void> upsertAuthRow(ParentAuthRow row) async {
    await into(parentAuth).insertOnConflictUpdate(
      ParentAuthCompanion(
        id: const Value(1),
        pinHash: Value(row.pinHash),
        salt: Value(row.salt),
        failedCount: Value(row.failedCount),
        lockoutUntil: Value(row.lockoutUntil),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ParentQaStore implementation
  // ---------------------------------------------------------------------------

  @override
  Future<String> insertQa({
    required String question,
    required String? plan,
    required String answer,
    required DateTime askedAt,
  }) async {
    final id = const Uuid().v4();
    await into(parentQa).insert(
      ParentQaCompanion.insert(
        id: id,
        question: question,
        plan: Value(plan),
        answer: answer,
        askedAt: askedAt,
      ),
    );
    return id;
  }
}

/// Opens the encrypted database. [key] must be a 64-char hex string.
Future<AppDatabase> openAppDatabase(String key) async {
  if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(key)) {
    throw ArgumentError('Database key must be a 64-char hex string.');
  }
  final dir = await getApplicationSupportDirectory();
  final dbPath = p.join(dir.path, 'daksha.db');

  final executor = NativeDatabase.createInBackground(
    File(dbPath),
    setup: (db) {
      db.execute("PRAGMA key = \"x'$key'\";");
    },
  );

  return AppDatabase(executor);
}
