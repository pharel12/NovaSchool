import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class DashboardService {
  final ApiClient _client = ApiClient();

  // ============================================================
  // DASHBOARD PARENT
  // ============================================================

  Future<Map<String, dynamic>> getParentDashboard() async {
    return _get(ApiConstants.parentDashboard);
  }

  // ============================================================
  // DASHBOARD ENSEIGNANT
  // ============================================================

  Future<Map<String, dynamic>> getTeacherDashboard() async {
    return _get(ApiConstants.teacherDashboard);
  }

  // ============================================================
  // REQUÊTE GET COMMUNE
  // ============================================================

  Future<Map<String, dynamic>> _get(String url) async {
    final response = await _client.get(url);

    if (response.statusCode != 200) {
      String message = 'Impossible de charger le tableau de bord.';

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          message = decoded['message']?.toString() ??
          decoded['detail']?.toString() ??
          message;
        }
      } catch (_) {}

      throw Exception(message);
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Réponse du tableau de bord invalide.',);
    }

    return Map<String, dynamic>.from(decoded);
  }
}

