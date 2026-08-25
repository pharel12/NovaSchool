import 'dart:convert';

import 'package:novaschool/core/constants/api_constants.dart';
import 'package:novaschool/core/network/api_client.dart';
import 'package:novaschool/models/child_dashboard_models.dart';
import 'package:novaschool/models/child_model.dart';

import '../models/filter_models.dart';

/// Service charg� de r�cup�rer les donn�es enfants depuis l'API OdooManager.
/// 
/// ? ADAPT� aux nouveaux endpoints v2.0:
///   - /api/children/{id}/absences/   (anciennement: /api/students/{id}/attendances/)
///   - /api/children/{id}/timetable/  (anciennement: /api/students/{id}/timetables/)
///   - /api/children/{id}/payments/   (anciennement: /api/students/{id}/payments/)
///   - /api/children/{id}/grades/     (NOUVEAU)
class ChildService {
  final ApiClient _apiClient = ApiClient();

  /// R�cup�re la liste des enfants du parent connect�.
  /// 
  /// Retour: Une liste d'enfants pars�e depuis la r�ponse API
  /// G�re plusieurs formats de r�ponse possibles: children, results, data, items
  Future<List<ChildModel>> getChildren() async {
    try {
      final response = await _apiClient.get(ApiConstants.children);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        
        // Extraction intelligente de la liste des enfants
        // OdooManager retourne {"children": [...]}
        final List<dynamic> rawChildren = _extractList(
          decoded,
          keys: ['children', 'results', 'data', 'items'],
        );

        return rawChildren
            .whereType<Map>()
            .map(
              (entry) => ChildModel.fromJson(Map<String, dynamic>.from(entry)),
            )
            .toList();
      }

      throw Exception(_readErrorMessage(response.body));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Impossible de charger les enfants.');
    }
  }

  /// R�cup�re les absences et retards d'un enfant.
  /// 
  /// Endpoint (OdooManager): GET /api/children/{id}/absences/
  /// Ancien endpoint: GET /api/students/{id}/attendances/
  /// 
  /// Retour: {"absences": [...], "total_absences": ..., "total_retards": ...}
  Future<List<AbsenceEntry>> getChildAbsences(
      String childId, {
        AbsenceFilter? filter,
      }) async {
    final url = ApiConstants.childAbsences(
      childId,
      dateStart: filter?.dateStart,
      dateEnd: filter?.dateEnd,
    );

    final response = await _apiClient.get(url);

    if (response.statusCode != 200) {
      throw Exception(_readErrorMessage(response.body));
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> list = _extractList(
      decoded,
      keys: ["absences", "results", "data", "items"],
    );

    return list
        .map((e) => AbsenceEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// R�cup�re l'emploi du temps du jour pour un enfant.
  /// 
  /// Endpoint (OdooManager): GET /api/children/{id}/timetable/
  /// Ancien endpoint: GET /api/students/{id}/timetables/
  /// 
  /// Retour: {"days": {"lundi": [...], ...}, "timetable": {...}}
  Future<TimetableData> getChildTimeTable(
      String childId, {
        String period = 'week',
        DateTime? selectedDate,
      }) async {
    final response = await _apiClient.get(
      ApiConstants.studentTimeTable(
        childId,
        period: period,
        date: selectedDate == null
            ? null
            : '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(_readErrorMessage(response.body));
    }

    final decoded = jsonDecode(response.body);

    return TimetableData.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  /// R�cup�re les paiements et factures d'un enfant.
  /// 
  /// Endpoint (OdooManager): GET /api/children/{id}/payments/
  /// Ancien endpoint: GET /api/students/{id}/payments/
  /// 
  /// Retour: {"payments": [...], "student": {...}, "statut_paiement": ...}
  Future<List<Paiement>> getChildPayments(
      String childId, {
        PaymentFilter? filter,
      }) async {
    final url = ApiConstants.childPayments(
      childId,
      paymentStatus: filter?.paymentStatus?.value,
      academicYearId: filter?.academicYearId,
    );

    final response = await _apiClient.get(url);

    if (response.statusCode != 200) {
      throw Exception(_readErrorMessage(response.body));
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> list = _extractList(
      decoded,
      keys: ["payments", "results", "data", "items"],
    );

    return list
        .map((e) => Paiement.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// ? NOUVEAU: R�cup�re les notes d'un �l�ve.
  /// 
  /// Endpoint (OdooManager): GET /api/children/{id}/grades/
  /// 
  /// Retour: {"grades": [...], "average": ..., "count": ..., "student": {...}}
  Future<List<GradeEntry>> getChildGrades(
      String childId, {
        GradesFilter? filter,
      }) async {
    final url = ApiConstants.childGrades(
      childId,
      evaluationType: filter?.evaluationType?.value,
      academicYearId: filter?.academicYearId,
      grouped: false,
    );

    final response = await _apiClient.get(url);

    if (response.statusCode != 200) {
      throw Exception(_readErrorMessage(response.body));
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> list = _extractList(
      decoded,
      keys: ["grades", "results", "data", "items"],
    );

    return list
        .map((e) => GradeEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Combine les donn�es d'absences, emploi du temps, paiements et notes.
  /// 
  /// Charge les donn�es en parall�le pour une meilleure performance.
  Future<ChildDashboard> getChildDashboard(
      String childId,
      ) async {
    // Les ressources Odoo sont indépendantes. Une facture indisponible ne doit
    // pas empêcher un parent de consulter les absences ou l'emploi du temps.
    final results = await Future.wait([
      _withFallback(getChildAbsences(childId), <AbsenceEntry>[]),
      _withFallback(getChildGrades(childId), <GradeEntry>[]),
      _withFallback(getChildPayments(childId), <Paiement>[]),
      _withFallback(
        getChildTimeTable(childId),
        const TimetableData(studentId: 0, studentName: '', timetable: []),
      ),
    ]);

    return ChildDashboard(
      absences: results[0] as List<AbsenceEntry>,
      grades: results[1] as List<GradeEntry>,
      payments: results[2] as List<Paiement>,
      timetable: results[3] as TimetableData,
    );
  }

  /// Retourne une valeur vide pour une rubrique indisponible afin de permettre
  /// l'affichage des autres données déjà récupérées avec succès.
  Future<T> _withFallback<T>(Future<T> request, T fallback) async {
    try {
      return await request;
    } catch (_) {
      return fallback;
    }
  }

  // -----------------------------------------------------------------------------
  // ??? UTILITAIRES PRIV�S
  // -----------------------------------------------------------------------------

  /// Extrait une liste d'une r�ponse JSON complexe.
  List<dynamic> _extractList(dynamic decoded, {required List<String> keys}) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      for (final key in keys) {
        final value = decoded[key];
        if (value is List) {
          return value;
        }
        if (value is Map<String, dynamic>) {
          return _extractList(value, keys: keys);
        }
      }

      if (decoded.containsKey('data')) {
        final data = decoded['data'];
        if (data is List) {
          return data;
        }
      }
    }

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      return _extractList(map, keys: keys);
    }

    return const [];
  }

  /// Extrait une Map d'une r�ponse JSON complexe.
  Map<String, dynamic>? _extractMap(
    dynamic decoded, {
    required List<String> keys,
  }) {
    if (decoded is Map<String, dynamic>) {
      for (final key in keys) {
        final value = decoded[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
      }
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return null;
  }

  /// Convertit une valeur en int de mani�re s�re.
  int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Extrait le message d'erreur d'une r�ponse API.
  String _readErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ?? 'Erreur API.';
      }
    } catch (_) {}

    return 'Erreur API.';
  }
}
