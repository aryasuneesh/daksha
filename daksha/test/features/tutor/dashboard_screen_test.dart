import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:daksha/core/theme.dart';
import 'package:daksha/features/tutor/dashboard_screen.dart';

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
          ],
        ),
      ),
    );

void main() {
  group('DashboardScreen', () {
    testWidgets('renders all 4 subject labels', (tester) async {
      await tester.pumpWidget(_wrap(const DashboardScreen()));
      await tester.pump();

      expect(find.text('Math'), findsOneWidget);
      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Chemistry'), findsOneWidget);
      expect(find.text('Biology'), findsOneWidget);
    });

    testWidgets('"Needs work" section is present', (tester) async {
      await tester.pumpWidget(_wrap(const DashboardScreen()));
      await tester.pump();

      expect(find.text('Needs work'), findsOneWidget);
    });

    testWidgets('"Practice weakest now" button is present', (tester) async {
      await tester.pumpWidget(_wrap(const DashboardScreen()));
      await tester.pump();

      expect(find.text('Practice weakest now'), findsOneWidget);
    });
  });
}
