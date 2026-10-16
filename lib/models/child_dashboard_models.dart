import 'package:flutter/foundation.dart';

// ============================================================================
// ABSENCES
// ============================================================================

class AbsenceEntry {
  final int id;
  final int studentId;
  final String studentName;
  final int? teacherId;
  final String? teacherName;
  final String status;
  final String? comment;
  final DateTime startDate;
  final DateTime? endDate;

  const AbsenceEntry({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.teacherId,
    this.teacherName,
    required this.status,
    this.comment,
    required this.startDate,
    this.endDate,
  });

  factory AbsenceEntry.fromJson(Map<String, dynamic> json) {
    final student =
    json["student_id"] is List ? json["student_id"] as List : null;

    final teacher =
    json["teacher_id"] is List ? json["teacher_id"] as List : null;

    return AbsenceEntry(
      id: _asInt(json["id"]),

      studentId:
      student != null && student.isNotEmpty
          ? _asInt(student.first)
          : _asInt(json["student_id"]),

      studentName:
      student != null && student.length > 1
          ? student.last.toString()
          : json["student_name"]?.toString() ?? "",

      teacherId:
      teacher != null && teacher.isNotEmpty
          ? _asInt(teacher.first)
          : _nullableInt(json["teacher_id"]),

      teacherName:
      teacher != null && teacher.length > 1
          ? teacher.last.toString()
          : json["teacher_name"]?.toString(),

      status: json["status"]?.toString() ?? "",

      comment: json["comment"]?.toString(),

      startDate:
      DateTime.tryParse(
        json["start_datetime"]?.toString() ?? "",
      ) ??
          DateTime.fromMillisecondsSinceEpoch(0),

      endDate:
      json["end_datetime"] != null
          ? DateTime.tryParse(
        json["end_datetime"].toString(),
      )
          : null,
    );
  }

  bool get isAbsent => status == "absent";

  bool get isLate => status == "late";

  bool get isPresent => status == "present";
}

// ============================================================================
// NOTES
// ============================================================================

class GradeEntry {
  final int id;
  final int evaluationId;
  final String evaluationName;
  final int courseId;
  final String courseName;
  final String type;
  final double grade;
  final String? comment;
  final DateTime? date;

  const GradeEntry({
    required this.id,
    required this.evaluationId,
    required this.evaluationName,
    required this.courseId,
    required this.courseName,
    required this.type,
    required this.grade,
    this.comment,
    this.date,
  });

  factory GradeEntry.fromJson(Map<String, dynamic> json) {
    final evaluation =
    json["evaluation_id"] is List
        ? json["evaluation_id"] as List
        : null;

    final course =
    json["course_id"] is List
        ? json["course_id"] as List
        : null;

    return GradeEntry(
      id: _asInt(json["id"]),

      evaluationId:
      evaluation != null && evaluation.isNotEmpty
          ? _asInt(evaluation.first)
          : _asInt(json["evaluation_id"]),

      evaluationName:
      evaluation != null && evaluation.length > 1
          ? evaluation.last.toString()
          : json["evaluation_name"]?.toString() ?? "",

      courseId:
      course != null && course.isNotEmpty
          ? _asInt(course.first)
          : _asInt(json["course_id"]),

      courseName:
      json["course_name"]?.toString() ??
          (course != null && course.length > 1
              ? course.last.toString()
              : ""),

      type: json["type"]?.toString() ?? "",

      grade: _asDouble(json["grade"]),

      comment: json["comment"]?.toString(),

      date:
      json["date"] != null
          ? DateTime.tryParse(
        json["date"].toString(),
      )
          : null,
    );
  }
}

// ============================================================================
// NOTES GROUPÉES PAR MATIÈRE
// ============================================================================

class CourseGrades {
  final int courseId;
  final String courseName;
  final double average;
  final List<GradeEntry> grades;

  const CourseGrades({
    required this.courseId,
    required this.courseName,
    required this.average,
    required this.grades,
  });

