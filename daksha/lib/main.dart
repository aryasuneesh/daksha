import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'app/app.dart';

// The model filename must match what ModelSetupScreen downloads.
const _kModelFilename = 'gemma-4-E4B-it.litertlm';

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
    final modelFile = File(p.join(dir.path, 'models', _kModelFilename));
    if (await modelFile.exists()) {
      // fromFile() only writes the path to SharedPreferences — no copy.
      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      ).fromFile(modelFile.path).install();
    }
  }

  final needsSetup = !FlutterGemma.hasActiveModel();

  runApp(ProviderScope(child: DakshaApp(needsSetup: needsSetup)));
}
