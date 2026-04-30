import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:daksha/core/theme.dart';
import 'package:daksha/features/common/bottom_action_bar.dart';
import 'package:daksha/features/tutor/home_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp.router(
        theme: buildDakshaTheme(),
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => child,
            ),
            GoRoute(
              path: '/capture',
              builder: (_, __) => const Scaffold(body: Text('Capture')),
            ),
          ],
        ),
      ),
    );

void main() {
  group('HomeScreen', () {
    testWidgets('renders all 4 subject cards', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();

      expect(find.text('Math'), findsOneWidget);
      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Chemistry'), findsOneWidget);
      expect(find.text('Biology'), findsOneWidget);
    });

    testWidgets('renders BottomActionBar', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();

      expect(find.byType(BottomActionBar), findsOneWidget);
    });

    testWidgets('renders Start review button', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();

      expect(find.textContaining('Start review'), findsOneWidget);
    });
  });
}
