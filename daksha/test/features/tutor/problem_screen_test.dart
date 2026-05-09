import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/native.dart';

import 'package:daksha/app/providers.dart';
import 'package:daksha/core/theme.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/tutor_service.dart';
import 'package:daksha/domain/tutor_state.dart';
import 'package:daksha/features/tutor/problem_screen.dart';
import 'package:daksha/features/tutor/solved_screen.dart';
import 'package:daksha/features/tutor/widgets/daksha_bubble.dart';
import 'package:daksha/features/tutor/widgets/hint_level_dots.dart';
import 'package:daksha/inference/inference_engine.dart';
import 'package:daksha/storage/database/app_database.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class _MockTutorService extends StateNotifier<TutorState>
    implements TutorService {
  _MockTutorService(super.initial);

  void setState(TutorState next) => state = next;

  @override
  Future<void> startProblem(String problemText) async {}

  @override
  Future<void> resumeProblem({
    required String problemId,
    required String problemText,
    required Topic topic,
  }) async {}

  @override
  Future<void> submitAttempt(String attempt) async {}

  @override
  Future<void> requestHint() async {}

  @override
  void reset() {}
}

// Inert engine — ProblemScreen only ever needs `engineProvider.hasValue` to be
// true; the actual InferenceEngine is never invoked because tutorServiceProvider
// is also overridden by the [_MockTutorService] above.
class _NoopEngine implements InferenceEngine {
  @override
  Future<void> load() async {}
  @override
  Future<void> dispose() async {}
  @override
  bool get isLoaded => true;
  @override
  bool get supportsVision => false;
  @override
  Future<InferenceResponse> generate(InferenceRequest request) async =>
      const InferenceResponse.success(text: '');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _mathTopic = Topic(
  subject: 'math',
  slug: 'algebra',
  displayName: 'Algebra',
);

/// Wraps a ProblemScreen for testing.
///
/// [seedTurns] runs against a fresh in-memory DB before the screen builds
/// so tests can pre-populate the conversation log that drives the chat.
/// Returns the test wrapper plus the [AppDatabase] so each test can close
/// it in tearDown — without that we leak open file handles between tests
/// and trigger drift's "multiple databases" warning.
({Widget widget, AppDatabase db}) _wrapWithState(
  TutorState state, {
  Future<void> Function(AppDatabase db)? seedTurns,
}) {
  final db = AppDatabase(NativeDatabase.memory());

  Future<void> seedFuture =
      seedTurns == null ? Future.value() : seedTurns(db);

  // Override the three async deps so ProblemScreen.allReady is true at
  // first pump — without these the screen would render its "warming up"
  // spinner and never show the chat content under test.
  final widget = ProviderScope(
    overrides: [
      engineProvider.overrideWith((ref) async => _NoopEngine()),
      dbProvider.overrideWith((ref) async {
        await seedFuture;
        return db;
      }),
      taxonomyProvider.overrideWith((ref) async => const [_mathTopic]),
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
          GoRoute(
            path: '/solved',
            builder: (_, __) => const SolvedScreen(),
          ),
        ],
      ),
    ),
  );
  return (widget: widget, db: db);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ProblemScreen — chat hydration from DB', () {
    testWidgets('renders a daksha bubble seeded into the conversation table',
        (tester) async {
      // The chat list is now driven by [AppDatabase.watchTurns], not by
      // [TutorState.opener]. Seeding a turn proves the DB → bubble path
      // works, which is what makes resume-from-history show prior content.
      final harness = _wrapWithState(
        const TutorState.asking(
          problemText: 'Solve: x + 3 = 7',
          topic: _mathTopic,
          opener: 'What is x?',
          problemId: 'test-id',
        ),
        seedTurns: (db) async {
          await db.insertTurn(
            problemId: 'test-id',
            role: 'daksha',
            content: 'What is x?',
            createdAt: DateTime(2024, 1, 1),
          );
        },
      );
      await tester.pumpWidget(harness.widget);
      // pumpAndSettle would deadlock on the placeholder's
      // CircularProgressIndicator (indefinite animation). Manual pumps
      // drain the post-frame callbacks and the auto-scroll's 200ms
      // animation without requiring the spinner to come to rest.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(DakshaBubble), findsOneWidget);
      expect(find.text('What is x?'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await harness.db.close();
    });
  });

  group('ProblemScreen — TutorHinting', () {
    testWidgets('renders HintLevelDots reflecting the current level',
        (tester) async {
      final harness = _wrapWithState(
        TutorState.hinting(
          problemText: 'Solve: x + 3 = 7',
          topic: _mathTopic,
          level: 2,
          hint: 'Think about subtraction',
          problemId: 'test-id',
          firstHintAt: DateTime(2024, 1, 1),
          opener: 'What is x?',
        ),
      );
      await tester.pumpWidget(harness.widget);
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final dots = tester.widget<HintLevelDots>(find.byType(HintLevelDots));
      expect(dots.level, equals(2));

      await tester.pumpWidget(const SizedBox());
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await harness.db.close();
    });
  });

  group('ProblemScreen — TutorSolved', () {
    testWidgets('does NOT auto-navigate to /solved on TutorSolved',
        (tester) async {
      // Auto-navigation was removed: the student may have follow-up doubts
      // even after a correct answer, and being thrown to a separate screen
      // killed the conversation.
      final mockService = _MockTutorService(
        const TutorState.asking(
          problemText: 'Solve: x + 3 = 7',
          topic: _mathTopic,
          opener: 'What is x?',
          problemId: 'test-id',
        ),
      );
      final db = AppDatabase(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            engineProvider.overrideWith((ref) async => _NoopEngine()),
            dbProvider.overrideWith((ref) async => db),
            taxonomyProvider.overrideWith((ref) async => const [_mathTopic]),
            tutorServiceProvider.overrideWith((_) => mockService),
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
                  builder: (_, __) =>
                      const ProblemScreen(problemText: 'Solve: x + 3 = 7'),
                ),
                GoRoute(
                  path: '/solved',
                  builder: (_, __) => const SolvedScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      mockService.setState(const TutorState.solved(
        problemId: 'done-id',
        problemText: 'Solve x + 2 = 5',
        topic: Topic(subject: 'math', slug: 'algebra', displayName: 'Algebra'),
        opener: 'What is x?',
      ));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // ProblemScreen stays mounted. The Solved ✓ badge appears in the
      // top bar and the SolvedScreen is NOT pushed.
      expect(find.byType(ProblemScreen), findsOneWidget);
      expect(find.byType(SolvedScreen), findsNothing);
      expect(find.textContaining('Solved'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await db.close();
    });
  });
}
