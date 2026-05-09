import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'app/app.dart';
import 'app/locale_provider.dart';
import 'core/constants/model.dart';
import 'storage/secure_key_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flutter_gemma so its SharedPreferences model registry is
  // loaded before we check whether the active model has been registered.
  await FlutterGemma.initialize();

  // Auto-recover registration when the model file is still on disk but the
  // SharedPreferences registry was wiped (e.g. APK reinstalled with a
  // different signing config between debug / profile / release builds, or
  // the user cleared app data without deleting the internal-storage models
  // directory).  Without this, the user would be forced to re-download the
  // full 3.65 GB model every time they switch build types.
  if (!FlutterGemma.hasActiveModel()) {
    final dir = await getApplicationSupportDirectory();
    final modelFile = File(p.join(dir.path, 'models', kModelFilename));
    if (await modelFile.exists()) {
      final fileSize = await modelFile.length();
      // A file smaller than [kModelMinValidBytes] is a partial download from a
      // previous failed attempt (e.g. WorkManager timeout at 33%). Registering
      // a truncated file causes MediaPipe to throw "Model may be invalid" at
      // engine load time. Delete the partial file so ModelSetupScreen shows
      // the download flow instead of silently bypassing it with a broken
      // registration.
      if (fileSize >= kModelMinValidBytes) {
        // fromFile() only writes the path to SharedPreferences — no copy.
        await FlutterGemma.installModel(
          modelType: ModelType.gemma4,
          fileType: ModelFileType.litertlm,
        ).fromFile(modelFile.path).install();
      } else {
        // Partial/corrupt file — remove it so the user sees the setup screen
        // and can start a clean download via dart:io HttpClient.
        await modelFile.delete();
      }
    }
  }

  final hasModel = FlutterGemma.hasActiveModel();

  // Read the persisted locale BEFORE building MaterialApp so the first frame
  // renders in the correct language (no flash of English on Hindi/Malayalam
  // installs). MaterialApp needs `locale:` at construction; we cannot defer
  // this to an async provider without a flicker.
  final storage = FlutterSecureStorageAdapter();
  final initialLocale = await readPersistedLocale(storage);
  final initialOnboardingComplete =
      await readPersistedOnboardingComplete(storage);

  // Three startup states the router cares about:
  //   1. no model      → /setup            (download)
  //   2. model + no locale → /setup/language (first-launch picker)
  //   3. model + locale    → /                (normal home)
  final String startLocation;
  if (!hasModel) {
    startLocation = '/setup';
  } else if (initialLocale == null) {
    startLocation = '/setup/language';
  } else {
    startLocation = '/';
  }

  runApp(
    ProviderScope(
      overrides: [
        initialLocaleProvider.overrideWithValue(initialLocale),
        initialOnboardingCompleteProvider
            .overrideWithValue(initialOnboardingComplete),
        localeStorageProvider.overrideWithValue(storage),
      ],
      child: DakshaApp(initialLocation: startLocation),
    ),
  );
}
