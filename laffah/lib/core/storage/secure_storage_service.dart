import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';

  final SharedPreferences _storage;

  SecureStorageService(this._storage);

  // ─── Token ───
  Future<void> saveToken(String token) async {
    await _storage.setString(_tokenKey, token);
    await _storage.setString('sanctum_token', token);
  }

  Future<String?> getToken() async {
    return _storage.getString(_tokenKey) ??
        _storage.getString('sanctum_token');
  }

  Future<void> clearToken() async {
    await _storage.remove(_tokenKey);
    await _storage.remove('sanctum_token');
  }

  // ─── Role ───
  Future<void> saveRole(String role) async =>
      await _storage.setString(_roleKey, role);

  Future<String?> getRole() async => _storage.getString(_roleKey);

  Future<void> clearRole() async => await _storage.remove(_roleKey);

  // ─── User ID ───
  Future<void> saveUserId(String id) async =>
      await _storage.setString(_userIdKey, id);

  Future<String?> getUserId() async => _storage.getString(_userIdKey);

  // ─── Session ───
  Future<bool> hasActiveSession() async =>
      _storage.getString(_tokenKey) != null;

  Future<void> clearAll() async => await _storage.clear();
}
