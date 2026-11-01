import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small interface so the PIN logic can be tested without a phone.
abstract class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Real store. Uses Android Keystore-backed encrypted storage.
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore() : _storage = const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
