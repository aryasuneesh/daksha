import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/services/parent/digest_service.dart';
import 'package:daksha/storage/database/app_database.dart';

// ---------------------------------------------------------------------------
// Helper — open an in-memory database for each test
// ---------------------------------------------------------------------------

AppDatabase _openMemoryDb() => AppDatabase(NativeDatabase.memory());

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late AppDatabase db;
  late DigestService service;

  setUp(() {
    db = _openMemoryDb();
    service = DigestService(db);
  });

  tearDown(() async {
    await db.close();
  });

  final kNow = DateTime(2025, 6, 15, 12, 0, 0);

  // ── 1. Empty DB ────────────────────────────────────────────────────────────
  group('empty database', () {
    test('returns all zeros / empty lists', () async {
      final digest = await service.weekly(kNow);

      expect(digest.streakDays, equals(0));
      expect(digest.minutesUsed, equals(0));
      expect(digest.topicsCovered, equals(0));
      expect(digest.masteryBySubject, isEmpty);
      expect(digest.needsAttention, isEmpty);
    });
  });

  // ── 2. streakDays from LearnerProfile ─────────────────────────────────────
  group('streak days', () {
    test('reads streak from learner_profile', () async {
      await db.into(db.learnerProfile).insert(
            LearnerProfileCompanion.insert(name: 'Student', streakDays: const Value(7)),
          );

      final digest = await service.weekly(kNow);
      expect(digest.streakDays, equals(7));
    });

    test('returns 0 when learner_profile is empty', () async {
      final digest = await service.weekly(kNow);
      expect(digest.streakDays, equals(0));
    });
  });

  // ── 3. minutesUsed from ConversationTurns ─────────────────────────────────
  group('minutes used', () {
    test('counts turns in last 7 days × 2', () async {
      // Insert a problem first (foreign key)
      await db.into(db.problems).insert(
            ProblemsCompanion.insert(
              id: 'p1',
              subject: 'math',
              topic: 'algebra',
              rawText: 'Solve x',
              capturedAt: kNow,
            ),
          );

      // 3 turns in last 7 days → 6 minutes
      for (var i = 0; i < 3; i++) {
        await db.into(db.conversationTurns).insert(
              ConversationTurnsCompanion.insert(
                id: 'turn-$i',
                problemId: 'p1',
                role: 'daksha',
                content: 'Hello',
                createdAt: kNow.subtract(Duration(days: i)), // within 7 days
              ),
            );
      }

      // 1 turn older than 7 days → should NOT be counted
      await db.into(db.conversationTurns).insert(
            ConversationTurnsCompanion.insert(
              id: 'turn-old',
              problemId: 'p1',
              role: 'user',
              content: 'Old',
              createdAt: kNow.subtract(const Duration(days: 8)),
            ),
          );

      final digest = await service.weekly(kNow);
      expect(digest.minutesUsed, equals(6)); // 3 turns × 2 min
    });

    test('returns 0 when no turns in last 7 days', () async {
      final digest = await service.weekly(kNow);
      expect(digest.minutesUsed, equals(0));
    });
  });

  // ── 4. topicsCovered — distinct topics in last 7 days ─────────────────────
  group('topics covered', () {
    test('counts distinct topics created in last 7 days', () async {
      // 3 problems: 2 distinct topics in last 7 days, 1 older (excluded)
      final problems = [
        ('p1', 'math', 'algebra', kNow.subtract(const Duration(days: 1))),
        ('p2', 'math', 'algebra', kNow.subtract(const Duration(days: 2))), // same topic → not counted twice
        ('p3', 'physics', 'optics', kNow.subtract(const Duration(days: 3))),
        ('p4', 'chemistry', 'acids', kNow.subtract(const Duration(days: 8))), // old → excluded
      ];

      for (final (id, subj, topic, at) in problems) {
        await db.into(db.problems).insert(
              ProblemsCompanion.insert(
                id: id,
                subject: subj,
                topic: topic,
                rawText: 'text',
                capturedAt: at,
              ),
            );
      }

      final digest = await service.weekly(kNow);
      expect(digest.topicsCovered, equals(2)); // algebra + optics
    });
  });

  // ── 5. masteryBySubject ────────────────────────────────────────────────────
  group('mastery by subject', () {
    test('computes solved/total per subject', () async {
      // Math: 3 total, 2 solved → 66.6%
      // Physics: 2 total, 0 solved → 0%
      final problems = [
        ('m1', 'math', true),
        ('m2', 'math', true),
        ('m3', 'math', false),
        ('ph1', 'physics', false),
        ('ph2', 'physics', false),
      ];

      for (final (id, subj, solved) in problems) {
        final companionId = id;
        await db.into(db.problems).insert(
              ProblemsCompanion.insert(
                id: companionId,
                subject: subj,
                topic: 'topic',
                rawText: 'text',
                capturedAt: kNow,
                solved: Value(solved),
              ),
            );
      }

      final digest = await service.weekly(kNow);

      final mathEntry = digest.masteryBySubject.firstWhere((e) => e.$1 == 'math');
      final physicsEntry = digest.masteryBySubject.firstWhere((e) => e.$1 == 'physics');

      expect(mathEntry.$2, closeTo(2 / 3, 0.01));
      expect(physicsEntry.$2, closeTo(0.0, 0.01));
    });
  });

  // ── 6. needsAttention — subjects below 30% ─────────────────────────────────
  group('needs attention', () {
    test('subjects below 30% mastery appear in needsAttention', () async {
      // Math: 8/10 = 80% → NOT in needsAttention
      // Biology: 2/10 = 20% → IN needsAttention
      final subjects = {
        'math': (10, 8),    // total, solved
        'biology': (10, 2),
      };

      for (final entry in subjects.entries) {
        final (total, solved) = entry.value;
        for (var i = 0; i < total; i++) {
          await db.into(db.problems).insert(
                ProblemsCompanion.insert(
                  id: 'p-${entry.key}-$i',
                  subject: entry.key,
                  topic: 'topic',
                  rawText: 'text',
                  capturedAt: kNow,
                  solved: Value(i < solved),
                ),
              );
        }
      }

      final digest = await service.weekly(kNow);
      expect(digest.needsAttention, contains('biology'));
      expect(digest.needsAttention, isNot(contains('math')));
    });

    test('subject with exactly 30% is NOT in needsAttention', () async {
      // 3/10 = 30% → NOT below threshold, should not appear
      for (var i = 0; i < 10; i++) {
        await db.into(db.problems).insert(
              ProblemsCompanion.insert(
                id: 'p-$i',
                subject: 'chemistry',
                topic: 'topic',
                rawText: 'text',
                capturedAt: kNow,
                solved: Value(i < 3),
              ),
            );
      }

      final digest = await service.weekly(kNow);
      expect(digest.needsAttention, isNot(contains('chemistry')));
    });
  });
}