  factory CourseGrades.fromJson(Map<String, dynamic> json) {
    return CourseGrades(
      courseId: _asInt(json["course_id"]),

      courseName:
      json["course_name"]?.toString() ?? "",

      average:
      _asDouble(json["average"]),

      grades:
      (json["grades"] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => GradeEntry.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),
    );
  }
}

// ============================================================================
// NOTES GROUPÉES
// ============================================================================

class GroupedGrades {
  final List<CourseGrades> byCourse;

  const GroupedGrades({
    required this.byCourse,
  });

  factory GroupedGrades.fromJson(Map<String, dynamic> json) {
    return GroupedGrades(
      byCourse:
      (json["by_course"] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => CourseGrades.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),
    );
  }
}

// ============================================================================
// CRÉNEAU D'EMPLOI DU TEMPS
// ============================================================================

class CoursSlot {
  final int id;

  final int courseId;

  final String courseName;

  final int? teacherId;

  final String? teacherName;

  final String day;

  final String startTime;

  final String endTime;

  final String? room;

  final String? type;

  final DateTime? startDatetime;

  final DateTime? endDatetime;

  final bool isToday;

  const CoursSlot({
    required this.id,
    required this.courseId,
    required this.courseName,
    this.teacherId,
    this.teacherName,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.room,
    this.type,
    this.startDatetime,
    this.endDatetime,
    required this.isToday,
  });

  factory CoursSlot.fromJson(Map<String, dynamic> json) {
    /*
     * Le middleware peut retourner :
     *
     * "course_id": [3, "Mathématiques"]
     *
     * OU :
     *
     * "course": {
     *    "id": 3,
     *    "name": "Mathématiques"
     * }
     */

    final course =
    json["course_id"] is List
        ? json["course_id"] as List
        : null;

    final teacher =
    json["teacher_id"] is List
        ? json["teacher_id"] as List
        : null;

    final courseInfo =
    json["course"] is Map
        ? Map<String, dynamic>.from(
      json["course"] as Map,
    )
        : null;

    final teacherInfo =
    json["teacher"] is Map
        ? Map<String, dynamic>.from(
      json["teacher"] as Map,
    )
        : null;

    /*
     * ID du cours
     */

    final int courseId =
    course != null && course.isNotEmpty
        ? _asInt(course.first)
        : _asInt(courseInfo?["id"]);

    /*
     * Nom du cours
     */

    final String courseName =
    course != null && course.length > 1
        ? course.last.toString()
        : courseInfo?["name"]?.toString() ??
        json["course_name"]?.toString() ??
        json["name"]?.toString() ??
        "Cours";

    /*
     * ID du professeur
     */

    final int? teacherId =
    teacher != null && teacher.isNotEmpty
        ? _nullableInt(teacher.first)
        : _nullableInt(teacherInfo?["id"]);

    /*
     * Nom du professeur
     */

    final String? teacherName =
    teacher != null && teacher.length > 1
        ? teacher.last.toString()
        : teacherInfo?["name"]?.toString() ??
        json["teacher_name"]?.toString();

    return CoursSlot(
      id: _asInt(json["id"]),

      courseId: courseId,

      courseName: courseName,

      teacherId: teacherId,

      teacherName: teacherName,

      day: json["day"]?.toString() ?? "",

      startTime:
      json["start_time"]?.toString() ??
          json["startTime"]?.toString() ??
          "",

      endTime:
      json["end_time"]?.toString() ??
          json["endTime"]?.toString() ??
          "",

      room: json["room"]?.toString(),

      type: json["type"]?.toString(),

      startDatetime:
      json["start_datetime"] != null
          ? DateTime.tryParse(
        json["start_datetime"].toString(),
      )
          : null,

      endDatetime:
      json["end_datetime"] != null
          ? DateTime.tryParse(
        json["end_datetime"].toString(),
      )
          : null,

      isToday:
      json["is_today"] == true ||
          json["is_today"]?.toString().toLowerCase() == "true",
    );
  }
}

