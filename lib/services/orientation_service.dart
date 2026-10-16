import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class OrientationService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> _get(String url) async {
    final response = await _client.get(url);

    if (response.statusCode != 200) {
      throw Exception(_message(response.body));
    }

    return _map(response.body);
  }

  Future<Map<String, dynamic>> _post(
      String url,
      Map<String, dynamic> body,
      ) async {
    final response = await _client.post(
      url,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response.body));
    }

    return _map(response.body);
  }

  Future<Map<String, dynamic>> getProfile(
      int studentId,
      ) =>
      _get(
        ApiConstants.orientationProfile(studentId),
      );

  Future<Map<String, dynamic>> getSchoolProfile(
      int studentId,
      ) =>
      _get(
        ApiConstants.orientationSchoolProfile(studentId),
      );

  Future<Map<String, dynamic>> saveProfile({
    required int studentId,
    required List<String> interests,
    required List<String> preferredActivities,
    required String professionalProject,
    required bool childConsulted,
    required String childOpinion,
  }) =>
      _post(
        ApiConstants.orientationProfile(studentId),
        {
          'interests': interests,
          'preferred_activities': preferredActivities,
          'professional_project': professionalProject,
          'child_consulted': childConsulted,
          'child_opinion': childOpinion,
        },
      );

  Future<Map<String, dynamic>> getRecommendations(
      int studentId, {
        String? question,
      }) {
    final trimmed = question?.trim();
    return _post(
      ApiConstants.orientationRecommendations(studentId),
      (trimmed != null && trimmed.isNotEmpty)
          ? {'question': trimmed}
          : {},
    );
  }

  Future<Map<String, dynamic>> ask(
      int studentId,
      String question,
      ) =>
      _post(
        ApiConstants.orientationAsk(studentId),
        {
          'question': question.trim(),
        },
      );

  Map<String, dynamic> _map(String body) {
    final value = jsonDecode(body);

    return value is Map
        ? Map<String, dynamic>.from(value)
        : const {};
  }

  String _message(String body) {
    try {
      final map = _map(body);

      return map['message']?.toString() ??
          'Une erreur est survenue.';
    } catch (_) {
      return 'Une erreur est survenue.';
    }
  }
}