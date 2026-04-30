import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:daksha/app/providers.dart';
import 'package:daksha/core/theme.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/tutor_service.dart';
import 'package:daksha/domain/tutor_state.dart';
import 'package:daksha/features/common/cards.dart';
import 'package:daksha/features/tutor/problem_screen.dart';
import 'package:daksha/features/tutor/widgets/daksha_bubble.dart';
import 'package:daksha/features/tutor/widgets/hint_level_dots.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class _MockTutorService extends StateNotifier<TutorState>
    implements TutorService {
  _MockTutorService(super.initial);

  @override
  Future<void> startProblem(String problemText) async {}

  @override
  Future<void> submitAttempt(String attempt) async {}

  @override
  Future<void> requestHint() async {}

  @override
  void reset() {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _mathTopic = Topic(
  subject: 'math',
  slug: 'algebra',
  displayName: 'Algebra',
);

Widget _wrapWithState(TutorState state) {
  return ProviderScope(
    overrides: [
      tutorServiceProvider.overrideWith(
        (ref) => _MockTutorService(state),
      ),
    ],
    child: MaterialApp.router(
      theme: buildDakshaTheme(),
      routerConfig: GoRouter(
        initialLocation: '/problem',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/problem',
            builder: (_, __) => const ProblemScreen(problemText: 'Solve: x + 3 = 7'),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ProblemScreen — TutorAsking', () {
    testWidgets('shows DakshaBubble with opener text', (tester) async {
      await tester.pumpWidget(
        _wrapWithState(
          const TutorState.asking(
            problemText: 'Solve: x + 3 = 7',
            topic: _mathTopic,
            opener: 'What is x?',
            problemId: 'test-id',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DakshaBubble), findsOneWidget);
      expect(find.text('What is x?'), findsOneWidget);
    });
  });

  group('ProblemScreen — TutorHinting', () {
    testWidgets('shows AmberCard with hint label and HintLevelDots', (tester) async {
      await tester.pumpWidget(
        _wrapWithState(
          TutorState.hinting(
            problemText: 'Solve: x + 3 = 7',
            topic: _mathTopic,
            level: 2,
            hint: 'Think about subtraction',
            problemId: 'test-id',
            firstHintAt: DateTime(2024, 1, 1),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AmberCard), findsOneWidget);
      expect(find.text('Hint 2'), findsOneWidget);
      expect(find.byType(HintLevelDots), findsOneWidget);
    });

    testWidgets('HintLevelDots shows 2 filled dots at level 2', (tester) async {
      await tester.pumpWidget(
        _wrapWithState(
          TutorState.hinting(
            problemText: 'Solve: x + 3 = 7',
            topic: _mathTopic,
            level: 2,
            hint: 'Think about subtraction',
            problemId: 'test-id',
            firstHintAt: DateTime(2024, 1, 1),
          ),
        ),
      );
      await tester.pump();

      final dots = tester.widget<HintLevelDots>(find.byType(HintLevelDots));
      expect(dots.level, equals(2));
    });
  });

  group('ProblemScreen — TutorSolved', () {
    testWidgets('shows solved state placeholder text', (tester) async {
      await tester.pumpWidget(
        _wrapWithState(
          const TutorState.solved(problemId: 'done-id'),
        ),
      );
      await tester.pump();
      // In the solved state, the chat area shows 'Solved!' text
      // (navigation via ref.listen is async and may not complete in sync tests)
      expect(find.text('Solved!'), findsOneWidget);
    });
  });
}