// ============================================================================
// JOURNÉE DE L'EMPLOI DU TEMPS
// ============================================================================

class TimetableDay {
  final String day;

  final List<CoursSlot> slots;

  const TimetableDay({
    required this.day,
    required this.slots,
  });

  factory TimetableDay.fromJson(
      Map<String, dynamic> json,
      ) {
    return TimetableDay(
      day: json["day"]?.toString() ?? "",

      slots:
      (json["slots"] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => CoursSlot.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),
    );
  }
}

// ============================================================================
// EMPLOI DU TEMPS COMPLET
// ============================================================================

class TimetableData {
  final int studentId;

  final String studentName;

  final List<TimetableDay> timetable;

  final String? timetableName;

  const TimetableData({
    required this.studentId,
    required this.studentName,
    required this.timetable,
    this.timetableName,
  });

  // --------------------------------------------------------------------------
  // PARSING JSON
  // --------------------------------------------------------------------------

  factory TimetableData.fromJson(
      Map<String, dynamic> json,
      ) {
    /*
     * ============================================================
     * STRUCTURE RENVOYÉE PAR DJANGO
     * ============================================================
     *
     * {
     *   "success": true,
     *   "message": "...",
     *   "filters": {
     *      "student_id": 18,
     *      "period": "week",
     *      "date": null
     *   },
     *   "data": [
     *      {
     *         "id": 1,
     *         "day": "monday",
     *         "start_time": "08:00",
     *         "end_time": "10:00",
     *         "course": {
     *             "id": 1,
     *             "name": "Mathématiques"
     *         },
     *         "teacher": {
     *             "id": 12,
     *             "name": "Ngaleu Frank"
     *         }
     *      }
     *   ]
     * }
     *
     * Le middleware renvoie donc une LISTE directement dans "data".
     *
     * Il ne renvoie pas :
     *
     * "data": {
     *    "slots": [...]
     * }
     */

    dynamic payload = json["data"] ?? json;

    // Liste brute des créneaux.
    List<dynamic> rawSlots = [];

    /*
     * ============================================================
     * CAS 1 : data est directement une LISTE
     * ============================================================
     */

    if (payload is List) {
      rawSlots = payload;
    }

    /*
     * ============================================================
     * CAS 2 : compatibilité avec une future réponse :
     *
     * "data": {
     *     "slots": [...]
     * }
     * ============================================================
     */

    Map<String, dynamic>? payloadMap;

    if (payload is Map) {
      payloadMap = Map<String, dynamic>.from(
        payload,
      );

      final slots = payloadMap["slots"];

      if (slots is List) {
        rawSlots = slots;
      }
    }

    /*
     * ============================================================
     * CONVERSION DES CRÉNEAUX
     * ============================================================
     */

    final List<CoursSlot> slots =
    rawSlots
        .whereType<Map>()
        .map(
          (slot) => CoursSlot.fromJson(
        Map<String, dynamic>.from(slot),
      ),
    )
        .toList();

    /*
     * ============================================================
     * RÉCUPÉRER LES INFORMATIONS DE L'ÉLÈVE
     * ============================================================
     */

    Map<String, dynamic>? student;

    if (payloadMap != null &&
        payloadMap["student"] is Map) {
      student = Map<String, dynamic>.from(
        payloadMap["student"] as Map,
      );
    }

    /*
     * ============================================================
     * REGROUPER LES CRÉNEAUX PAR JOUR
     * ============================================================
     *
     * Exemple :
     *
     * lundi:
     *   - Mathématiques
     *   - Français
     *
     * mardi:
     *   - Anglais
     *
     * mercredi:
     *   - Physique
     */

    final Map<String, List<CoursSlot>> slotsByDay = {};

    for (final slot in slots) {
      final day = slot.day.trim();

      if (day.isEmpty) {
        continue;
      }

      slotsByDay.putIfAbsent(
        day,
            () => [],
      );

      slotsByDay[day]!.add(slot);
    }

    /*
     * ============================================================
     * RÉCUPÉRER LE NOM DE L'EMPLOI DU TEMPS
     * ============================================================
     */

    String? timetableName;

    if (payloadMap != null &&
        payloadMap["timetable"] is Map) {
      final timetableInfo =
      Map<String, dynamic>.from(
        payloadMap["timetable"] as Map,
      );

      timetableName =
          timetableInfo["name"]?.toString();
    }

    /*
     * ============================================================
     * CONSTRUIRE LE MODÈLE FINAL
     * ============================================================
     */

    return TimetableData(
      /*
       * L'ID peut être présent dans "student".
       */

      studentId:
      _asInt(
        student?["id"],
      ),

      /*
       * Nom de l'élève.
       */

      studentName:
      student?["name"]?.toString() ?? "",

      /*
       * Les créneaux sont maintenant regroupés par jour.
       */

      timetable:
      slotsByDay.entries.map(
            (entry) {
          return TimetableDay(
            day: entry.key,
            slots: entry.value,
          );
        },
      ).toList(),

      timetableName: timetableName,
    );
  }
}

