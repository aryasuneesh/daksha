import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:daksha/core/theme.dart';
import 'package:daksha/features/parent/voice_screen.dart';
import 'package:daksha/services/stt_service.dart';

// ---------------------------------------------------------------------------
// Fake STT engine
// ---------------------------------------------------------------------------

class _FakeSttEngine implements SttEngine {
  bool initResult = true;
  String? nextResult;
  bool _listening = false;
  final List<String> log = [];

  void Function(String)? _onResult;
  void Function()? _onDone;

  /// Simulate the engine delivering a result + done event.
  void deliverResult(String words) {
    _onResult?.call(words);
    _onDone?.call();
    _listening = false;
  }

  @override
  Future<bool> initialize() async {
    log.add('initialize');
    return initResult;
  }

  @override
  Future<void> listen({
    required String locale,
    required void Function(String words) onResult,
    required void Function() onDone,
  }) async {
    log.add('listen:$locale');
    _listening = true;
    _onResult = onResult;
    _onDone = onDone;
    if (nextResult != null) {
      // Simulate a final result followed by the session ending.
      onResult(nextResult!);
      _listening = false;
      onDone();
    }
  }

  @override
  Future<void> stop() async {
    log.add('stop');
    _listening = false;
  }

  @override
  bool get isAvailable => initResult;

  @override
  bool get isListening => _listening;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void _mockWindowChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('daksha/window'),
    (call) async => null,
  );
}

Widget _buildSubject(_FakeSttEngine engine) {
  final fakeStt = SttService(engine);
  final router = GoRouter(
    initialLocation: '/parent/voice',
    routes: [
      GoRoute(
        path: '/parent/voice',
        builder: (_, __) => VoiceScreen(sttForTesting: fakeStt),
      ),
      GoRoute(
        path: '/parent/shell',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Shell'))),
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
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('daksha/window'), null);
    });
  });

  group('VoiceScreen — empty state', () {
    testWidgets('shows empty state with mic emoji and Tap to speak',
        (tester) async {
      final engine = _FakeSttEngine();
      await tester.pumpWidget(_buildSubject(engine));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty_state')), findsOneWidget);
      expect(find.text('Tap to speak'), findsOneWidget);
    });

    testWidgets('mic button is rendered', (tester) async {
      final engine = _FakeSttEngine();
      await tester.pumpWidget(_buildSubject(engine));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('mic_button')), findsOneWidget);
    });
  });

  group('VoiceScreen — permission denied', () {
    testWidgets('shows permission denied view when init returns false',
        (tester) async {
      final engine = _FakeSttEngine()..initResult = false;
      await tester.pumpWidget(_buildSubject(engine));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('permission_denied')), findsOneWidget);
      expect(find.text('Microphone permission required'), findsOneWidget);
    });
  });

  group('VoiceScreen — listening', () {
    testWidgets('tapping mic starts listening and shows waveform',
        (tester) async {
      final engine = _FakeSttEngine();
      await tester.pumpWidget(_buildSubject(engine));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('mic_button')));
      await tester.pump();

      expect(engine.log, contains('listen:en-IN'));
      expect(find.byKey(const Key('waveform')), findsOneWidget);
    });

    testWidgets('transcription appears after result is delivered',
        (tester) async {
      final engine = _FakeSttEngine()..nextResult = 'Is the student struggling?';
      await tester.pumpWidget(_buildSubject(engine));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('mic_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('transcription_text')), findsOneWidget);
      expect(find.text('Is the student struggling?'), findsOneWidget);
    });

    testWidgets('tapping mic again stops listening', (tester) async {
      final engine = _FakeSttEngine();
      await tester.pumpWidget(_buildSubject(engine));
      await tester.pumpAndSettle();

      // Start
      await tester.tap(find.byKey(const Key('mic_button')));
      await tester.pump();

      expect(engine.isListening, isTrue);

      // Stop
      await tester.tap(find.byKey(const Key('mic_button')));
      await tester.pump();

      expect(engine.log, contains('stop'));
    });
  });

  group('VoiceScreen — language toggle', () {
    testWidgets('TopBar has language toggle', (tester) async {
      final engine = _FakeSttEngine();
      await tester.pumpWidget(_buildSubject(engine));
      await tester.pumpAndSettle();

      // ParentTopBar has a LanguageToggle
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('HI'), findsOneWidget);
      expect(find.text('ML'), findsOneWidget);
    });

    testWidgets('switching language stops active listening', (tester) async {
      final engine = _FakeSttEngine();
      await tester.pumpWidget(_buildSubject(engine));
      await tester.pumpAndSettle();

      // Start listening
      await tester.tap(find.byKey(const Key('mic_button')));
      await tester.pump();
      expect(engine.isListening, isTrue);

      // Switch to Hindi — should stop
      await tester.tap(find.text('HI'));
      await tester.pump();

      expect(engine.log, contains('stop'));
    });
  });
}
