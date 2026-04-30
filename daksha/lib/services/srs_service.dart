/// Pure Leitner-system SRS service — no Flutter or Drift imports.
class SrsService {
  // Intervals per box (1-indexed); index 0 is unused.
  static const List<int> intervals = [0, 1, 3, 7, 14, 30];

  /// Promote on correct answer, reset to box 1 on wrong answer.
  static int nextBox({required bool correct, required int currentBox}) {
    assert(currentBox >= 1 && currentBox <= 5);
    if (correct) return (currentBox + 1).clamp(1, 5);
    return 1;
  }

  /// Returns the [DateTime] when a card in [box] is due, given [now].
  static DateTime dueAt(int box, DateTime now) {
    assert(box >= 1 && box <= 5);
    return now.add(Duration(days: intervals[box]));
  }

  /// Filters [cards] to those with [dueAt] ≤ [now] and returns their IDs
  /// ordered oldest-first.
  static List<String> dueQueue(
    List<({DateTime dueAt, String cardId})> cards,
    DateTime now,
  ) {
    final due = cards.where((c) => !c.dueAt.isAfter(now)).toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return due.map((c) => c.cardId).toList();
  }
}
