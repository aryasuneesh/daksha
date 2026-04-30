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

/// Opens the encrypted database.
/// [key] must be a 64-char hex string from SecureKeyProvider.
Future<AppDatabase> openAppDatabase(String key) async {
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(dir.path, 'daksha.db');

  final executor = NativeDatabase.createInBackground(
    File(dbPath),
    setup: (db) {
      // SQLCipher key pragma — must be first statement
      db.execute("PRAGMA key = '$key';");
    },
  );

  return AppDatabase(executor);
}
