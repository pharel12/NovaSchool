import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/child_model.dart';
import '../models/teacher_model.dart';

class TeacherService {
  final ApiClient _apiClient = ApiClient();

  /// Récupère la liste de tous les enseignants (pour les parents)
  Future<List<TeacherModel>> getTeachers() async {
    try {
      final response = await _apiClient.get(ApiConstants.teacher);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TeacherModel.fromJson(json)).toList();
      }
      throw Exception('Erreur lors de la récupération des enseignants');
    } catch (e) {
      debugPrint('Error getting teachers: $e');
      rethrow;
    }
  }

  /// Récupère les conversations d'un enseignant
  Future<List<dynamic>> getConversations() async {
    try {
      final response = await _apiClient.get(ApiConstants.teacherConversations);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur lors de la récupération des conversations');
    } catch (e) {
      debugPrint('Error getting teacher conversations: $e');
      rethrow;
    }
  }

  /// Récupère les messages d'une conversation pour un enseignant
  Future<List<dynamic>> getMessages(int conversationId) async {
    try {
      final response = await _apiClient.get(ApiConstants.teacherMessages(conversationId));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur lors de la récupération des messages');
    } catch (e) {
      debugPrint('Error getting teacher messages: $e');
      rethrow;
    }
  }

  /// Envoie un message en tant qu'enseignant
  Future<void> sendMessage(int conversationId, String content) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.teacherSendMessage,
        body: {
          'conversation_id': conversationId,
          'content': content,
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Erreur lors de l\'envoi du message');
      }
    } catch (e) {
      debugPrint('Error sending teacher message: $e');
      rethrow;
    }
  }

  /// Récupère la liste des élèves pour marquer les absences
  Future<List<ChildModel>> getStudents() async {
    try {
      final response = await _apiClient.get(ApiConstants.teacherStudentsList);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChildModel.fromJson(json)).toList();
      }
      throw Exception('Erreur lors de la récupération des élèves');
    } catch (e) {
      debugPrint('Error getting teacher students: $e');
      rethrow;
    }
  }

  /// Marque l'absence d'un élève
  Future<void> markAbsence({
    required int studentId,
    required String status, // 'absent', 'late', 'present'
    String? comment,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.teacherMarkAbsence,
        body: {
          'student_id': studentId,
          'status': status,
          'comment': comment,
          'start_datetime': startDate.toIso8601String(),
          if (endDate != null) 'end_datetime': endDate.toIso8601String(),
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors du marquage de l\'absence');
      }
    } catch (e) {
      debugPrint('Error marking absence: $e');
      rethrow;
    }
  }
}
