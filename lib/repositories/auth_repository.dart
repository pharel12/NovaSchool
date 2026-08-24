import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  /// Connexion
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final authResponse = await _authService.login(
      username: username,
      password: password,
    );
    await _storage.saveAccessToken(authResponse.accessToken);
    await _storage.saveRefreshToken(authResponse.refreshToken);
    return authResponse.user;
  }

  /// Récupère le profil de l'utilisateur connecté
  Future<UserModel> getProfile() async {
    return await _authService.getProfile();
  }

  /// Déconnexion
  Future<void> logout() async {
    await _storage.clearTokens();
  }

  /// Vérifie si l'utilisateur est déjà connecté
  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }
}