import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flutter_gemma so its SQLite model registry is loaded before
  // we check whether the active model has already been downloaded.
  await FlutterGemma.initialize();

  final needsSetup = !FlutterGemma.hasActiveModel();

  runApp(ProviderScope(child: DakshaApp(needsSetup: needsSetup)));
}
