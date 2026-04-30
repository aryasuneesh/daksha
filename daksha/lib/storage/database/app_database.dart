import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LearnerProfile, Problems, ConversationTurns, ReviewCards])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
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
