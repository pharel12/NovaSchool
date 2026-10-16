import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

/// Petit wrapper HTTP qui ajoute automatiquement le token d'acc�s et g�re le refresh.
class ApiClient {
  final StorageService _storage = StorageService();
  final AuthService _authService = AuthService();

  /// Ex�cute une requ�te GET avec le token stock� et relance automatiquement
  /// la requ�te si le backend r�pond 401.
  Future<http.Response> get(String url, {String? token}) async {
    return _sendWithRetry(() async {
      final authToken = token ?? await _storage.getAccessToken();
      if (authToken == null || authToken.isEmpty) {
        throw Exception('Utilisateur non authentifi�.');
      }

      return http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 60));
    });
  }

  /// Relance la requ�te initiale apr�s un refresh du token si n�cessaire.
  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();

    if (response.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) throw Exception('Session expir�e.');

      try {
        final newAccess = await _authService.refreshAccessToken(refreshToken);
        await _storage.saveAccessToken(newAccess);
        response = await request();
      } catch (e) {
        await _storage.clearTokens();
        throw Exception('Session expir�e, veuillez vous reconnecter.');
      }
    }

    return response;
  }


  /// Exécute une requête POST avec authentification.
  Future<http.Response> post(
      String url, {
        Map<String, dynamic>? body,
        String? token,
      }) async {
    return _sendWithRetry(() async {
      final authToken = token ?? await _storage.getAccessToken();

      if (authToken == null || authToken.isEmpty) {
        throw Exception("Utilisateur non authentifié.");
      }

      return http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body ?? {}),
      ).timeout(const Duration(seconds: 60));
    });
  }
}

