import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  SecureStorageService(this._secureStorage, this._prefs);

  // ─── Token (Encrypted via Android Keystore / iOS Keychain) ───
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // ─── Role (non-sensitive, SharedPreferences for speed) ───
  Future<void> saveRole(String role) async =>
      await _prefs.setString(_roleKey, role);

  Future<String?> getRole() async => _prefs.getString(_roleKey);

  Future<void> clearRole() async => await _prefs.remove(_roleKey);

  // ─── User ID (non-sensitive) ───
  Future<void> saveUserId(String id) async =>
      await _prefs.setString(_userIdKey, id);

  Future<String?> getUserId() async => _prefs.getString(_userIdKey);

  // ─── Session ───
  Future<bool> hasActiveSession() async =>
      await _secureStorage.read(key: _tokenKey) != null;

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
