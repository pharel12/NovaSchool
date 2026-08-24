import 'package:network_info_plus/network_info_plus.dart';

/// Centralise toutes les routes de l'API - OdooManager Middleware v2.0
class ApiConstants {
  // ===========================================================================
  // CONFIGURATION DES SERVEURS
  // ===========================================================================

  /// URL actuellement sélectionnée
  static String _baseUrl = 'http://192.168.1.149:8000/api';

  /// URL par défaut si aucun Wi-Fi connu n'est détecté
  static const String defaultUrl = 'http://192.168.1.149:8000/api';

  // ===========================================================================
  // MAPPING WIFI -> SERVEUR
  // ===========================================================================

  /// Change ces noms de Wi-Fi et adresses IP selon ton environnement.
  static const Map<String, String> wifiServers = {

  'MonWifiEntreprise': 'http://192.168.1.28:8000/api',

  'WifiEcole': 'http://192.168.1.149:8000/api',

  'Redmi': 'http://172.21.44.180:8000/api',
  };

  // ===========================================================================
  // INITIALISATION
  // ===========================================================================

  /// Détecte automatiquement le Wi-Fi et sélectionne le serveur correspondant.
  static Future<void> initialize() async {
    try {
      final info = NetworkInfo();

      final wifiName = await info.getWifiName();

      // Retire les éventuels guillemets ajoutés par Android
      final cleanWifiName = wifiName?.replaceAll('"', '').trim();

      print('📶 Wi-Fi détecté : $cleanWifiName');

      if (cleanWifiName != null &&
      wifiServers.containsKey(cleanWifiName)) {
        _baseUrl = wifiServers[cleanWifiName]!;

        print('🌐 Serveur sélectionné : $_baseUrl');
      } else {
        _baseUrl = defaultUrl;

        print('⚠️ Wi-Fi inconnu : utilisation du serveur par défaut',);
        print('🌐 Serveur : $_baseUrl');
      }
    } catch (e) {
      _baseUrl = defaultUrl;

      print('❌ Impossible de détecter le Wi-Fi : $e');
      print('🌐 Serveur par défaut : $_baseUrl');
    }
  }

  // ===========================================================================
  // URL DE BASE
  // ===========================================================================
  static String get baseUrl => _baseUrl;

  // ===========================================================================
  // AUTHENTIFICATION
  // ===========================================================================
  static String get login => "$baseUrl/login/";

  /// POST /api/token/refresh/
  static String get tokenRefresh => "$baseUrl/token/refresh/";

  // ===========================================================================
  // PROFIL UTILISATEUR
  // ===========================================================================
  static String get profile => "$baseUrl/profile/";

  // ===========================================================================
  // GESTION DES ENFANTS
  // ===========================================================================
  static String get children => "$baseUrl/children/";

  // ===========================================================================
  // INFORMATION DU PROFESSEUR
  // ===========================================================================
  static String get teacher => "$baseUrl/teachers/";

  // ===========================================================================
  // CHAT
  // ===========================================================================
  static String get chatStart => "$baseUrl/chat/start/";
  static String get chatSend => "$baseUrl/chat/send/";
  static String get chatConversations => "$baseUrl/chat/conversations/";

  // Endpoints Enseignants (Chat)
  static String get teacherConversations => "$baseUrl/chat/teacher/conversations/";
  static String teacherMessages(int conversationId) => "$baseUrl/chat/teacher/conversations/$conversationId/messages/";
  static String get teacherSendMessage => "$baseUrl/chat/teacher/send/";

  // ===========================================================================
  // ABSENCES / PRÉSENCES (Enseignants)
  // ===========================================================================
  static String get teacherMarkAbsence => "$baseUrl/teacher/absences/mark/";
  static String get teacherStudentsList => "$baseUrl/teacher/students/";

  // ===========================================================================
  // ABSENCES / PRÉSENCES
  // ===========================================================================

  static String childAbsences(
  String id, {
    String? dateStart,
    String? dateEnd,
  }) {
    String url = "$baseUrl/children/$id/absences/";

    final params = <String>[];

    if (dateStart != null) {
    params.add("date_start=$dateStart");
    }

    if (dateEnd != null) {
    params.add("date_end=$dateEnd");
    }

    if (params.isNotEmpty) {
    url += "?${params.join('&')}";
    }

    return url;
  }

  // ===========================================================================
  // NOTES / ÉVALUATIONS
  // ===========================================================================
  static String childGrades(
  String id, {
    String? evaluationType,
    String? academicYearId,
    bool grouped = false,
  }) {
    String url = "$baseUrl/children/$id/grades/";

    final params = <String>[];

    if (evaluationType != null) {
      params.add("evaluation_type=$evaluationType");
    }

    if (academicYearId != null) {
      params.add("academic_year_id=$academicYearId");
    }

    if (grouped) {
      params.add("grouped=true");
    }

    if (params.isNotEmpty) {
      url += "?${params.join('&')}";
    }

    return url;
  }

  // ===========================================================================
  // PAIEMENTS / FACTURES
  // ===========================================================================

  static String childPayments(
  String id, {
    String? paymentStatus,
    String? academicYearId,
  }) {
    String url = "$baseUrl/children/$id/payments/";

    final params = <String>[];

    if (paymentStatus != null) {
      params.add("payment_status=$paymentStatus");
    }

    if (academicYearId != null) {
      params.add("academic_year_id=$academicYearId");
    }

    if (params.isNotEmpty) {
      url += "?${params.join('&')}";
    }

    return url;
  }

  // Pour compatibilité backward
  @Deprecated('Use childPayments() instead')
  static String childPayment(String id) {
    return "$baseUrl/children/$id/payments/";
  }

  // ===========================================================================
  // EMPLOI DU TEMPS
  // ===========================================================================
  static String childTimeTable(String id) {
    return "$baseUrl/children/$id/timetable/";
  }

  // ===========================================================================
  // HEALTH CHECK
  // ===========================================================================
  static String get health => "$baseUrl/health/";

  // ===========================================================================
  // AGENDA PARENT
  // ===========================================================================
  static String get parentAgenda => "$baseUrl/agenda/";
  static String parentAgendaDetail(int eventId) => "$baseUrl/agenda/$eventId/";
}
