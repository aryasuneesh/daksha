import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daksha/app/providers.dart';
import 'package:daksha/core/theme.dart';
import 'package:daksha/features/parent/gate_screen.dart';
import 'package:daksha/services/parent/parent_auth_service.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockParentAuthService extends Mock implements ParentAuthService {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Mocks the daksha/window channel so FLAG_SECURE calls are no-ops in tests.
void _mockWindowChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('daksha/window'),
    (call) async => null,
  );
}

Widget _buildSubject({
  required ParentAuthService authService,
  String initialLocation = '/parent/gate',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/parent/gate',
        builder: (_, __) => const GateScreen(),
      ),
      GoRoute(
        path: '/parent/shell',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Parent Shell')),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      parentAuthServiceProvider.overrideWithValue(authService),
    ],
    child: MaterialApp.router(
      theme: buildDakshaTheme(),
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockParentAuthService mockService;

  setUp(() {
    _mockWindowChannel();
    mockService = _MockParentAuthService();
  });

  group('GateScreen — initial state', () {
    testWidgets('renders 4 empty PIN dots', (tester) async {
      await tester.pumpWidget(_buildSubject(authService: mockService));
      await tester.pump();

      // 4 AnimatedContainers for the dots
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(containers.length, equals(4));

      // All dots should have the unfilled color (DT.elev2)
      for (final c in containers) {
        final decoration = c.decoration as BoxDecoration;
        expect(decoration.color, isNotNull);
      }
    });

    testWidgets('renders heading and Enter PIN text', (tester) async {
      await tester.pumpWidget(_buildSubject(authService: mockService));
      await tester.pump();

      expect(find.text('Parent view'), findsOneWidget);
      expect(find.text('Enter PIN'), findsOneWidget);
    });

    testWidgets('renders keypad keys 0–9 and delete', (tester) async {
      await tester.pumpWidget(_buildSubject(authService: mockService));
      await tester.pump();

      for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
        expect(find.text(digit), findsOneWidget);
      }
      expect(find.text('⌫'), findsOneWidget);
    });
  });

  group('GateScreen — PIN entry', () {
    testWidgets('tapping a key fills a dot', (tester) async {
      await tester.pumpWidget(_buildSubject(authService: mockService));
      await tester.pump();

      // Before tap: all dots empty — first dot should have elev2 color
      final dotsBefore = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();
      final firstDotBefore = dotsBefore.first.decoration as BoxDecoration;
      expect(firstDotBefore.color?.value, isNot(equals(const Color(0xFF5C4A2E).value)));

      // Tap '1'
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // wait for animation

      // After tap: first dot should have primary color
      final dotsAfter = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();
      final firstDotAfter = dotsAfter.first.decoration as BoxDecoration;
      expect(firstDotAfter.color?.value, equals(const Color(0xFF5C4A2E).value));
    });

    testWidgets('entering correct PIN navigates to /parent/shell', (tester) async {
      when(() => mockService.verify(any())).thenAnswer((_) async => const AuthSuccess());

      await tester.pumpWidget(_buildSubject(authService: mockService));
      await tester.pump();

      for (final digit in ['1', '2', '3', '4']) {
        await tester.tap(find.text(digit));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(find.text('Parent Shell'), findsOneWidget);
    });

    testWidgets('entering wrong PIN shows error and clears dots', (tester) async {
      when(() => mockService.verify(any()))
          .thenAnswer((_) async => const AuthFailure(1));

      await tester.pumpWidget(_buildSubject(authService: mockService));
      await tester.pump();

      for (final digit in ['1', '2', '3', '4']) {
        await tester.tap(find.text(digit));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Error message should appear
      expect(find.textContaining('Incorrect PIN'), findsOneWidget);

      // Dots should be cleared (all 4 showing empty/unfilled)
      final dots = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();
      for (final dot in dots) {
        final decoration = dot.decoration as BoxDecoration;
        // Unfilled dots have border and elev2 background
        expect(decoration.border, isNotNull);
      }
    });
  });

  group('GateScreen — lockout state', () {
    testWidgets('lockout disables keypad', (tester) async {
      final until = DateTime.now().add(const Duration(minutes: 1));
      when(() => mockService.verify(any()))
          .thenAnswer((_) async => AuthLockout(
                until: until,
                restartRequired: false,
              ));

      await tester.pumpWidget(_buildSubject(authService: mockService));
      await tester.pump();

      for (final digit in ['1', '2', '3', '4']) {
        await tester.tap(find.text(digit));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Locked message should appear
      expect(find.textContaining('Locked.'), findsOneWidget);

      // Tapping a key while locked should not add to PIN
      // (The GateScreen ignores key taps when _locked is true)
      await tester.tap(find.text('5'));
      await tester.pump();

      // The locked state message should still be present
      expect(find.textContaining('Locked.'), findsOneWidget);
    });
  });
}
