import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:daksha/domain/tutor_service.dart';
import 'package:daksha/services/parent/parent_auth_service.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [LearnerProfile, Problems, ConversationTurns, ReviewCards, ParentAuth],
)
class AppDatabase extends _$AppDatabase implements ProblemStore, AuthStore {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(parentAuth);
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
