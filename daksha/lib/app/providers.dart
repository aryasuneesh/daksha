import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/core/constants/model.dart';
import 'package:daksha/storage/secure_key_provider.dart';
import 'package:daksha/storage/database/app_database.dart';
import 'package:daksha/inference/engine_factory.dart';
import 'package:daksha/inference/inference_engine.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/topic_classifier.dart';
import 'package:daksha/domain/socratic_tools.dart';
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
  final db = await openAppDatabase(key);
  // Close the underlying SQLite connection if the provider is ever disposed
  // (e.g. on test teardown or a future hot-restart hook). Without this the
  // file handle leaks until process exit.
  ref.onDispose(() async {
    await db.close();
  });
  return db;
});

final engineProvider = FutureProvider<InferenceEngine>((ref) async {
  final dir = await getApplicationSupportDirectory();
  // Model filename matches what ModelSetupScreen downloads:
  //   dart:io HttpClient → <app-support>/models/gemma-4-E4B-it.litertlm
  // EnginePreference.mediaPipe is used directly (no file-existence check)
  // because MediaPipeEngine.load() calls FlutterGemma.hasActiveModel() and
  // uses the registered model path, not the path passed here.  The path here
  // is only the fallback for a manual adb-push workflow without setup screen.
  final mediaPipePath = p.join(dir.path, 'models', kModelFilename);
  final llamaCppPath = p.join(dir.path, 'models', 'gemma3n-e2b-q4.gguf');
  final engine = EngineFactory.create(
    mediaPipeModelPath: mediaPipePath,
    llamaCppModelPath: llamaCppPath,
    // Force MediaPipe: skip the file-existence check so we always return a
    // MediaPipeEngine. Its load() checks hasActiveModel() internally.
    preference: EnginePreference.mediaPipe,
  );
  // Release GPU/OpenCL memory if the provider is ever disposed. Without this
  // a future invalidate() would leave ~2.26 GB of weights pinned forever.
  ref.onDispose(() async {
    await engine.dispose();
  });
  // load() initialises the flutter_gemma InferenceModel — this is where the
  // model is loaded into GPU/NPU memory. It must complete before any generate()
  // call can be made.
  await engine.load();
  return engine;
});

final taxonomyProvider = FutureProvider<List<Topic>>((ref) async {
  return TaxonomyLoader.load();
});

/// Fire-once verdict events from the tutor service.
///
/// Held in a separate provider (rather than baked into [TutorState]) because
/// pop-ups must fire on transition only. If we put the verdict in the state,
/// every rebuild after a "wrong" attempt would re-show the dialog.
///
/// The [ProblemScreen] consumer calls `state = null` after showing the
/// dialog so the value is consumed exactly once per emission.
final tutorVerdictEventProvider = StateProvider<TutorVerdictEvent?>((_) => null);

/// Tutor service — wired to real engine + db + taxonomy.
///
/// Uses [AsyncValue.requireValue] so that if any async dep is still loading
/// this provider enters an error state (instead of crashing with
/// UnimplementedError). [ProblemScreen] checks the async deps first and shows
/// a loading indicator until all three are ready.
///
/// In tests, override via ProviderScope.overrides with a fake TutorService
/// backed by a mock engine + in-memory store.
final tutorServiceProvider =
    StateNotifierProvider<TutorService, TutorState>((ref) {
  final engine = ref.watch(engineProvider).requireValue;
  final db = ref.watch(dbProvider).requireValue;
  final topics = ref.watch(taxonomyProvider).requireValue;

  return TutorService(
    classifier: TopicClassifier(engine: engine, topics: topics),
    socratic: SocraticService(engine),
    store: db,
    onVerdict: (event) {
      ref.read(tutorVerdictEventProvider.notifier).state = event;
    },
  );
});

/// Stream of all problems, most recent first.
///
/// Depends on [dbProvider] — emits nothing until the DB is ready, then
/// auto-updates on every insert/update without manual refresh.
final problemsProvider = StreamProvider<List<Problem>>((ref) async* {
  final db = await ref.watch(dbProvider.future);
  yield* db.watchAllProblems();
});

/// Stream of conversation turns for a given problem, oldest first.
///
/// Used by [ProblemScreen] to render the chat from the DB rather than from
/// in-memory tutor state — that's what allows a history → resume flow to
/// replay prior turns instead of starting from scratch.
final turnsProvider = StreamProvider.family<
    List<ConversationTurn>,
    ({AppDatabase db, String problemId})>((ref, key) {
  return key.db.watchTurns(key.problemId);
});

/// Stream of the learner's current streak in days (for the home top bar).
///
/// Mirrors [problemsProvider]'s pattern: depends on [dbProvider], emits
/// nothing until the DB is ready, then auto-updates whenever the learner
/// profile row is touched (e.g. when [TutorService] calls recordActivity).
final streakDaysProvider = StreamProvider<int>((ref) async* {
  final db = await ref.watch(dbProvider.future);
  yield* db.watchStreakDays();
});

/// Count of all problems stored so far (for the home screen badge).
final problemCountProvider = Provider<int>((ref) {
  return ref.watch(problemsProvider).whenData((list) => list.length).value ?? 0;
});

/// Parent auth service — wired to db + secure storage.
///
/// Uses [AsyncValue.requireValue] for the same loading-guard reason.
/// In tests, override via ProviderScope.overrides.
final parentAuthServiceProvider = Provider<ParentAuthService>((ref) {
  final db = ref.watch(dbProvider).requireValue;
  return ParentAuthService(
    store: db,
    secureStorage: FlutterSecureStorageAdapter(),
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
/// In tests, override via ProviderScope.overrides.
final parentServiceProvider = Provider<ParentService>((ref) {
  final engine = ref.watch(engineProvider).requireValue;
  final db = ref.watch(dbProvider).requireValue;
  return ParentService(engine: engine, store: db);
});
