import 'package:drift/drift.dart';
import 'package:daksha/storage/database/app_database.dart';

/// Value object returned by [DigestService.weekly].
class WeeklyDigest {
  const WeeklyDigest({
    required this.minutesUsed,
    required this.streakDays,
    required this.topicsCovered,
    required this.masteryBySubject,
    required this.needsAttention,
  });

  /// Approximate usage: count of conversation turns in last 7 days × 2 min each.
  final int minutesUsed;

  /// Current streak from LearnerProfile (fallback 0).
  final int streakDays;

  /// Distinct topic slugs in Problems created in last 7 days.
  final int topicsCovered;

  /// Per-subject mastery as a fraction 0.0–1.0 (solved / total).
  final List<(String name, double pct)> masteryBySubject;

  /// Subjects with mastery below 30%.
  final List<String> needsAttention;
}

/// Computes a [WeeklyDigest] from the on-device Drift database.
///
/// All queries use [AppDatabase.customSelect] to keep the implementation
/// straightforward without needing DAO code-gen.
class DigestService {
  const DigestService(this._db);

  final AppDatabase _db;

  Future<WeeklyDigest> weekly(DateTime now) async {
    final streakDays = await _queryStreakDays();
    final minutesUsed = await _queryMinutesUsed(now);
    final topicsCovered = await _queryTopicsCovered(now);
    final mastery = await _queryMasteryBySubject();

    final needsAttention = mastery
        .where((e) => e.$2 < 0.30)
        .map((e) => e.$1)
        .toList(growable: false);

    return WeeklyDigest(
      minutesUsed: minutesUsed,
      streakDays: streakDays,
      topicsCovered: topicsCovered,
      masteryBySubject: mastery,
      needsAttention: needsAttention,
    );
  }

  // ---------------------------------------------------------------------------
  // Private query helpers
  // ---------------------------------------------------------------------------

  Future<int> _queryStreakDays() async {
    final rows = await _db.customSelect(
      'SELECT streak_days FROM learner_profile LIMIT 1',
    ).get();
    if (rows.isEmpty) return 0;
    return rows.first.read<int>('streak_days');
  }

  Future<int> _queryMinutesUsed(DateTime now) async {
    final cutoff = now.subtract(const Duration(days: 7));
    final rows = await _db.customSelect(
      'SELECT COUNT(id) AS cnt FROM conversation_turns '
      'WHERE created_at >= ?',
      variables: [
        Variable<DateTime>(cutoff),
      ],
    ).get();
    if (rows.isEmpty) return 0;
    final count = rows.first.read<int>('cnt');
    return count * 2;
  }

  Future<int> _queryTopicsCovered(DateTime now) async {
    final cutoff = now.subtract(const Duration(days: 7));
    final rows = await _db.customSelect(
      'SELECT COUNT(DISTINCT topic) AS cnt FROM problems '
      'WHERE captured_at >= ?',
      variables: [
        Variable<DateTime>(cutoff),
      ],
    ).get();
    if (rows.isEmpty) return 0;
    return rows.first.read<int>('cnt');
  }

  Future<List<(String, double)>> _queryMasteryBySubject() async {
    final rows = await _db.customSelect(
      'SELECT subject, '
      '       COUNT(*) AS total, '
      '       SUM(CASE WHEN solved = 1 THEN 1 ELSE 0 END) AS solved_count '
      'FROM problems '
      'GROUP BY subject '
      'ORDER BY subject',
    ).get();

    return rows.map((row) {
      final subject = row.read<String>('subject');
      final total = row.read<int>('total');
      final solved = row.read<int>('solved_count');
      final pct = total > 0 ? solved / total : 0.0;
      return (subject, pct);
    }).toList(growable: false);
  }
}
