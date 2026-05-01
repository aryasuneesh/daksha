import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/features/common/language_toggle.dart';
import 'package:daksha/services/stt_service.dart';

// ---------------------------------------------------------------------------
// Fake engine
// ---------------------------------------------------------------------------

class _FakeSttEngine implements SttEngine {
  final List<String> log = [];
  bool _available = true;
  bool _listening = false;

  // Configurable: if set, onResult will be called with this value on listen()
  String? nextResult;
  bool nextInitResult = true;

  void setAvailable(bool v) => _available = v;

  @override
  Future<bool> initialize() async {
    log.add('initialize');
    return nextInitResult;
  }

  @override
  Future<void> listen({
    required String locale,
    required void Function(String words) onResult,
    required void Function() onDone,
  }) async {
    log.add('listen:$locale');
    _listening = true;
    if (nextResult != null) {
      onResult(nextResult!);
    }
  }

  @override
  Future<void> stop() async {
    log.add('stop');
    _listening = false;
  }

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _listening;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SttService.localeFor', () {
    test('en maps to en-IN', () {
      expect(SttService.localeFor(AppLanguage.en), 'en-IN');
    });

    test('hi maps to hi-IN', () {
      expect(SttService.localeFor(AppLanguage.hi), 'hi-IN');
    });

    test('ml maps to ml-IN', () {
      expect(SttService.localeFor(AppLanguage.ml), 'ml-IN');
    });
  });

  group('SttService.initialize', () {
    test('delegates to engine.initialize', () async {
      final engine = _FakeSttEngine();
      final svc = SttService(engine);

      final result = await svc.initialize();

      expect(result, isTrue);
      expect(engine.log, ['initialize']);
    });

    test('returns false when engine not available', () async {
      final engine = _FakeSttEngine()..nextInitResult = false;
      final svc = SttService(engine);

      final result = await svc.initialize();

      expect(result, isFalse);
    });
  });

  group('SttService.listen', () {
    late _FakeSttEngine engine;
    late SttService svc;

    setUp(() {
      engine = _FakeSttEngine();
      svc = SttService(engine);
    });

    test('calls engine.listen with correct locale for en', () async {
      await svc.listen(
        language: AppLanguage.en,
        onResult: (_) {},
        onDone: () {},
      );
      expect(engine.log, contains('listen:en-IN'));
    });

    test('calls engine.listen with correct locale for hi', () async {
      await svc.listen(
        language: AppLanguage.hi,
        onResult: (_) {},
        onDone: () {},
      );
      expect(engine.log, contains('listen:hi-IN'));
    });

    test('calls engine.listen with correct locale for ml', () async {
      await svc.listen(
        language: AppLanguage.ml,
        onResult: (_) {},
        onDone: () {},
      );
      expect(engine.log, contains('listen:ml-IN'));
    });

    test('onResult callback receives transcription from engine', () async {
      engine.nextResult = 'How is the student doing?';
      String? received;
      await svc.listen(
        language: AppLanguage.en,
        onResult: (w) => received = w,
        onDone: () {},
      );
      expect(received, 'How is the student doing?');
    });
  });

  group('SttService.stop', () {
    test('delegates to engine.stop', () async {
      final engine = _FakeSttEngine();
      final svc = SttService(engine);

      await svc.stop();

      expect(engine.log, ['stop']);
    });
  });

  group('SttService.isListening', () {
    test('mirrors engine.isListening', () async {
      final engine = _FakeSttEngine();
      final svc = SttService(engine);

      expect(svc.isListening, isFalse);
      await svc.listen(language: AppLanguage.en, onResult: (_) {}, onDone: () {});
      expect(svc.isListening, isTrue);
      await svc.stop();
      expect(svc.isListening, isFalse);
    });
  });
}
