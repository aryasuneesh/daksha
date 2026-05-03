import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:daksha/app/providers.dart';
import 'package:daksha/core/theme.dart';
import 'package:daksha/features/parent/voice_screen.dart';
import 'package:daksha/inference/inference_engine.dart';
import 'package:daksha/services/parent/parent_service.dart';
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
// Fake ParentService
// ---------------------------------------------------------------------------

class _FakeInferenceEngine implements InferenceEngine {
  final List<InferenceResponse> responses;
  int _call = 0;

  _FakeInferenceEngine(this.responses);

  @override
  Future<void> load() async {}

  @override
  Future<void> dispose() async {}

  @override
  bool get isLoaded => true;

  @override
  bool get supportsVision => false;

  @override
  Future<InferenceResponse> generate(InferenceRequest request) async {
    final r = responses[_call % responses.length];
    _call++;
    return r;
  }
}

/// An InferenceEngine whose first generate() call never completes.
class _HangingInferenceEngine implements InferenceEngine {
  final _completer = Completer<InferenceResponse>();

  @override
  Future<void> load() async {}

  @override
  Future<void> dispose() async {}

  @override
  bool get isLoaded => true;

  @override
  bool get supportsVision => false;

  @override
  Future<InferenceResponse> generate(InferenceRequest request) =>
      _completer.future;
}

class _FakeStore implements ParentQaStore {
  @override
  Future<String> insertQa({
    required String question,
    required String? plan,
    required String answer,
    required DateTime askedAt,
  }) async =>
      'fake-uuid';
}

ParentService _makeParentService({
  String plan = 'A plan.',
  String answer = 'Great progress!',
  bool failPlan = false,
  bool failSpeak = false,
}) {
  final engine = _FakeInferenceEngine([
    failPlan
        ? const InferenceFailure(error: 'plan error')
        : InferenceSuccess(text: plan),
    failSpeak
        ? const InferenceFailure(error: 'speak error')
        : InferenceSuccess(text: answer),
  ]);
  return ParentService(engine: engine, store: _FakeStore());
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

Widget _buildSubject(
  _FakeSttEngine engine, {
  ParentService? parentService,
}) {
  final fakeStt = SttService(engine);
  final ps = parentService ?? _makeParentService();
  final router = GoRouter(
    initialLocation: '/parent/voice',
    routes: [
      GoRoute(
        path: '/parent/voice',
        builder: (_, __) => VoiceScreen(
          sttForTesting: fakeStt,
          parentServiceForTesting: ps,
        ),
      ),
      GoRoute(
        path: '/parent/shell',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Shell'))),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      parentServiceProvider.overrideWithValue(ps),
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

  group('VoiceScreen — pipeline', () {
    testWidgets('shows processing indicator while ParentService is running',
        (tester) async {
      final engine = _FakeSttEngine()
        ..nextResult = 'Is the student struggling?';

      // A service backed by an engine whose generate() never completes.
      final hangingService = ParentService(
        engine: _HangingInferenceEngine(),
        store: _FakeStore(),
      );
      await tester.pumpWidget(
          _buildSubject(engine, parentService: hangingService));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('mic_button')));
      // Pump once — STT delivers synchronously, onDone fires, _submitQuestion
      // starts but the engine hangs so _isProcessing stays true.
      await tester.pump();

      expect(find.byKey(const Key('processing_indicator')), findsOneWidget);
    });

    testWidgets('shows answer after pipeline completes', (tester) async {
      final engine = _FakeSttEngine()
        ..nextResult = 'Is the student struggling?';
      final parentService = _makeParentService(answer: 'Your child is doing well!');

      await tester.pumpWidget(_buildSubject(engine, parentService: parentService));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('mic_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('answer_text')), findsOneWidget);
      expect(find.text('Your child is doing well!'), findsOneWidget);
    });

    testWidgets('shows error when pipeline fails', (tester) async {
      final engine = _FakeSttEngine()
        ..nextResult = 'How is she doing?';
      final parentService = _makeParentService(failPlan: true);

      await tester.pumpWidget(_buildSubject(engine, parentService: parentService));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('mic_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('error_text')), findsOneWidget);
    });

    testWidgets('tapping mic again clears previous answer', (tester) async {
      final engine = _FakeSttEngine()
        ..nextResult = 'How is she doing?';
      final parentService = _makeParentService(answer: 'She is great!');

      await tester.pumpWidget(_buildSubject(engine, parentService: parentService));
      await tester.pumpAndSettle();

      // First question — get an answer on screen
      await tester.tap(find.byKey(const Key('mic_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('answer_text')), findsOneWidget);

      // Second tap — clear nextResult so STT hangs (no auto-done)
      engine.nextResult = null;
      await tester.tap(find.byKey(const Key('mic_button')));
      await tester.pump(); // starts listening, sets _answer = null

      // Previous answer should be cleared as soon as listening starts
      expect(find.byKey(const Key('answer_text')), findsNothing);
      expect(find.byKey(const Key('waveform')), findsOneWidget);
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
