import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Cette classe contient toute la logique liée à l'authentification.

class AuthService {

  /// Connexion
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponseModel.fromJson(data);
      }

      final data = jsonDecode(response.body);
      throw Exception(data["message"] ?? "Identifiants incorrects.");
    } on TimeoutException {
      throw Exception('Le serveur ne répond pas. Vérifiez votre connexion.');
    } on FormatException {
      throw Exception('Réponse invalide du serveur.');
    } catch (e) {
      // Ne pas présenter un refus d'identifiants comme une erreur réseau.
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau : $e');
    }
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse(ApiConstants.tokenRefresh),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["access"];
    }

    throw Exception("Session expirée, veuillez vous reconnecter.");
  }

  /// Profil (utilise ApiClient pour gérer le token + refresh automatique)
  Future<UserModel> getProfile() async {
    final response = await ApiClient().get(ApiConstants.profile);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(
        data["message"] ?? "Impossible de récupérer le profil.",
      );
    }
  }
}
