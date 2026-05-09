import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/l10n/app_localizations.dart';
import 'package:daksha/core/theme.dart';
import 'package:daksha/app/locale_provider.dart';
import 'package:daksha/app/router.dart';

class DakshaApp extends ConsumerWidget {
  const DakshaApp({super.key, required this.initialLocation});

  /// Starting route picked by main() based on (modelPresent, localePicked).
  final String initialLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    // AnnotatedRegion sets dark status-bar icons (correct for the light Warm
    // Desk theme) without needing an AppBar to own the overlay style.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light, // iOS
      ),
      child: MaterialApp.router(
        title: 'Daksha',
        debugShowCheckedModeBanner: false,
        theme: buildDakshaTheme(),
        // null → MaterialApp falls back to device locale. Once the user picks
        // a language in /setup/language or Settings the notifier emits a
        // concrete Locale and the whole tree rebuilds in the new language.
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: createRouter(initialLocation: initialLocation),
      ),
    );
  }
}
