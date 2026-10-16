import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/teacher_model.dart';

  class TeacherService {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _teacherClasses = [];

  List<Map<String, dynamic>> get teacherClasses =>
      List.unmodifiable(_teacherClasses);

  // ============================================================
  // ENSEIGNANTS
  // ============================================================

  Future<List<TeacherModel>> getTeachers() async {
    final response = await _apiClient.get(
    ApiConstants.teacher,
    );

    if (response.statusCode != 200) {
      throw Exception(
      'Erreur lors de la récupération des enseignants.',
      );
    }

    final decoded = jsonDecode(response.body);

    final data = decoded is List
    ? decoded
        : (decoded is Map
    ? decoded['data'] ?? decoded['teachers']
        : const []);

    return (data as List)
        .whereType<Map>()
        .map(
    (e) => TeacherModel.fromJson(
    Map<String, dynamic>.from(e),
    ),
    )
        .toList();
  }

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  Future<List<dynamic>> getConversations() async {
    final response = await _apiClient.get(
    ApiConstants.teacherConversations,
    );

    if (response.statusCode != 200) {
      throw Exception(
      'Erreur lors de la récupération des conversations.',
      );
    }

    final decoded = jsonDecode(response.body);

    return decoded is List
    ? decoded
        : (decoded is Map
    ? decoded['data'] ?? const []
        : const []);
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  Future<List<dynamic>> getMessages(
  int conversationId,
  ) async {
    final response = await _apiClient.get(
    ApiConstants.teacherMessages(
    conversationId,
    ),
    );

    if (response.statusCode != 200) {
      throw Exception(
      'Erreur lors de la récupération des messages.',
      );
    }

    final decoded = jsonDecode(response.body);

    return decoded is List
    ? decoded
        : (decoded is Map
    ? decoded['data'] ?? const []
        : const []);
  }

  // ============================================================
  // ENVOYER UN MESSAGE
  // ============================================================

  Future<void> sendMessage(
  int conversationId,
  String content,
  ) async {
    final response = await _apiClient.post(
    ApiConstants.teacherSendMessage,
    body: {
      'conversation_id': conversationId,
      'content': content,
    },
    );

    if (response.statusCode != 200 &&
    response.statusCode != 201) {
      throw Exception(
      "Erreur lors de l’envoi du message.",
      );
    }
  }

  // ============================================================
  // UTILITAIRE : EXTRAIRE data
  // ============================================================

  List<Map<String, dynamic>> _dataList(
  String body,
  ) {
    final decoded = jsonDecode(body);

    final data = decoded is Map
    ? decoded['data']
        : decoded;

    return (data is List ? data : const [])
        .whereType<Map>()
        .map(
    (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  // ============================================================
  // COURS DE L'ENSEIGNANT
  // ============================================================

  Future<List<Map<String, dynamic>>> getAttendanceSlots({
  DateTime? date,
  }) async {
    final suffix = date == null
    ? ''
        : '?date=${date.toIso8601String().substring(0, 10)}';

    final response = await _apiClient.get(
    '${ApiConstants.teacherAttendanceSlots}$suffix',
    );

    if (response.statusCode != 200) {
      throw Exception(
      'Impossible de récupérer les cours.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map && decoded['classes'] is List) {
      _teacherClasses = (decoded['classes'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return _dataList(response.body);
  }

  // ============================================================
  // ÉLÈVES DU COURS
  // ============================================================

  Future<List<Map<String, dynamic>>> getAttendanceStudents(
  int slotId,
  ) async {
    final response = await _apiClient.get(
    ApiConstants.teacherAttendanceStudents(
    slotId,
    ),
    );

    if (response.statusCode != 200) {
      throw Exception(
      'Impossible de récupérer les élèves.',
      );
    }

    return _dataList(response.body);
  }

  // ============================================================
  // PRÉSENCES DU COURS
  // ============================================================

  Future<List<Map<String, dynamic>>> getSlotAttendances(
  int slotId,
  ) async {
    final response = await _apiClient.get(
    ApiConstants.teacherAttendanceList(
    slotId,
    ),
    );

    if (response.statusCode != 200) {
      throw Exception(
      'Impossible de récupérer les présences.',
      );
    }

    return _dataList(response.body);
  }

  // ============================================================
  // MARQUER UNE PRÉSENCE
  // ============================================================

  Future<void> markAttendance({
  required int slotId,
  required int studentId,
  required String status,
    }) async {
    final response = await _apiClient.post(
    ApiConstants.teacherMarkAttendance,
    body: {
      'slot_id': slotId,
      'student_id': studentId,
      'status': status,
    },
    );

    if (response.statusCode != 200) {
      throw Exception(
      'Impossible d’enregistrer la présence.',
      );
    }
  }

  // ============================================================
  // MARQUER LES PRÉSENCES EN MASSE
  // ============================================================

  Future<Map<String, dynamic>> markBulkAttendance({
  required int slotId,
  required List<Map<String, dynamic>> attendances,
    }) async {
    try {
      final response = await _apiClient.post(
      ApiConstants.teacherMarkBulkAttendance,
      body: {
        'slot_id': slotId,
        'attendances': attendances,
      },
      );

      if (response.statusCode != 200) {
        throw Exception(
        'Impossible d’enregistrer les présences.',
        );
      }

      final decoded = jsonDecode(
      response.body,
      );

      return decoded is Map
      ? Map<String, dynamic>.from(decoded)
          : const {};
    } catch (error) {
      debugPrint(
      'Attendance bulk error: $error',
      );

      rethrow;
    }
  }


  // ============================================================
// AGENDA DE L'ENSEIGNANT
// ============================================================
//
// Réutilise l'endpoint existant :
//
// GET /api/attendance/slots/?date=YYYY-MM-DD
//
// period:
//   day   -> 1 jour
//   week  -> 7 jours
//   month -> tous les jours du mois
//
// ============================================================

    Future<List<Map<String, dynamic>>> getTeacherAgenda({
      DateTime? date,
      String period = 'week',
    }) async {
      final selectedDate = date ?? DateTime.now();

      final List<Map<String, dynamic>> allSlots = [];

      int numberOfDays;

      switch (period) {
        case 'day':
          numberOfDays = 1;
          break;

        case 'month':
          numberOfDays = DateUtils.getDaysInMonth(
            selectedDate.year,
            selectedDate.month,
          );
          break;

        case 'week':
        default:
          numberOfDays = 7;
          break;
      }

      // ----------------------------------------------------------
      // Pour la semaine :
      // on commence au lundi
      // ----------------------------------------------------------

      DateTime firstDate = selectedDate;

      if (period == 'week') {
        final difference = selectedDate.weekday - DateTime.monday;

        firstDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day - difference,
        );
      }

      // ----------------------------------------------------------
      // Récupération des cours
      // ----------------------------------------------------------

      for (int i = 0; i < numberOfDays; i++) {
        final currentDate = firstDate.add(
          Duration(days: i),
        );

        final dateString =
            '${currentDate.year.toString().padLeft(4, '0')}-'
            '${currentDate.month.toString().padLeft(2, '0')}-'
            '${currentDate.day.toString().padLeft(2, '0')}';

        try {
          final response = await _apiClient.get(
            '${ApiConstants.teacherAttendanceSlots}'
                '?date=$dateString',
          );

          if (response.statusCode != 200) {
            continue;
          }

          final slots = _dataList(response.body);

          // ------------------------------------------------------
          // Ajouter la date au cours si le backend ne la fournit
          // pas déjà.
          // ------------------------------------------------------

          for (final slot in slots) {
            final copy = Map<String, dynamic>.from(slot);

            copy['date'] ??= dateString;

            allSlots.add(copy);
          }
        } catch (error) {
          debugPrint(
            'Erreur agenda pour $dateString : $error',
          );
        }
      }

      // ----------------------------------------------------------
      // Tri par date puis heure
      // ----------------------------------------------------------

      allSlots.sort((a, b) {
        final dateA = a['date']?.toString() ?? '';
        final dateB = b['date']?.toString() ?? '';

        final dateCompare = dateA.compareTo(dateB);

        if (dateCompare != 0) {
          return dateCompare;
        }

        final startA = a['start']?.toString() ?? '';
        final startB = b['start']?.toString() ?? '';

        return startA.compareTo(startB);
      });

      return allSlots;
    }

  // ============================================================
// DASHBOARD ENSEIGNANT
// ============================================================

    Future<Map<String, dynamic>> getTeacherDashboard() async {
      final response = await _apiClient.get(
        ApiConstants.teacherDashboard,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Impossible de récupérer le dashboard enseignant.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Réponse invalide du serveur.',
        );
      }

      if (decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ??
              'Erreur lors du chargement du dashboard.',
        );
      }

      final data = decoded['data'];

      if (data is! Map) {
        throw Exception(
          'Les données du dashboard sont invalides.',
        );
      }

      return Map<String, dynamic>.from(data);
    }

}

