import 'dart:math';

abstract interface class SecureStorageAdapter {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SecureKeyProvider {
  final SecureStorageAdapter _storage;
  static const _dbKey = 'daksha.db.key';

  SecureKeyProvider(this._storage);

  Future<String> getOrCreateKey() async {
    final existing = await _storage.read(_dbKey);
    if (existing != null) return existing;
    final key = _generateKey();
    await _storage.write(_dbKey, key);
    return key;
  }

  String _generateKey() {
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
