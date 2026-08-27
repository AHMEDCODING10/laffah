import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';

  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // ─── Token ───
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: 'sanctum_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey) ??
        await _storage.read(key: 'sanctum_token');
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: 'sanctum_token');
  }

  // ─── Role ───
  Future<void> saveRole(String role) =>
      _storage.write(key: _roleKey, value: role);

  Future<String?> getRole() => _storage.read(key: _roleKey);

  Future<void> clearRole() => _storage.delete(key: _roleKey);

  // ─── User ID ───
  Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  // ─── Session ───
  Future<bool> hasActiveSession() async =>
      await _storage.read(key: _tokenKey) != null;

  Future<void> clearAll() => _storage.deleteAll();
}
