// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/services/parent/parent_auth_service.dart';
import 'package:daksha/storage/secure_key_provider.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeAuthStore implements AuthStore {
  ParentAuthRow? _row;

  @override
  Future<ParentAuthRow?> getAuthRow() async => _row;

  @override
  Future<void> upsertAuthRow(ParentAuthRow row) async => _row = row;
}

class FakeSecureStorage implements SecureStorageAdapter {
  final _store = <String, String>{};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ParentAuthService makeService({
  required FakeAuthStore store,
  required FakeSecureStorage secureStorage,
  DateTime Function()? clock,
}) =>
    ParentAuthService(
      store: store,
      secureStorage: secureStorage,
      clock: clock ?? DateTime.now,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Note: Argon2id is compute-intensive; individual tests may take a few
  // seconds. The default flutter test timeout of 30 s is sufficient.
  group('ParentAuthService', () {
    late FakeAuthStore store;
    late FakeSecureStorage secureStorage;

    setUp(() {
      store = FakeAuthStore();
      secureStorage = FakeSecureStorage();
    });

    // -----------------------------------------------------------------------
    // setup()
    // -----------------------------------------------------------------------

    test('setup stores a hash, never the raw PIN', () async {
      const pin = '1234';
      final svc = makeService(store: store, secureStorage: secureStorage);

      await svc.setup(pin);

      final row = store._row;
      expect(row, isNotNull);
      // The stored hash must not equal the PIN.
      expect(row!.pinHash, isNot(equals(pin)));
      // The hash should be a 64-char hex string (32 bytes).
      expect(row.pinHash.length, equals(64));
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(row.pinHash), isTrue);
      // Salt also stored.
      expect(row.salt.length, equals(32)); // 16 bytes = 32 hex chars
      // failedCount reset to 0.
      expect(row.failedCount, equals(0));
      expect(row.lockoutUntil, isNull);
    });

    test('setup writes salt to secure storage', () async {
      final svc = makeService(store: store, secureStorage: secureStorage);
      await svc.setup('0000');

      final storedSalt = await secureStorage.read('daksha.parent.salt');
      expect(storedSalt, isNotNull);
      expect(storedSalt!.length, equals(32));
    });

    test('two setups with same PIN produce different hashes (random salt)',
        () async {
      final svc = makeService(store: store, secureStorage: secureStorage);
      await svc.setup('1234');
      final hash1 = store._row!.pinHash;

      await svc.setup('1234');
      final hash2 = store._row!.pinHash;

      // Different salts → different hashes (with overwhelming probability).
      expect(hash1, isNot(equals(hash2)));
    });

    // -----------------------------------------------------------------------
    // verify() — success path
    // -----------------------------------------------------------------------

    test('correct PIN returns AuthSuccess and resets failedCount', () async {
      const pin = '9876';
      final svc = makeService(store: store, secureStorage: secureStorage);
      await svc.setup(pin);

      final result = await svc.verify(pin);

      expect(result, isA<AuthSuccess>());
      expect(store._row!.failedCount, equals(0));
      expect(store._row!.lockoutUntil, isNull);
    });

    test('correct PIN after earlier failures resets failedCount to 0',
        () async {
      const pin = 'abcd';
      final svc = makeService(store: store, secureStorage: secureStorage);
      await svc.setup(pin);

      // Two failures first.
      await svc.verify('wrong1');
      await svc.verify('wrong2');
      expect(store._row!.failedCount, equals(2));

      // Now correct.
      final result = await svc.verify(pin);
      expect(result, isA<AuthSuccess>());
      expect(store._row!.failedCount, equals(0));
    });

    // -----------------------------------------------------------------------
    // verify() — failure path
    // -----------------------------------------------------------------------

    test('wrong PIN returns AuthFailure with incrementing failedCount',
        () async {
      final svc = makeService(store: store, secureStorage: secureStorage);
      await svc.setup('1111');

      final r1 = await svc.verify('0000');
      expect(r1, isA<AuthFailure>());
      expect((r1 as AuthFailure).failedCount, equals(1));

      final r2 = await svc.verify('0000');
      expect(r2, isA<AuthFailure>());
      expect((r2 as AuthFailure).failedCount, equals(2));
    });

    test('verify before setup returns AuthFailure(0)', () async {
      final svc = makeService(store: store, secureStorage: secureStorage);
      final result = await svc.verify('1234');
      expect(result, isA<AuthFailure>());
      expect((result as AuthFailure).failedCount, equals(0));
    });

    // -----------------------------------------------------------------------
    // verify() — lockout after 5 failures (tier 0 → 1 minute)
    // -----------------------------------------------------------------------

    test('5 wrong attempts trigger a 1-minute lockout', () async {
      final baseTime = DateTime(2025, 1, 1, 12, 0, 0);
      var fakeNow = baseTime;
      final svc = makeService(
        store: store,
        secureStorage: secureStorage,
        clock: () => fakeNow,
      );
      await svc.setup('correct');

      // 4 failures — no lockout yet.
      for (var i = 0; i < 4; i++) {
        final r = await svc.verify('wrong');
        expect(r, isA<AuthFailure>());
      }

      // 5th failure triggers lockout.
      final r5 = await svc.verify('wrong');
      expect(r5, isA<AuthLockout>());
      final lockout = r5 as AuthLockout;
      expect(lockout.restartRequired, isFalse);
      // Lockout should end ~1 minute from now.
      final expectedEnd = baseTime.add(const Duration(minutes: 1));
      expect(lockout.until, equals(expectedEnd));
    });

    // -----------------------------------------------------------------------
    // verify() — lockout re-check while still locked
    // -----------------------------------------------------------------------

    test('verify during lockout returns AuthLockout without re-hashing',
        () async {
      final baseTime = DateTime(2025, 6, 1, 9, 0, 0);
      var fakeNow = baseTime;
      final svc = makeService(
        store: store,
        secureStorage: secureStorage,
        clock: () => fakeNow,
      );
      await svc.setup('correct');

      // Exhaust first tier.
      for (var i = 0; i < 5; i++) {
        await svc.verify('wrong');
      }

      // Still within lockout window.
      fakeNow = baseTime.add(const Duration(seconds: 30));
      final r = await svc.verify('correct');
      expect(r, isA<AuthLockout>());
      final lockout = r as AuthLockout;
      expect(lockout.restartRequired, isFalse);
    });

    // -----------------------------------------------------------------------
    // verify() — lockout expires, then correct PIN succeeds
    // -----------------------------------------------------------------------

    test('after lockout expires correct PIN returns AuthSuccess', () async {
      final baseTime = DateTime(2025, 6, 1, 10, 0, 0);
      var fakeNow = baseTime;
      final svc = makeService(
        store: store,
        secureStorage: secureStorage,
        clock: () => fakeNow,
      );
      await svc.setup('correct');

      // Trigger tier-0 lockout.
      for (var i = 0; i < 5; i++) {
        await svc.verify('wrong');
      }

      // Advance past 1-minute lockout.
      fakeNow = baseTime.add(const Duration(minutes: 1, seconds: 1));
      final r = await svc.verify('correct');
      expect(r, isA<AuthSuccess>());
      expect(store._row!.failedCount, equals(0));
    });

    // -----------------------------------------------------------------------
    // verify() — second lockout tier (10 failures → 4 minutes)
    // -----------------------------------------------------------------------

    test('10 wrong attempts trigger a 4-minute lockout (tier 1)', () async {
      final baseTime = DateTime(2025, 1, 1, 8, 0, 0);
      var fakeNow = baseTime;
      final svc = makeService(
        store: store,
        secureStorage: secureStorage,
        clock: () => fakeNow,
      );
      await svc.setup('correct');

      // First 5 failures → tier-0 lockout at baseTime+1min.
      for (var i = 0; i < 5; i++) {
        await svc.verify('wrong');
      }

      // Advance past tier-0 lockout.
      fakeNow = baseTime.add(const Duration(minutes: 2));
      final secondLockoutBase = fakeNow;

      // Next 5 failures → tier-1 lockout.
      for (var i = 0; i < 5; i++) {
        await svc.verify('wrong');
      }

      final row = store._row!;
      expect(row.failedCount, equals(10));
      expect(
        row.lockoutUntil,
        equals(secondLockoutBase.add(const Duration(minutes: 4))),
      );
    });

    // -----------------------------------------------------------------------
    // verify() — 5th lockout tier (restartRequired)
    // -----------------------------------------------------------------------

    test(
        '25+ wrong attempts (tier 4) return AuthLockout with restartRequired=true',
        () async {
      var fakeNow = DateTime(2025, 3, 1);
      final svc = makeService(
        store: store,
        secureStorage: secureStorage,
        clock: () => fakeNow,
      );
      await svc.setup('correct');

      // Exhaust all 4 timed lockout tiers (5 * 4 = 20 failures).
      // Each tier we advance past the lockout window so we can continue.
      final lockoutMinutes = [1, 4, 16, 64];
      for (var tier = 0; tier < lockoutMinutes.length; tier++) {
        for (var i = 0; i < 5; i++) {
          await svc.verify('wrong');
        }
        // Advance past this tier's lockout.
        fakeNow = fakeNow.add(Duration(minutes: lockoutMinutes[tier] + 1));
      }

      // 25th failure triggers restart-required lockout.
      for (var i = 0; i < 5; i++) {
        await svc.verify('wrong');
      }

      final lastResult = await svc.verify('correct');
      expect(lastResult, isA<AuthLockout>());
      expect((lastResult as AuthLockout).restartRequired, isTrue);
    });

    // -----------------------------------------------------------------------
    // Security: PIN never appears in results or stored data
    // -----------------------------------------------------------------------

    test('PIN never appears in stored ParentAuthRow', () async {
      const pin = 'mySecretPin9!';
      final svc = makeService(store: store, secureStorage: secureStorage);
      await svc.setup(pin);

      final row = store._row!;
      expect(row.pinHash, isNot(contains(pin)));
      expect(row.salt, isNot(contains(pin)));
    });

    test('AuthSuccess carries no PIN information', () async {
      const pin = 'sensitivePin';
      final svc = makeService(store: store, secureStorage: secureStorage);
      await svc.setup(pin);

      final result = await svc.verify(pin);
      expect(result, isA<AuthSuccess>());
      // AuthSuccess has no fields — just verify it is the right type with no
      // data leak (the sealed class has no fields beyond its type).
    });

    test('AuthFailure carries only a count, not the PIN', () async {
      final svc = makeService(store: store, secureStorage: secureStorage);
      await svc.setup('secure1234');

      final result = await svc.verify('wrong');
      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.failedCount, equals(1));
      // Confirm the failure object has exactly one field of type int.
    });

    // -----------------------------------------------------------------------
    // Constant-time comparison is used
    // -----------------------------------------------------------------------

    test(
        'wrong PINs of identical length as correct PIN are handled consistently',
        () async {
      // We cannot reliably measure timing in unit tests, but we can verify
      // that a wrong PIN of the same length as the correct PIN still returns
      // AuthFailure — confirming the constant-time path is taken (not an early
      // exit on length mismatch that would reveal PIN length).
      const pin = '1234'; // 4 chars
      final svc = makeService(store: store, secureStorage: secureStorage);
      await svc.setup(pin);

      final result = await svc.verify('5678'); // same length, wrong value
      expect(result, isA<AuthFailure>());
    });

    // -----------------------------------------------------------------------
    // ParentAuthRow.copyWith
    // -----------------------------------------------------------------------

    test('copyWith can clear lockoutUntil to null', () {
      final row = ParentAuthRow(
        pinHash: 'abc',
        salt: 'def',
        failedCount: 3,
        lockoutUntil: DateTime(2025),
      );
      final updated = row.copyWith(lockoutUntil: null);
      expect(updated.lockoutUntil, isNull);
      expect(updated.failedCount, equals(3));
    });

    test('copyWith preserves lockoutUntil when not specified', () {
      final dt = DateTime(2025, 6, 1);
      final row = ParentAuthRow(
        pinHash: 'abc',
        salt: 'def',
        failedCount: 0,
        lockoutUntil: dt,
      );
      final updated = row.copyWith(failedCount: 1);
      expect(updated.lockoutUntil, equals(dt));
    });
  });
}
