import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _accessTokenKey = 'ramirx_access_token';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<String?> readAccessToken() async {
    if (kIsWeb) {
      final prefs = await _prefs();
      return prefs.getString(_accessTokenKey);
    }
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> writeAccessToken(String token) async {
    if (kIsWeb) {
      final prefs = await _prefs();
      await prefs.setString(_accessTokenKey, token);
      return;
    }
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> clearAccessToken() async {
    if (kIsWeb) {
      final prefs = await _prefs();
      await prefs.remove(_accessTokenKey);
      return;
    }
    await _storage.delete(key: _accessTokenKey);
  }
}
