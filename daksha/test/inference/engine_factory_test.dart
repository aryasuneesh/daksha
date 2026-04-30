import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/inference/engine_factory.dart';
import 'package:daksha/inference/mediapipe_engine.dart';
import 'package:daksha/inference/llama_cpp_engine.dart';

void main() {
  group('EngineFactory', () {
    test('explicit mediaPipe preference returns MediaPipeEngine', () {
      final engine = EngineFactory.create(
        mediaPipeModelPath: '/path/to/mediapipe.tflite',
        llamaCppModelPath: '/path/to/llama.gguf',
        preference: EnginePreference.mediaPipe,
      );

      expect(engine, isA<MediaPipeEngine>());
    });

    test('explicit llamaCpp preference returns LlamaCppEngine', () {
      final engine = EngineFactory.create(
        mediaPipeModelPath: '/path/to/mediapipe.tflite',
        llamaCppModelPath: '/path/to/llama.gguf',
        preference: EnginePreference.llamaCpp,
      );

      expect(engine, isA<LlamaCppEngine>());
    });

    test('auto mode with only mediaPipe file present returns MediaPipeEngine',
        () async {
      final tempDir = await Directory.systemTemp.createTemp();
      try {
        final mediaPipeFile =
            File('${tempDir.path}/mediapipe.tflite');
        await mediaPipeFile.create();

        final engine = EngineFactory.create(
          mediaPipeModelPath: mediaPipeFile.path,
          llamaCppModelPath: '${tempDir.path}/nonexistent.gguf',
          preference: EnginePreference.auto,
        );

        expect(engine, isA<MediaPipeEngine>());
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('auto mode with only llamaCpp file present returns LlamaCppEngine',
        () async {
      final tempDir = await Directory.systemTemp.createTemp();
      try {
        final llamaCppFile = File('${tempDir.path}/llama.gguf');
        await llamaCppFile.create();

        final engine = EngineFactory.create(
          mediaPipeModelPath: '${tempDir.path}/nonexistent.tflite',
          llamaCppModelPath: llamaCppFile.path,
          preference: EnginePreference.auto,
        );

        expect(engine, isA<LlamaCppEngine>());
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('auto mode with no files present throws StateError', () {
      expect(
        () => EngineFactory.create(
          mediaPipeModelPath: '/nonexistent/mediapipe.tflite',
          llamaCppModelPath: '/nonexistent/llama.gguf',
          preference: EnginePreference.auto,
        ),
        throwsA(isA<StateError>()
            .having((e) => e.message, 'message', 'No model file found')),
      );
    });

    test('auto mode with both files present prefers MediaPipeEngine', () async {
      final tempDir = await Directory.systemTemp.createTemp();
      try {
        final mediaPipeFile =
            File('${tempDir.path}/mediapipe.tflite');
        final llamaCppFile = File('${tempDir.path}/llama.gguf');

        await mediaPipeFile.create();
        await llamaCppFile.create();

        final engine = EngineFactory.create(
          mediaPipeModelPath: mediaPipeFile.path,
          llamaCppModelPath: llamaCppFile.path,
          preference: EnginePreference.auto,
        );

        expect(engine, isA<MediaPipeEngine>());
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });
}
