import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String accessTokenKey = "access_token";
  static const String refreshTokenKey = "refresh_token";
  static const String apiBaseUrlKey = "api_base_url";
  static const String apiNetworkUrlsKey = "api_network_urls";

  String _passwordChangedOnceKey(int userId) =>
      'password_changed_once_$userId';

  Future<bool> hasChangedPasswordOnce(int userId) async =>
      await _storage.read(key: _passwordChangedOnceKey(userId)) == 'true';

  Future<void> markPasswordChangedOnce(int userId) =>
      _storage.write(key: _passwordChangedOnceKey(userId), value: 'true');

  /// Sauvegarde le token d'accès
  Future<void> saveAccessToken(String token) async {
    await _storage.write(
      key: accessTokenKey,
      value: token,
    );
  }

  /// Sauvegarde le refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: refreshTokenKey,
      value: token,
    );
  }

  /// Récupère le token d'accès
  Future<String?> getAccessToken() async {
    return await _storage.read(
      key: accessTokenKey,
    );
  }

  /// Récupère le refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(
      key: refreshTokenKey,
    );
  }

  /// Enregistre l'URL API choisie par l'utilisateur, par exemple
  /// http://192.168.10.25:8000/api ou https://api.novaschool.com/api.
  Future<void> saveApiBaseUrl(String url) async {
    await _storage.write(key: apiBaseUrlKey, value: url);
  }

  Future<String?> getApiBaseUrl() => _storage.read(key: apiBaseUrlKey);

  Future<void> clearApiBaseUrl() => _storage.delete(key: apiBaseUrlKey);

  Future<Map<String, String>> getNetworkApiUrls() async {
    final raw = await _storage.read(key: apiNetworkUrlsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map((key, value) => MapEntry(key.toString(), value.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveNetworkApiUrl(String networkName, String url) async {
    final urls = await getNetworkApiUrls();
    urls[networkName] = url;
    await _storage.write(key: apiNetworkUrlsKey, value: jsonEncode(urls));
  }

  Future<void> removeNetworkApiUrl(String networkName) async {
    final urls = await getNetworkApiUrls();
    urls.remove(networkName);
    await _storage.write(key: apiNetworkUrlsKey, value: jsonEncode(urls));
  }

  /// Supprime tous les tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
  }
}



