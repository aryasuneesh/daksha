import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daksha/storage/secure_key_provider.dart';

class MockSecureStorageAdapter extends Mock implements SecureStorageAdapter {}

void main() {
  group('SecureKeyProvider', () {
    late MockSecureStorageAdapter mockStorage;
    late SecureKeyProvider provider;

    setUp(() {
      mockStorage = MockSecureStorageAdapter();
      provider = SecureKeyProvider(mockStorage);
    });

    test('generates 64-char hex key when storage is empty', () async {
      when(() => mockStorage.read('daksha.db.key')).thenAnswer((_) async => null);
      when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});

      final key = await provider.getOrCreateKey();

      expect(key, hasLength(64));
      expect(
        key,
        matches(RegExp(r'^[0-9a-f]{64}$')),
        reason: 'Key must be exactly 64 hex characters',
      );
      verify(() => mockStorage.write('daksha.db.key', key)).called(1);
    });

    test('returns existing key without writing', () async {
      const existingKey = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      when(() => mockStorage.read('daksha.db.key'))
          .thenAnswer((_) async => existingKey);

      final key = await provider.getOrCreateKey();

      expect(key, existingKey);
      verifyNever(() => mockStorage.write(any(), any()));
    });

    test('generated keys are random (different each time)', () async {
      when(() => mockStorage.read('daksha.db.key')).thenAnswer((_) async => null);
      when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});

      final provider1 = SecureKeyProvider(mockStorage);
      final key1 = await provider1.getOrCreateKey();

      // Reset mock for second call
      mockStorage = MockSecureStorageAdapter();
      when(() => mockStorage.read('daksha.db.key')).thenAnswer((_) async => null);
      when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});

      final provider2 = SecureKeyProvider(mockStorage);
      final key2 = await provider2.getOrCreateKey();

      expect(key1, isNotEmpty);
      expect(key2, isNotEmpty);
      expect(key1, isNot(key2));
    });
  });
}
