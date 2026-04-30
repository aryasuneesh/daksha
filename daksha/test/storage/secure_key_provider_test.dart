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
      final storage1 = MockSecureStorageAdapter();
      when(() => storage1.read(any())).thenAnswer((_) async => null);
      when(() => storage1.write(any(), any())).thenAnswer((_) async {});

      final storage2 = MockSecureStorageAdapter();
      when(() => storage2.read(any())).thenAnswer((_) async => null);
      when(() => storage2.write(any(), any())).thenAnswer((_) async {});

      final key1 = await SecureKeyProvider(storage1).getOrCreateKey();
      final key2 = await SecureKeyProvider(storage2).getOrCreateKey();

      expect(key1, isNot(key2));
    });
  });
}
