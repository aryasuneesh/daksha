import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureStorageAdapter {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SecureKeyProvider {
  final SecureStorageAdapter _storage;
  static const _dbKey = 'daksha.db.key';
  static final _random = Random.secure();

  SecureKeyProvider(this._storage);

  Future<String> getOrCreateKey() async {
    final existing = await _storage.read(_dbKey);
    if (existing != null) return existing;
    final key = _generateKey();
    await _storage.write(_dbKey, key);
    return key;
  }

  String _generateKey() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

class FlutterSecureStorageAdapter implements SecureStorageAdapter {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}