// ============================================================================
// PAIEMENT
// ============================================================================

class Paiement {
  final int invoiceId;
  final String invoiceNumber;
  final String feeName;
  final double amount;
  final double residual;
  final String paymentState;
  final DateTime invoiceDate;
  final DateTime? dueDate;

  const Paiement({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.feeName,
    required this.amount,
    required this.residual,
    required this.paymentState,
    required this.invoiceDate,
    this.dueDate,
  });

  factory Paiement.fromJson(
      Map<String, dynamic> json,
      ) {
    final fee =
    json["fee_id"] is List
        ? json["fee_id"] as List
        : null;

    return Paiement(
      invoiceId:
      _asInt(
        json["id"] ??
            json["invoice_id"],
      ),

      invoiceNumber:
      json["name"]?.toString() ??
          json["invoice_number"]?.toString() ??
          "",

      feeName:
      fee != null && fee.length > 1
          ? fee[1].toString()
          : json["fee_name"]?.toString() ??
          "Facture scolaire",

      amount:
      _asDouble(
        json["amount_total"] ??
            json["amount"],
      ),

      residual:
      _asDouble(
        json["amount_residual"] ??
            json["residual"],
      ),

      paymentState:
      json["payment_state"]?.toString() ??
          "",

      invoiceDate:
      DateTime.tryParse(
        json["invoice_date"]?.toString() ??
            "",
      ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
          ),

      dueDate:
      json["invoice_date_due"] != null
          ? DateTime.tryParse(
        json["invoice_date_due"].toString(),
      )
          : json["due_date"] != null
          ? DateTime.tryParse(
        json["due_date"].toString(),
      )
          : null,
    );
  }

  bool get isPaid =>
      paymentState == "paid";

  bool get isUnpaid =>
      const {
        "unpaid",
        "not_paid",
        "in_payment",
      }.contains(paymentState);

  bool get isPartial =>
      paymentState == "partial";
}

// ============================================================================
// HEALTH CHECK
// ============================================================================

class HealthCheckResult {
  final String status;

  final String database;

  final String odoo;

  final String message;

  const HealthCheckResult({
    required this.status,
    required this.database,
    required this.odoo,
    required this.message,
  });

  factory HealthCheckResult.fromJson(
      Map<String, dynamic> json,
      ) {
    return HealthCheckResult(
      status:
      json["status"]?.toString() ??
          "error",

      database:
      json["database"]?.toString() ??
          "error",

      odoo:
      json["odoo"]?.toString() ??
          "error",

      message:
      json["message"]?.toString() ??
          "",
    );
  }

  bool get isHealthy =>
      status == "ok";

