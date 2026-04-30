import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/storage/secure_key_provider.dart';
import 'package:daksha/storage/database/app_database.dart';
import 'package:daksha/inference/engine_factory.dart';
import 'package:daksha/inference/inference_engine.dart';
import 'package:daksha/domain/taxonomy.dart';
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
