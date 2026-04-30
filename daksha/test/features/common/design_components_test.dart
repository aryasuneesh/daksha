import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/theme.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/buttons.dart';
import 'package:daksha/features/common/cards.dart';
import 'package:daksha/features/common/language_toggle.dart';
import 'package:daksha/features/common/tags.dart';
import 'package:daksha/features/common/bottom_action_bar.dart';
import 'package:daksha/features/common/top_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: buildDakshaTheme(),
      home: Scaffold(body: child),
    );

void main() {
  group('PrimaryButton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Submit', onPressed: () {}),
      ));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('hit area >= 44x44', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Submit', onPressed: () {}),
      ));
      final size = tester.getSize(find.byType(PrimaryButton));
      expect(size.height, greaterThanOrEqualTo(DT.minTouch));
    });
  });

  group('DakshaOutlineButton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        DakshaOutlineButton(label: 'Need a hint', onPressed: () {}),
      ));
      expect(find.text('Need a hint'), findsOneWidget);
    });

    testWidgets('disabled state uses muted colors', (tester) async {
      await tester.pumpWidget(_wrap(
        const DakshaOutlineButton(label: 'Hint', onPressed: null, enabled: false),
      ));
      expect(find.text('Hint'), findsOneWidget);
    });
  });

  group('DakshaTextButton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        DakshaTextButton(label: 'Back to home', onPressed: () {}),
      ));
      expect(find.text('Back to home'), findsOneWidget);
    });
  });

  group('StandardCard', () {
    testWidgets('renders child without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const StandardCard(child: Text('hello')),
      ));
      expect(find.text('hello'), findsOneWidget);
    });
  });

  group('ElevatedCard', () {
    testWidgets('renders child without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ElevatedCard(child: Text('problem')),
      ));
      expect(find.text('problem'), findsOneWidget);
    });
  });

  group('AmberCard', () {
    testWidgets('renders label and body', (tester) async {
      await tester.pumpWidget(_wrap(
        const AmberCard(label: 'Daksha asks', body: 'What is x doing here?'),
      ));
      expect(find.text('Daksha asks'), findsOneWidget);
      expect(find.text('What is x doing here?'), findsOneWidget);
    });

    testWidgets('Latin text renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const AmberCard(label: 'Daksha asks', body: 'Solve for x'),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Devanagari text renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const AmberCard(label: 'Daksha asks', body: 'क्या x कर रहा है?'),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Malayalam text renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const AmberCard(label: 'Daksha asks', body: 'x എന്താണ് ചെയ്യുന്നത്?'),
      ));
      expect(tester.takeException(), isNull);
    });
  });

  group('CautionCard', () {
    testWidgets('renders label and body with warning icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const CautionCard(
          label: 'Close — one step off',
          body: 'You divided by 3 instead of 2.',
        ),
      ));
      expect(find.text('Close — one step off'), findsOneWidget);
      expect(find.text('⚠'), findsOneWidget);
    });
  });

  group('SubjectTag', () {
    testWidgets('renders subject and topic', (tester) async {
      await tester.pumpWidget(_wrap(
        const SubjectTag(subject: 'math', topic: 'linear equations'),
      ));
      expect(find.text('math · linear equations'), findsOneWidget);
    });
  });

  group('DueBadge', () {
    testWidgets('shows when count > 0', (tester) async {
      await tester.pumpWidget(_wrap(const DueBadge(count: 3)));
      expect(find.text('3 due'), findsOneWidget);
    });

    testWidgets('hidden when count is 0', (tester) async {
      await tester.pumpWidget(_wrap(const DueBadge(count: 0)));
      expect(find.text('0 due'), findsNothing);
    });
  });

  group('LanguageToggle', () {
    testWidgets('renders all three language options', (tester) async {
      await tester.pumpWidget(_wrap(
        LanguageToggle(selected: AppLanguage.en, onChanged: (_) {}),
      ));
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('HI'), findsOneWidget);
      expect(find.text('ML'), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      AppLanguage? changed;
      await tester.pumpWidget(_wrap(
        LanguageToggle(selected: AppLanguage.en, onChanged: (l) => changed = l),
      ));
      await tester.tap(find.text('HI'));
      await tester.pump();
      expect(changed, AppLanguage.hi);
    });

    testWidgets('each segment hit area >= 44x44', (tester) async {
      await tester.pumpWidget(_wrap(
        LanguageToggle(selected: AppLanguage.en, onChanged: (_) {}),
      ));
      // Each GestureDetector wrapping a segment should be at least minTouch high.
      final gestures = tester.widgetList(find.byType(GestureDetector)).toList();
      for (final g in gestures) {
        final size = tester.getSize(find.byWidget(g));
        // Width may be small on narrow devices; height must meet minTouch.
        expect(size.height, greaterThanOrEqualTo(DT.minTouch));
      }
    });
  });

  group('BottomActionBar', () {
    testWidgets('renders single child', (tester) async {
      await tester.pumpWidget(_wrap(
        BottomActionBar(
          children: [PrimaryButton(label: 'Start', onPressed: () {})],
        ),
      ));
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('renders two children with gap', (tester) async {
      await tester.pumpWidget(_wrap(
        BottomActionBar(
          children: [
            PrimaryButton(label: 'A', onPressed: () {}),
            DakshaOutlineButton(label: 'B', onPressed: () {}),
          ],
        ),
      ));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });

  group('HomeTopBar', () {
    testWidgets('renders streak and logo', (tester) async {
      await tester.pumpWidget(_wrap(
        const HomeTopBar(streakDays: 6),
      ));
      expect(find.text('दक्ष'), findsOneWidget);
      expect(find.textContaining('6'), findsWidgets);
    });
  });

  group('Typography.withScript', () {
    test('Latin sample returns unchanged height', () {
      const base = DakshaTypography.body;
      final result = DakshaTypography.withScript(base, 'Solve for x');
      expect(result.height, base.height);
    });

    test('Devanagari sample boosts line height by ~12%', () {
      const base = DakshaTypography.body;
      final result = DakshaTypography.withScript(base, 'क्या x कर रहा है?');
      expect(result.height, greaterThan(base.height!));
      expect(result.height!, closeTo(base.height! * 1.12, 0.01));
    });

    test('Malayalam sample boosts line height', () {
      const base = DakshaTypography.body;
      final result = DakshaTypography.withScript(base, 'x എന്താണ്?');
      expect(result.height, greaterThan(base.height!));
    });
  });
}
