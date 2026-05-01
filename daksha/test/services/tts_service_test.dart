import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/features/common/language_toggle.dart';
import 'package:daksha/services/tts_service.dart';

// ---------------------------------------------------------------------------
// Fake engine — records every call for assertion
// ---------------------------------------------------------------------------

class _FakeTtsEngine implements TtsEngine {
  final List<String> log = [];
  String? lastLocale;
  double? lastRate;
  String? lastText;
  bool stopped = false;

  @override
  Future<void> setLanguage(String locale) async {
    log.add('setLanguage:$locale');
    lastLocale = locale;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    log.add('setSpeechRate:$rate');
    lastRate = rate;
  }

  @override
  Future<void> speak(String text) async {
    log.add('speak:$text');
    lastText = text;
  }

  @override
  Future<void> stop() async {
    log.add('stop');
    stopped = true;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TtsService.localeFor', () {
    test('en maps to en-IN', () {
      expect(TtsService.localeFor(AppLanguage.en), 'en-IN');
    });

    test('hi maps to hi-IN', () {
      expect(TtsService.localeFor(AppLanguage.hi), 'hi-IN');
    });

    test('ml maps to ml-IN', () {
      expect(TtsService.localeFor(AppLanguage.ml), 'ml-IN');
    });
  });

  group('TtsService.speak', () {
    late _FakeTtsEngine engine;
    late TtsService svc;

    setUp(() {
      engine = _FakeTtsEngine();
      svc = TtsService(engine);
    });

    test('calls setLanguage, setSpeechRate, speak in order', () async {
      await svc.speak('Hello', AppLanguage.en);

      expect(engine.log, [
        'setLanguage:en-IN',
        'setSpeechRate:0.5',
        'speak:Hello',
      ]);
    });

    test('uses hi-IN locale for Hindi', () async {
      await svc.speak('नमस्ते', AppLanguage.hi);
      expect(engine.lastLocale, 'hi-IN');
      expect(engine.lastText, 'नमस्ते');
    });

    test('uses ml-IN locale for Malayalam', () async {
      await svc.speak('ഹലോ', AppLanguage.ml);
      expect(engine.lastLocale, 'ml-IN');
      expect(engine.lastText, 'ഹലോ');
    });

    test('speech rate is always 0.5', () async {
      await svc.speak('Test', AppLanguage.en);
      expect(engine.lastRate, 0.5);
    });
  });

  group('TtsService.stop', () {
    test('delegates to engine.stop', () async {
      final engine = _FakeTtsEngine();
      final svc = TtsService(engine);

      await svc.stop();

      expect(engine.stopped, isTrue);
      expect(engine.log, ['stop']);
    });
  });
}
