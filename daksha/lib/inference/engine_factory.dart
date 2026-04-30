import 'dart:io';
import 'inference_engine.dart';
import 'mediapipe_engine.dart';
import 'llama_cpp_engine.dart';

enum EnginePreference { mediaPipe, llamaCpp, auto }

class EngineFactory {
  /// Returns an [InferenceEngine] instance based on [preference] and model
  /// file existence.
  ///
  /// [preference] == [EnginePreference.auto]:
  ///   - If [mediaPipeModelPath] file exists → returns MediaPipeEngine
  ///   - Else if [llamaCppModelPath] file exists → returns LlamaCppEngine
  ///   - Else throws [StateError] with message 'No model file found'
  ///
  /// [preference] == [EnginePreference.mediaPipe]:
  ///   - Returns MediaPipeEngine regardless of file existence
  ///   (caller must ensure the file is present before calling load())
  ///
  /// [preference] == [EnginePreference.llamaCpp]:
  ///   - Returns LlamaCppEngine regardless of file existence
  static InferenceEngine create({
    required String mediaPipeModelPath,
    required String llamaCppModelPath,
    EnginePreference preference = EnginePreference.auto,
  }) {
    switch (preference) {
      case EnginePreference.mediaPipe:
        return MediaPipeEngine(modelPath: mediaPipeModelPath);
      case EnginePreference.llamaCpp:
        return LlamaCppEngine(modelPath: llamaCppModelPath);
      case EnginePreference.auto:
        if (File(mediaPipeModelPath).existsSync()) {
          return MediaPipeEngine(modelPath: mediaPipeModelPath);
        }
        if (File(llamaCppModelPath).existsSync()) {
          return LlamaCppEngine(modelPath: llamaCppModelPath);
        }
        throw StateError('No model file found');
    }
  }
}
