import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/storage/secure_key_provider.dart';

/// Secure-storage key for the user-selected app locale.
/// Stored as a language code: 'en' | 'hi' | 'ml'.
const String kLocaleStorageKey = 'daksha.locale';

/// Locales the app ships translations for. Keep in sync with the ARB files
/// under lib/l10n and with [AppLocalizations.supportedLocales].
const supportedLanguageCodes = <String>['en', 'hi', 'ml'];

/// State: a [Locale] when the user has explicitly picked one, or null when
/// they haven't yet (first launch). Null causes [MaterialApp] to fall back
/// to the device locale and signals the router to show the language picker.
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._storage, Locale? initial) : super(initial);

  final SecureStorageAdapter _storage;

  Future<void> setLocale(Locale locale) async {
    if (!supportedLanguageCodes.contains(locale.languageCode)) return;
    await _storage.write(kLocaleStorageKey, locale.languageCode);
    state = locale;
  }

  Future<void> clear() async {
    await _storage.write(kLocaleStorageKey, '');
    state = null;
  }
}

/// Reads the persisted locale once at startup. Call this in main() before
/// building the [ProviderScope] so [MaterialApp] gets a non-flicker locale
/// on the very first frame.
Future<Locale?> readPersistedLocale(SecureStorageAdapter storage) async {
  final raw = await storage.read(kLocaleStorageKey);
  if (raw == null || raw.isEmpty) return null;
  if (!supportedLanguageCodes.contains(raw)) return null;
  return Locale(raw);
}

/// Seed override target — main() overrides this with the value read from
/// secure storage so the notifier opens with the persisted locale instead
/// of needing an async fetch on first build.
final initialLocaleProvider = Provider<Locale?>((ref) => null);

/// Storage adapter override target — overridden in tests with a fake; in
/// production points at FlutterSecureStorageAdapter.
final localeStorageProvider = Provider<SecureStorageAdapter>(
  (ref) => FlutterSecureStorageAdapter(),
);

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final storage = ref.watch(localeStorageProvider);
  final initial = ref.watch(initialLocaleProvider);
  return LocaleNotifier(storage, initial);
});

// ── Onboarding walkthrough flag ──────────────────────────────────────────────
//
// Versioned key so future tour revisions can re-trigger by bumping the
// suffix. Presence of a non-empty value means "completed"; empty/missing
// means "show tour on next home visit." We piggyback on the same secure
// storage adapter used for locale to avoid a second initialisation path.

const String kOnboardingStorageKey = 'daksha.onboarding.completed.v1';

class OnboardingFlagNotifier extends StateNotifier<bool> {
  OnboardingFlagNotifier(this._storage, bool initial) : super(initial);

  final SecureStorageAdapter _storage;

  Future<void> markComplete() async {
    await _storage.write(kOnboardingStorageKey, '1');
    state = true;
  }

  Future<void> reset() async {
    await _storage.write(kOnboardingStorageKey, '');
    state = false;
  }
}

/// Reads the persisted onboarding flag once at startup. Mirrors
/// [readPersistedLocale] so main() can seed the provider before runApp.
Future<bool> readPersistedOnboardingComplete(
    SecureStorageAdapter storage) async {
  final raw = await storage.read(kOnboardingStorageKey);
  return raw != null && raw.isNotEmpty;
}

/// Seed override target — main() overrides this with the value read from
/// secure storage so the notifier opens with the persisted flag.
final initialOnboardingCompleteProvider = Provider<bool>((ref) => false);

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingFlagNotifier, bool>((ref) {
  final storage = ref.watch(localeStorageProvider);
  final initial = ref.watch(initialOnboardingCompleteProvider);
  return OnboardingFlagNotifier(storage, initial);
});
