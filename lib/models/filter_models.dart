/// 🔍 Modèles pour les filtres et réponses du middleware OdooManager
///
/// Contient les classes pour supporter:
/// - Filtres d'absences (dates)
/// - Filtres de notes (type, groupage)
/// - Filtres de paiements (statut)
/// - Réponses groupées

// ═════════════════════════════════════════════════════════════════════════════
// 📋 FILTRES D'ABSENCES
// ═════════════════════════════════════════════════════════════════════════════

/// 📋 Filtre pour récupérer les absences
class AbsenceFilter {
  /// Date de début au format YYYY-MM-DD
  /// Exemple: "2026-07-13"
  final String? dateStart;
  
  /// Date de fin au format YYYY-MM-DD
  /// Exemple: "2026-07-19"
  final String? dateEnd;

  AbsenceFilter({
    this.dateStart,
    this.dateEnd,
  });

  /// Crée un filtre depuis une plage de dates Dart
  factory AbsenceFilter.fromDateRange(DateTime start, DateTime end) {
    return AbsenceFilter(
      dateStart: _formatDate(start),
      dateEnd: _formatDate(end),
    );
  }

  /// Crée un filtre pour la semaine courante
  factory AbsenceFilter.currentWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6));
    
    return AbsenceFilter.fromDateRange(start, end);
  }

  /// Crée un filtre pour le mois courant
  factory AbsenceFilter.currentMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    
    return AbsenceFilter.fromDateRange(start, end);
  }

  /// Convertit le filtre en paramètres de requête
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (dateStart != null) params['date_start'] = dateStart!;
    if (dateEnd != null) params['date_end'] = dateEnd!;
    return params;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 📊 FILTRES DE NOTES
// ═════════════════════════════════════════════════════════════════════════════

/// 📊 Type d'évaluation pour filtrer les notes
enum EvaluationType {
  /// Contrôle / Quiz
  test('test'),
  /// Examen
  exam('exam'),
  /// Devoir / Travail
  assignment('assignment');

  final String value;
  const EvaluationType(this.value);
}

/// 📊 Filtre pour récupérer les notes
class GradesFilter {
  /// Type d'évaluation ('test', 'exam', 'assignment')
  final EvaluationType? evaluationType;
  
  /// ID de l'année académique
  final String? academicYearId;
  
  /// Grouper par cours (défaut: false)
  final bool grouped;

  GradesFilter({
    this.evaluationType,
    this.academicYearId,
    this.grouped = false,
  });

  /// Crée un filtre pour toutes les notes groupées par cours
  factory GradesFilter.groupedBySubject() {
    return GradesFilter(grouped: true);
  }

  /// Crée un filtre pour les examens uniquement
  factory GradesFilter.examsOnly() {
    return GradesFilter(evaluationType: EvaluationType.exam);
  }

  /// Crée un filtre pour les contrôles uniquement
  factory GradesFilter.testsOnly() {
    return GradesFilter(evaluationType: EvaluationType.test);
  }

  /// Convertit le filtre en paramètres de requête
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (evaluationType != null) params['evaluation_type'] = evaluationType!.value;
    if (academicYearId != null) params['academic_year_id'] = academicYearId!;
    if (grouped) params['grouped'] = 'true';
    return params;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 💰 FILTRES DE PAIEMENTS
// ═════════════════════════════════════════════════════════════════════════════

/// 💰 Statut de paiement pour filtrer
enum PaymentStatus {
  /// Factures payées
  paid('paid'),
  /// Factures non payées
  unpaid('unpaid');

  final String value;
  const PaymentStatus(this.value);
}

/// 💰 Filtre pour récupérer les paiements
class PaymentFilter {
  /// Statut du paiement ('paid', 'unpaid')
  final PaymentStatus? paymentStatus;
  
  /// ID de l'année académique
  final String? academicYearId;

  PaymentFilter({
    this.paymentStatus,
    this.academicYearId,
  });

  /// Crée un filtre pour les factures non payées
  factory PaymentFilter.unpaidOnly() {
    return PaymentFilter(paymentStatus: PaymentStatus.unpaid);
  }

  /// Crée un filtre pour les factures payées
  factory PaymentFilter.paidOnly() {
    return PaymentFilter(paymentStatus: PaymentStatus.paid);
  }

  /// Convertit le filtre en paramètres de requête
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (paymentStatus != null) params['payment_status'] = paymentStatus!.value;
    if (academicYearId != null) params['academic_year_id'] = academicYearId!;
    return params;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 📊 RÉPONSES GROUPÉES
// ═════════════════════════════════════════════════════════════════════════════

/// 📊 Représente les notes groupées par cours
/// Retour du middleware quand grouped=true
class GroupedGrades {
  /// Notes groupées par cours
  final List<CourseGrades> byCourse;

  GroupedGrades({required this.byCourse});

