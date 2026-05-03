import 'package:freezed_annotation/freezed_annotation.dart';

part 'inference_engine.freezed.dart';
part 'inference_engine.g.dart';

// ── Request ──────────────────────────────────────────────────────────────────

@freezed
sealed class InferenceRequest with _$InferenceRequest {
  const factory InferenceRequest({
    required String prompt,
    @Default(512) int maxTokens,
    @Default(0.7) double temperature,
    String? grammarBnf, // optional GBNF grammar for constrained output
    String? imagePath, // optional image file path for vision-capable models
  }) = _InferenceRequest;

  factory InferenceRequest.fromJson(Map<String, dynamic> json) =>
      _$InferenceRequestFromJson(json);
}

// ── Response ─────────────────────────────────────────────────────────────────

@freezed
class InferenceResponse with _$InferenceResponse {
  const factory InferenceResponse.success({
    required String text,
    @Default(0) int tokensGenerated,
  }) = InferenceSuccess;

  const factory InferenceResponse.failure({
    required String error,
  }) = InferenceFailure;
}

// ── Engine interface ──────────────────────────────────────────────────────────

abstract interface class InferenceEngine {
  /// Loads the model. Must be called before [generate].
  Future<void> load();

  /// Generates a response. [request.grammarBnf] and [request.imagePath] may
  /// be null.
  Future<InferenceResponse> generate(InferenceRequest request);

  /// Releases resources.
  Future<void> dispose();

  /// Returns true if [load] completed successfully.
  bool get isLoaded;

  /// Returns true if this engine can process image inputs via
  /// [InferenceRequest.imagePath].  Defaults to false for text-only backends.
  bool get supportsVision;
}
