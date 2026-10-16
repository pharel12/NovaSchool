import 'package:network_info_plus/network_info_plus.dart';
import '../../services/storage_service.dart';

/// Centralise toutes les routes de l'API - OdooManager Middleware v2.0
class ApiConstants {
  // ===========================================================================
  // CONFIGURATION DES SERVEURS
  // ===========================================================================

  /// URL actuellement sélectionnée
  static String _baseUrl = 'http://192.168.1.158:8000/api';

  /// URL par défaut si aucun Wi-Fi connu n'est détecté
  static const String defaultUrl = 'http://192.168.1.158:8000/api';

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

      // Un serveur enregistré pour ce Wi-Fi est prioritaire sur la valeur
      // générale : l'application peut donc utiliser une IP différente pour
      // chaque réseau, sans modifier le code.
      final savedNetworkUrls = await StorageService().getNetworkApiUrls();
      final networkUrl = cleanWifiName == null ? null : savedNetworkUrls[cleanWifiName];
      if (networkUrl != null && networkUrl.isNotEmpty) {
        _baseUrl = normalizeBaseUrl(networkUrl);
        return;
      }

      // Une URL générale fonctionne sur tout réseau où le serveur est
      // joignable (IP fixe, DNS public/interne ou mDNS).
      final savedUrl = await StorageService().getApiBaseUrl();
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        _baseUrl = normalizeBaseUrl(savedUrl);
        return;
      }

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

  /// Définit l'URL du serveur pour tous les réseaux et la conserve sur
  /// l'appareil. Utilisez de préférence un nom DNS stable (ex.
  /// https://api.novaschool.example/api) si les appareils changent de réseau.
  static Future<void> setBaseUrl(String url) async {
    _baseUrl = normalizeBaseUrl(url);
    await StorageService().saveApiBaseUrl(_baseUrl);
  }

  /// Revient à la détection Wi-Fi et aux valeurs de secours configurées.
  static Future<void> clearCustomBaseUrl() async {
    await StorageService().clearApiBaseUrl();
    await initialize();
  }

  /// Associe l'URL API au Wi-Fi actuellement connecté. Cette méthode permet
  /// d'utiliser automatiquement la bonne IP quand l'utilisateur change de
  /// réseau local.
  static Future<void> setBaseUrlForCurrentNetwork(String url) async {
    final network = await NetworkInfo().getWifiName();
    final name = network?.replaceAll('"', '').trim();
    if (name == null || name.isEmpty) {
      throw StateError('Aucun réseau Wi-Fi détecté.');
    }
    final normalized = normalizeBaseUrl(url);
    await StorageService().saveNetworkApiUrl(name, normalized);
    _baseUrl = normalized;
  }

  static String normalizeBaseUrl(String value) {
    var raw = value.trim().replaceAll(RegExp(r'/+$'), '');
    // La fenêtre de démarrage accepte directement une IP : 192.168.1.10
    // ou une IP avec port : 192.168.1.10:8000.
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      raw = 'http://$raw';
    }
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError('URL API invalide.');
    }
    return raw.endsWith('/api') ? raw : '$raw/api';
  }

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
  static String get changePassword => "$baseUrl/password/change/";

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
  static String get teacherAttendanceSlots => "$baseUrl/attendance/slots/";
  static String teacherAttendanceStudents(int slotId) => "$baseUrl/attendance/slots/$slotId/students/";
  static String teacherAttendanceList(int slotId) => "$baseUrl/attendance/slots/$slotId/";
  static String get teacherMarkAttendance => "$baseUrl/attendance/mark/";
  static String get teacherMarkBulkAttendance => "$baseUrl/attendance/mark-bulk/";

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

  /// Emploi du temps enrichi : période (day/week/month) et date de référence.
  static String studentTimeTable(String id, {required String period, String? date}) {
    final query = <String>['period=$period'];
    if (date != null) query.add('date=$date');
    return "$baseUrl/timetable/student/$id/?${query.join('&')}";
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

  // ===========================================================================
  // ORIENTATION SCOLAIRE (PARENT)
  // ===========================================================================
  static String orientationProfile(int studentId) => "$baseUrl/orientation/student/$studentId/profile/";
  static String orientationSchoolProfile(int studentId) => "$baseUrl/orientation/student/$studentId/school-profile/";
  static String orientationRecommendations(int studentId) => "$baseUrl/orientation/student/$studentId/recommendations/";
  static String orientationAsk(int studentId) => "$baseUrl/orientation/student/$studentId/ask/";

  // ===========================================================================
  // DASHBOARDS
  // ===========================================================================
  static String get parentDashboard => "$baseUrl/dashboard/parent/";
  static String get teacherDashboard => "$baseUrl/dashboard/teacher/";
}