  /// Crée depuis une réponse JSON du serveur
  /// Exemple: {"by_course": [...]}
  factory GroupedGrades.fromJson(Map<String, dynamic> json) {
    final courseList = (json['by_course'] as List<dynamic>?)
        ?.map((c) => CourseGrades.fromJson(c as Map<String, dynamic>))
        .toList() ?? [];
    
    return GroupedGrades(byCourse: courseList);
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() => {
    'by_course': byCourse.map((c) => c.toJson()).toList(),
  };

  /// Retourne la note moyenne de tous les cours
  double get overallAverage {
    if (byCourse.isEmpty) return 0;
    final sum = byCourse.fold<double>(0, (s, c) => s + c.average);
    return sum / byCourse.length;
  }

  /// Retourne le cours avec la meilleure moyenne
  CourseGrades? get bestCourse {
    if (byCourse.isEmpty) return null;
    return byCourse.reduce((a, b) => a.average > b.average ? a : b);
  }

  /// Retourne le cours avec la pire moyenne
  CourseGrades? get worstCourse {
    if (byCourse.isEmpty) return null;
    return byCourse.reduce((a, b) => a.average < b.average ? a : b);
  }
}

/// 📊 Représente les notes d'un cours (pour réponse groupée)
class CourseGrades {
  /// ID du cours
  final int courseId;
  
  /// Nom du cours
  final String courseName;
  
  /// Moyenne du cours
  final double average;
  
  /// Liste des notes du cours
  final List<dynamic> grades;

  CourseGrades({
    required this.courseId,
    required this.courseName,
    required this.average,
    required this.grades,
  });

  /// Crée depuis une réponse JSON du serveur
  factory CourseGrades.fromJson(Map<String, dynamic> json) {
    return CourseGrades(
      courseId: json['course_id'] as int? ?? 0,
      courseName: json['course_name'] as String? ?? 'Inconnu',
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      grades: json['grades'] as List<dynamic>? ?? [],
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    'course_name': courseName,
    'average': average,
    'grades': grades,
  };

  /// Retourne la note minimale du cours
  double get minGrade {
    if (grades.isEmpty) return 0;
    return (grades.map((g) => (g['grade'] as num?)?.toDouble() ?? 0).reduce((a, b) => a < b ? a : b));
  }

  /// Retourne la note maximale du cours
  double get maxGrade {
    if (grades.isEmpty) return 0;
    return (grades.map((g) => (g['grade'] as num?)?.toDouble() ?? 0).reduce((a, b) => a > b ? a : b));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 🏥 HEALTH CHECK
// ═════════════════════════════════════════════════════════════════════════════

/// 🏥 État du serveur
enum ServerStatus {
  /// Serveur OK
  ok('ok'),
  /// Erreur serveur
  error('error');

  final String value;
  const ServerStatus(this.value);
}

/// 🏥 Résultat du health check
class HealthCheckResult {
  /// État global du serveur
  final ServerStatus status;
  
  /// État de la base de données
  final ServerStatus database;
  
  /// État de la connexion Odoo
  final ServerStatus odoo;
  
  /// Message d'information
  final String message;
  
  /// Timestamp de la vérification
  final DateTime checkedAt;

  HealthCheckResult({
    required this.status,
    required this.database,
    required this.odoo,
    required this.message,
    DateTime? checkedAt,
  }) : checkedAt = checkedAt ?? DateTime.now();

  /// Crée depuis une réponse JSON du serveur
  factory HealthCheckResult.fromJson(Map<String, dynamic> json) {
    return HealthCheckResult(
      status: ServerStatus.values.firstWhere(
        (s) => s.value == json['status'],
        orElse: () => ServerStatus.error,
      ),
      database: ServerStatus.values.firstWhere(
        (s) => s.value == json['database'],
        orElse: () => ServerStatus.error,
      ),
      odoo: ServerStatus.values.firstWhere(
        (s) => s.value == json['odoo'],
        orElse: () => ServerStatus.error,
      ),
      message: json['message'] as String? ?? 'Pas d\'information',
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() => {
    'status': status.value,
    'database': database.value,
    'odoo': odoo.value,
    'message': message,
    'checked_at': checkedAt.toIso8601String(),
  };

  /// Vérifie si le serveur est complètement opérationnel
  bool get isHealthy => status == ServerStatus.ok && 
      database == ServerStatus.ok && 
      odoo == ServerStatus.ok;

  /// Vérifie si la base de données est OK
  bool get isDatabaseOk => database == ServerStatus.ok;

  /// Vérifie si Odoo est connecté
  bool get isOdooOk => odoo == ServerStatus.ok;
}

// ═════════════════════════════════════════════════════════════════════════════
// 🔧 UTILITAIRES
// ═════════════════════════════════════════════════════════════════════════════

/// Formate une date Dart en format API (YYYY-MM-DD)
String _formatDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
