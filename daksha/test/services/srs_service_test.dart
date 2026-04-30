import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/services/srs_service.dart';

void main() {
  group('SrsService.nextBox', () {
    test('correct from box 1 → box 2', () {
      expect(SrsService.nextBox(correct: true, currentBox: 1), 2);
    });

    test('correct from box 5 stays at 5 (capped)', () {
      expect(SrsService.nextBox(correct: true, currentBox: 5), 5);
    });

    test('wrong from box 3 → reset to box 1', () {
      expect(SrsService.nextBox(correct: false, currentBox: 3), 1);
    });

    test('wrong from box 1 → stays at 1', () {
      expect(SrsService.nextBox(correct: false, currentBox: 1), 1);
    });
  });

  group('SrsService.dueAt', () {
    test('box 1 → now + 1 day', () {
      final now = DateTime(2024, 1, 1);
      expect(SrsService.dueAt(1, now), now.add(const Duration(days: 1)));
    });

    test('box 5 → now + 30 days', () {
      final now = DateTime(2024, 1, 1);
      expect(SrsService.dueAt(5, now), now.add(const Duration(days: 30)));
    });
  });

  group('SrsService.dueQueue', () {
    test('returns only cards with dueAt ≤ now, ordered oldest-first', () {
      final now = DateTime(2024, 6, 15);
      final cards = [
        (dueAt: DateTime(2024, 6, 14), cardId: 'older'),
        (dueAt: DateTime(2024, 6, 15), cardId: 'today'),
        (dueAt: DateTime(2024, 6, 16), cardId: 'future'),
      ];
      final result = SrsService.dueQueue(cards, now);
      expect(result, ['older', 'today']);
    });

    test('excludes cards due in the future', () {
      final now = DateTime(2024, 6, 15);
      final cards = [
        (dueAt: DateTime(2024, 6, 20), cardId: 'future1'),
        (dueAt: DateTime(2024, 6, 16), cardId: 'future2'),
      ];
      expect(SrsService.dueQueue(cards, now), isEmpty);
    });
  });
}
