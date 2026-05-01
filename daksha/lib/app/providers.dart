import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/storage/secure_key_provider.dart';
import 'package:daksha/storage/database/app_database.dart';
import 'package:daksha/inference/engine_factory.dart';
import 'package:daksha/inference/inference_engine.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/tutor_service.dart';
import 'package:daksha/domain/tutor_state.dart';
import 'package:daksha/services/parent/parent_auth_service.dart';
import 'package:daksha/services/parent/parent_service.dart';
import 'package:daksha/services/tts_service.dart';
import 'package:daksha/services/stt_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

final secureKeyProvider = FutureProvider<String>((ref) async {
  final provider = SecureKeyProvider(FlutterSecureStorageAdapter());
  return provider.getOrCreateKey();
});

final dbProvider = FutureProvider<AppDatabase>((ref) async {
  final key = await ref.watch(secureKeyProvider.future);
  return openAppDatabase(key);
});

final engineProvider = FutureProvider<InferenceEngine>((ref) async {
  final dir = await getApplicationSupportDirectory();
  final mediaPipePath = p.join(dir.path, 'models', 'gemma3n-e2b-q4.bin');
  final llamaCppPath = p.join(dir.path, 'models', 'gemma3n-e2b-q4.gguf');
  return EngineFactory.create(
    mediaPipeModelPath: mediaPipePath,
    llamaCppModelPath: llamaCppPath,
  );
});

final taxonomyProvider = FutureProvider<List<Topic>>((ref) async {
  return TaxonomyLoader.load();
});

/// Tutor service provider — wired to real deps in Task 20 for UI scaffolding.
/// Tests and the real app will override this with ProviderScope overrides.
final tutorServiceProvider =
    StateNotifierProvider<TutorService, TutorState>((ref) {
  // This throws intentionally — consume only after overriding in tests
  // or after engine/db are ready. Screens handle loading/error via ref.watch.
  throw UnimplementedError(
    'tutorServiceProvider must be overridden via ProviderScope.overrides',
  );
});

/// Parent auth service provider.
/// Must be overridden in tests and in the real app's ProviderScope.
final parentAuthServiceProvider = Provider<ParentAuthService>((ref) {
  throw UnimplementedError(
    'parentAuthServiceProvider must be overridden via ProviderScope.overrides',
  );
});

/// TTS service — uses the real flutter_tts engine on device.
final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService(FlutterTtsEngine());
});

/// STT service — uses the real speech_to_text engine on device.
final sttServiceProvider = Provider<SttService>((ref) {
  return SttService(SpeechToTextEngine());
});

/// Parent service — 2-shot PLAN+SPEAK pipeline wired to real engine + db.
/// Must be overridden in tests via ProviderScope.overrides.
final parentServiceProvider = Provider<ParentService>((ref) {
  throw UnimplementedError(
    'parentServiceProvider must be overridden via ProviderScope.overrides',
  );
});
