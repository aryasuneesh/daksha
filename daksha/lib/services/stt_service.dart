import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:daksha/features/common/language_toggle.dart';

// ---------------------------------------------------------------------------
// Engine interface — narrow surface, easy to fake in tests
// ---------------------------------------------------------------------------

abstract interface class SttEngine {
  /// Initialises the recogniser. Returns true if speech recognition is
  /// available. The [onDone] wired during [listen] is fired via status events.
  Future<bool> initialize();

  /// Start listening and call [onResult] on each final result, [onDone] when
  /// the recogniser ends the session (auto-stop or timeout).
  Future<void> listen({
    required String locale,
    required void Function(String words) onResult,
    required void Function() onDone,
  });

  Future<void> stop();

  bool get isAvailable;
  bool get isListening;
}

// ---------------------------------------------------------------------------
// Real engine backed by speech_to_text
// ---------------------------------------------------------------------------

class SpeechToTextEngine implements SttEngine {
  SpeechToTextEngine() : _stt = stt.SpeechToText();

  final stt.SpeechToText _stt;

  // Stored per-listen session; fired when the platform reports 'done'.
  void Function()? _currentOnDone;

  @override
  Future<bool> initialize() => _stt.initialize(
        onStatus: (String status) {
          if (status == 'done' || status == 'notListening') {
            _currentOnDone?.call();
            _currentOnDone = null;
          }
        },
      );

  @override
  Future<void> listen({
    required String locale,
    required void Function(String words) onResult,
    required void Function() onDone,
  }) async {
    _currentOnDone = onDone;
    await _stt.listen(
      localeId: locale,
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      listenOptions: stt.SpeechListenOptions(cancelOnError: true),
    );
  }

  @override
  Future<void> stop() => _stt.stop();

  @override
  bool get isAvailable => _stt.isAvailable;

  @override
  bool get isListening => _stt.isListening;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class SttService {
  const SttService(this._engine);

  final SttEngine _engine;

  /// Maps [AppLanguage] to a BCP-47 locale supported by Android STT.
  static String localeFor(AppLanguage lang) => switch (lang) {
        AppLanguage.en => 'en-IN',
        AppLanguage.hi => 'hi-IN',
        AppLanguage.ml => 'ml-IN',
      };

  /// Initialise the recogniser. Returns true if speech recognition is
  /// available on this device.
  Future<bool> initialize() => _engine.initialize();

  /// Start listening in [language]. Calls [onResult] with final transcriptions
  /// and [onDone] when the recogniser stops.
  Future<void> listen({
    required AppLanguage language,
    required void Function(String words) onResult,
    required void Function() onDone,
  }) =>
      _engine.listen(
        locale: localeFor(language),
        onResult: onResult,
        onDone: onDone,
      );

  /// Stop the current listening session.
  Future<void> stop() => _engine.stop();

  bool get isListening => _engine.isListening;
  bool get isAvailable => _engine.isAvailable;
}