  bool get isDatabaseOk =>
      database == "ok";

  bool get isOdooOk =>
      odoo == "ok";
}

// ============================================================================
// DASHBOARD ENFANT
// ============================================================================

class ChildDashboard {
  final List<AbsenceEntry> absences;

  final List<GradeEntry> grades;

  final List<Paiement> payments;

  final TimetableData timetable;

  const ChildDashboard({
    this.absences = const [],
    this.grades = const [],
    this.payments = const [],

    this.timetable = const TimetableData(
      studentId: 0,
      studentName: "",
      timetable: [],
    ),
  });

  // --------------------------------------------------------------------------
  // TOTAL À PAYER
  // --------------------------------------------------------------------------

  double get totalAPayer {
    return payments.fold(
      0,
          (sum, paiement) {
        return sum + paiement.residual;
      },
    );
  }

  // --------------------------------------------------------------------------
  // TOTAL HEURES D'ABSENCE
  // --------------------------------------------------------------------------

  double get totalHeuresAbsentes {
    double total = 0;

    for (final absence in absences) {
      if (absence.isAbsent &&
          absence.endDate != null) {
        total +=
            absence.endDate!
                .difference(
              absence.startDate,
            )
                .inMinutes /
                60.0;
      }
    }

    return total;
  }

  // --------------------------------------------------------------------------
  // TOTAL JOURS D'ABSENCE
  // --------------------------------------------------------------------------

  int get totalJoursAbsents {
    return absences
        .where(
          (e) => e.isAbsent,
    )
        .length;
  }

  // --------------------------------------------------------------------------
  // TOTAL RETARDS
  // --------------------------------------------------------------------------

  int get totalRetards {
    return absences
        .where(
          (e) => e.isLate,
    )
        .length;
  }

  // --------------------------------------------------------------------------
  // STATISTIQUES DU MOIS
  // --------------------------------------------------------------------------

  Map<String, dynamic> get statsMoisEnCours {
    final now = DateTime.now();

    final moisAbsences =
    absences.where(
          (e) =>
      e.startDate.month ==
          now.month &&
          e.startDate.year ==
              now.year,
    ).toList();

    double heures = 0;

    int jours = 0;

    int retards = 0;

    for (final absence in moisAbsences) {
      if (absence.isAbsent) {
        jours++;

        if (absence.endDate != null) {
          heures +=
              absence.endDate!
                  .difference(
                absence.startDate,
              )
                  .inMinutes /
                  60.0;
        }
      } else if (absence.isLate) {
        retards++;
      }
    }

    return {
      "heures": heures,
      "jours": jours,
      "retards": retards,
    };
  }

  // --------------------------------------------------------------------------
  // DASHBOARD VIDE
  // --------------------------------------------------------------------------

  static const empty =
  ChildDashboard();

  // --------------------------------------------------------------------------
  // FROM JSON
  // --------------------------------------------------------------------------

  factory ChildDashboard.fromJson(
      Map<String, dynamic> json,
      ) {
    return ChildDashboard(
      absences:
      (json["absences"] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => AbsenceEntry.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),

      grades:
      (json["grades"] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => GradeEntry.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),

      payments:
      (json["payments"] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => Paiement.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),

      timetable:
      json["timetable"] != null
          ? TimetableData.fromJson(
        Map<String, dynamic>.from(
          json["timetable"],
        ),
      )
          : const TimetableData(
        studentId: 0,
        studentName: "",
        timetable: [],
      ),
    );
  }
}

// ============================================================================
// UTILITAIRES
// ============================================================================

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is double) {
    return value.toInt();
  }

  return int.tryParse(
    value?.toString() ?? "",
  ) ??
      0;
}

int? _nullableInt(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  if (value is double) {
    return value.toInt();
  }

  return int.tryParse(
    value.toString(),
  );
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value?.toString() ?? "",
  ) ??
      0;
}