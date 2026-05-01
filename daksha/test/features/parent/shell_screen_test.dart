import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:daksha/core/theme.dart';
import 'package:daksha/features/common/language_toggle.dart';
import 'package:daksha/features/parent/shell_screen.dart';

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

/// Stubs rootBundle asset loading for i18n JSON files.
void _mockI18nAssets() {
  final assets = <String, String>{
    'assets/i18n/en.json': jsonEncode({
      'parent_view': 'Parent view',
      'time_label': 'Time',
      'streak_label': 'Streak',
      'topics_label': 'Topics',
      'mastery_title': 'Mastery',
      'needs_attention_title': 'Needs attention',
      'no_attention_needed': 'All topics on track',
      'read_aloud': '🔊 Read',
      'ask_daksha': '🎤 Ask Daksha',
      'minutes_used': '{n} min',
      'streak_days': '{n} days',
      'topics_covered': '{n} topics',
    }),
    'assets/i18n/hi.json': jsonEncode({
      'parent_view': 'अभिभावक दृश्य',
      'time_label': 'समय',
      'streak_label': 'स्ट्रीक',
      'topics_label': 'विषय',
      'mastery_title': 'दक्षता',
      'needs_attention_title': 'ध्यान दें',
      'no_attention_needed': 'सभी विषय सही हैं',
      'read_aloud': '🔊 पढ़ें',
      'ask_daksha': '🎤 दक्ष से पूछें',
      'minutes_used': '{n} मिनट',
      'streak_days': '{n} दिन',
      'topics_covered': '{n} विषय',
    }),
    'assets/i18n/ml.json': jsonEncode({
      'parent_view': 'രക്ഷകർത്താവ്',
      'time_label': 'സമയം',
      'streak_label': 'സ്ട്രീക്',
      'topics_label': 'വിഷയങ്ങൾ',
      'mastery_title': 'പ്രാവീണ്യം',
      'needs_attention_title': 'ശ്രദ്ധ ആവശ്യമാണ്',
      'no_attention_needed': 'എല്ലാ വിഷയങ്ങളും ശരിയാണ്',
      'read_aloud': '🔊 വായിക്കുക',
      'ask_daksha': '🎤 ദക്ഷനോട് ചോദിക്കുക',
      'minutes_used': '{n} മിനിറ്റ്',
      'streak_days': '{n} ദിവസം',
      'topics_covered': '{n} വിഷയങ്ങൾ',
    }),
  };

  // Flutter's 'flutter/assets' channel sends the key as raw UTF-8 bytes
  // and expects the response as raw asset bytes (no length prefix).
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    if (message == null) return null;
    final key = utf8.decode(
      message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes),
    );
    final content = assets[key];
    if (content == null) return null;
    // Return raw UTF-8 bytes; AssetBundle.loadString will decode them.
    final encoded = utf8.encode(content);
    return ByteData.sublistView(Uint8List.fromList(encoded));
  });
}

Widget _buildSubject({String initialLocation = '/parent/shell'}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/parent/shell',
        builder: (_, __) => const ShellScreen(),
      ),
      GoRoute(
        path: '/parent/gate',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Parent Gate'))),
      ),
      GoRoute(
        path: '/parent/voice',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Parent Voice'))),
      ),
    ],
  );

  return ProviderScope(
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
  setUp(() {
    _mockWindowChannel();
    _mockI18nAssets();

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('daksha/window'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });
  });

  // ── English ─────────────────────────────────────────────────────────────────
  group('ShellScreen — English', () {
    testWidgets('shows Time, Streak, Topics labels', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('Topics'), findsOneWidget);
    });

    testWidgets('shows Mastery section heading', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Mastery'), findsOneWidget);
    });

    testWidgets('shows Needs attention CautionCard', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Needs attention'), findsOneWidget);
    });

    testWidgets('BottomActionBar has Read and Ask Daksha buttons',
        (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('🔊 Read'), findsOneWidget);
      expect(find.text('🎤 Ask Daksha'), findsOneWidget);
    });
  });

  // ── Hindi ───────────────────────────────────────────────────────────────────
  group('ShellScreen — Hindi', () {
    testWidgets('switching to Hindi renders Devanagari text and mastery title',
        (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      // Tap the HI button
      await tester.tap(find.text('HI'));
      await tester.pumpAndSettle();

      // Devanagari for "Time"
      expect(find.text('समय'), findsOneWidget);

      // Verify the mastery title widget has Devanagari content
      final masteryTitle =
          tester.widget<Text>(find.byKey(const Key('mastery_title')));
      final titleText = masteryTitle.data ?? '';
      // Check it contains Devanagari characters (U+0900–U+097F range)
      final hasDevanagari =
          titleText.runes.any((r) => r >= 0x0900 && r <= 0x097F);
      expect(hasDevanagari, isTrue,
          reason:
              'Mastery title should contain Devanagari text, got: $titleText');
    });
  });

  // ── Malayalam ───────────────────────────────────────────────────────────────
  group('ShellScreen — Malayalam', () {
    testWidgets('switching to ML renders Malayalam text and mastery title',
        (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      // Tap the ML button
      await tester.tap(find.text('ML'));
      await tester.pumpAndSettle();

      // Malayalam for "Time"
      expect(find.text('സമയം'), findsOneWidget);

      // Verify the mastery title widget has Malayalam content
      final masteryTitle =
          tester.widget<Text>(find.byKey(const Key('mastery_title')));
      final titleText = masteryTitle.data ?? '';
      // Check it contains Malayalam characters (U+0D00–U+0D7F range)
      final hasMalayalam =
          titleText.runes.any((r) => r >= 0x0D00 && r <= 0x0D7F);
      expect(hasMalayalam, isTrue,
          reason:
              'Mastery title should contain Malayalam text, got: $titleText');
    });
  });

  // ── Language toggle ─────────────────────────────────────────────────────────
  group('ShellScreen — language toggle', () {
    testWidgets('LanguageToggle widget is present', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(LanguageToggle), findsOneWidget);
    });
  });
}
