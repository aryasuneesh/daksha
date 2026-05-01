import 'package:flutter_tts/flutter_tts.dart';
import 'package:daksha/features/common/language_toggle.dart';

// ---------------------------------------------------------------------------
// Engine interface — narrow surface, easy to fake in tests
// ---------------------------------------------------------------------------

abstract interface class TtsEngine {
  Future<void> setLanguage(String locale);
  Future<void> setSpeechRate(double rate);
  Future<void> speak(String text);
  Future<void> stop();
}

// ---------------------------------------------------------------------------
// Real engine backed by flutter_tts
// ---------------------------------------------------------------------------

class FlutterTtsEngine implements TtsEngine {
  FlutterTtsEngine() : _tts = FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> setLanguage(String locale) => _tts.setLanguage(locale);

  @override
  Future<void> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  @override
  Future<void> speak(String text) => _tts.speak(text);

  @override
  Future<void> stop() => _tts.stop();
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class TtsService {
  const TtsService(this._engine);

  final TtsEngine _engine;

  /// Maps [AppLanguage] to a BCP-47 locale code supported by Android TTS.
  static String localeFor(AppLanguage lang) => switch (lang) {
        AppLanguage.en => 'en-IN',
        AppLanguage.hi => 'hi-IN',
        AppLanguage.ml => 'ml-IN',
      };

  /// Speak [text] in the locale that corresponds to [lang].
  ///
  /// Sets language and a comfortable speech rate before speaking.
  Future<void> speak(String text, AppLanguage lang) async {
    await _engine.setLanguage(localeFor(lang));
    await _engine.setSpeechRate(0.5);
    await _engine.speak(text);
  }

  /// Stop any ongoing speech.
  Future<void> stop() => _engine.stop();
}
