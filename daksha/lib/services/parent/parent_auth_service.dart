import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:daksha/storage/secure_key_provider.dart';

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

/// The result of a PIN verification attempt.
sealed class AuthResult {
  const AuthResult();
}

/// PIN was correct and authentication succeeded.
class AuthSuccess extends AuthResult {
  const AuthSuccess();
}

/// PIN was incorrect; [failedCount] is the new cumulative count.
class AuthFailure extends AuthResult {
  final int failedCount;
  const AuthFailure(this.failedCount);
}

/// Too many failures; lockout ends at [until].
/// If [restartRequired] is true, the user must force-quit and restart.
class AuthLockout extends AuthResult {
  final DateTime until;
  final bool restartRequired;
  const AuthLockout({required this.until, required this.restartRequired});
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

// Sentinel object used by copyWith to distinguish "set to null" from "keep
// existing".
const _keepExisting = Object();

/// Plain data holder — no PIN field ever appears here.
class ParentAuthRow {
  final String pinHash; // hex-encoded Argon2id output
  final String salt; // hex-encoded 16-byte random salt
  final int failedCount;
  final DateTime? lockoutUntil;

  const ParentAuthRow({
    required this.pinHash,
    required this.salt,
    required this.failedCount,
    this.lockoutUntil,
  });

  ParentAuthRow copyWith({
    String? pinHash,
    String? salt,
    int? failedCount,
    // Use the sentinel to keep the existing value; pass null explicitly to
    // clear lockoutUntil.
    Object? lockoutUntil = _keepExisting,
  }) {
    return ParentAuthRow(
      pinHash: pinHash ?? this.pinHash,
      salt: salt ?? this.salt,
      failedCount: failedCount ?? this.failedCount,
      lockoutUntil: identical(lockoutUntil, _keepExisting)
          ? this.lockoutUntil
          : lockoutUntil as DateTime?,
    );
  }
}

// ---------------------------------------------------------------------------
// Storage interface
// ---------------------------------------------------------------------------

abstract interface class AuthStore {
  Future<ParentAuthRow?> getAuthRow();
  Future<void> upsertAuthRow(ParentAuthRow row);
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class ParentAuthService {
  final AuthStore _store;
  final SecureStorageAdapter _secureStorage;
  final DateTime Function() _clock;

  static const _saltKey = 'daksha.parent.salt';
  static const _maxFailures = 5;

  // Lockout durations in minutes per lockout tier.
  // Tier 0 (after 5 failures) → 1 min
  // Tier 1 (after 10 failures) → 4 min
  // Tier 2 (after 15 failures) → 16 min
  // Tier 3 (after 20 failures) → 64 min
  // Tier 4+ (after 25+ failures) → restart required
  static const _lockoutMinutes = [1, 4, 16, 64];

  static final _random = Random.secure();

  static DateTime _defaultClock() => DateTime.now();

  ParentAuthService({
    required AuthStore store,
    required SecureStorageAdapter secureStorage,
    DateTime Function() clock = _defaultClock,
  })  : _store = store,
        _secureStorage = secureStorage,
        _clock = clock;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Sets up the parent PIN for the first time (or resets it).
  ///
  /// The PIN is **never** stored or returned; only its Argon2id hash is
  /// persisted.
  Future<void> setup(String pin) async {
    final salt = _generateSalt(16);
    final hash = await _hashPin(pin, salt);
    final saltHex = _toHex(salt);
    await _secureStorage.write(_saltKey, saltHex);
    await _store.upsertAuthRow(
      ParentAuthRow(
        pinHash: _toHex(hash),
        salt: saltHex,
        failedCount: 0,
        lockoutUntil: null,
      ),
    );
    // PIN never logged or returned.
  }

  /// Verifies the PIN. Returns [AuthSuccess], [AuthFailure], or [AuthLockout].
  Future<AuthResult> verify(String pin) async {
    final row = await _store.getAuthRow();
    if (row == null) return const AuthFailure(0); // not set up yet

    final now = _clock();

    // Check active lockout.
    if (row.lockoutUntil != null && row.lockoutUntil!.isAfter(now)) {
      final tier = (row.failedCount ~/ _maxFailures) - 1;
      return AuthLockout(
        until: row.lockoutUntil!,
        restartRequired: tier >= _lockoutMinutes.length,
      );
    }

    // Read salt from secure storage (authoritative) with DB fallback
    final storedSaltHex = await _secureStorage.read(_saltKey) ?? row.salt;
    final saltBytes = _fromHex(storedSaltHex);
    final hash = await _hashPin(pin, saltBytes);
    final correct = _constantTimeEquals(_toHex(hash), row.pinHash);

    if (correct) {
      await _store.upsertAuthRow(
        row.copyWith(failedCount: 0, lockoutUntil: null),
      );
      return const AuthSuccess();
    }

    final newFailed = row.failedCount + 1;
    DateTime? newLockout;
    bool restartRequired = false;

    if (newFailed % _maxFailures == 0) {
      final tier = (newFailed ~/ _maxFailures) - 1;
      if (tier >= _lockoutMinutes.length) {
        restartRequired = true;
        // Effectively permanent — requires app restart to clear.
        newLockout = now.add(const Duration(days: 3650));
      } else {
        newLockout = now.add(Duration(minutes: _lockoutMinutes[tier]));
      }
    }

    await _store.upsertAuthRow(
      row.copyWith(
        failedCount: newFailed,
        lockoutUntil: newLockout ?? _keepExisting,
      ),
    );

    if (newLockout != null) {
      return AuthLockout(until: newLockout, restartRequired: restartRequired);
    }
    return AuthFailure(newFailed);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<List<int>> _hashPin(String pin, List<int> salt) async {
    final argon2 = Argon2id(
      memory: 19456,
      parallelism: 1,
      iterations: 2,
      hashLength: 32,
    );
    final secretKey = SecretKey(utf8.encode(pin));
    final result = await argon2.deriveKey(secretKey: secretKey, nonce: salt);
    return result.extractBytes();
  }

  List<int> _generateSalt(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));

  static String _toHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static List<int> _fromHex(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  /// Constant-time string comparison to prevent timing attacks.
  static bool _constantTimeEquals(String a, String b) {
    final len = a.length > b.length ? a.length : b.length;
    var diff = a.length ^ b.length;
    for (var i = 0; i < len; i++) {
      final ca = i < a.length ? a.codeUnitAt(i) : 0;
      final cb = i < b.length ? b.codeUnitAt(i) : 0;
      diff |= ca ^ cb;
    }
    return diff == 0;
  }
}
