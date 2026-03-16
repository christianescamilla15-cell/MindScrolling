import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] for sensitive key/value pairs
/// such as device identifiers or access tokens.
///
/// Usage:
/// ```dart
/// final secure = SecureStorageService();
/// await secure.write('token', value);
/// final token = await secure.read('token');
/// ```
class SecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  final FlutterSecureStorage _storage;

  // ------------------------------------------------------------------
  // Write
  // ------------------------------------------------------------------

  /// Writes [value] for [key] to secure storage.
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // ------------------------------------------------------------------
  // Read
  // ------------------------------------------------------------------

  /// Returns the value stored under [key], or `null` if it does not exist.
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  // ------------------------------------------------------------------
  // Delete
  // ------------------------------------------------------------------

  /// Removes the entry for [key] from secure storage.
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Removes all entries managed by this service.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // ------------------------------------------------------------------
  // Utility
  // ------------------------------------------------------------------

  /// Returns `true` if [key] exists in secure storage.
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }
}
