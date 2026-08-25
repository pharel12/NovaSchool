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
    final student = json["student_id"] is List ? json["student_id"] as List : null;
    final teacher = json["teacher_id"] is List ? json["teacher_id"] as List : null;

    return AbsenceEntry(
      id: json["id"] ?? 0,
      studentId: student?.first as int? ?? 0,
      studentName: student != null ? student.last.toString() : "",
      teacherId: teacher?.first as int?,
      teacherName: teacher != null ? teacher.last.toString() : null,
      status: json["status"]?.toString() ?? "",
      comment: json["comment"]?.toString(),
      // Odoo peut retourner une date vide pour un enregistrement en cours.
      // Une valeur de repli évite de bloquer tout l'écran d'absences.
      startDate: DateTime.tryParse(json["start_datetime"]?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate: json["end_datetime"] != null
          ? DateTime.tryParse(json["end_datetime"].toString())
          : null,
    );
  }

  bool get isAbsent => status == "absent";

  bool get isLate => status == "late";

  bool get isPresent => status == "present";
}

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
    final evaluation = json["evaluation_id"] as List?;
    final course = json["course_id"] as List?;

    return GradeEntry(
      id: json["id"] ?? 0,
      evaluationId: evaluation != null ? evaluation.first as int : 0,
      evaluationName:
      evaluation != null ? evaluation.last.toString() : "",
      courseId: course != null ? course.first as int : 0,
      courseName: json["course_name"] ??
          (course != null ? course.last.toString() : ""),
      type: json["type"]?.toString() ?? "",
      grade: (json["grade"] ?? 0).toDouble(),
      comment: json["comment"]?.toString(),
      date: json["date"] != null
          ? DateTime.tryParse(json["date"])
          : null,
    );
  }
}

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
courseId: json['course_id'] ?? 0,
courseName: json['course_name'] ?? '',
average: (json['average'] ?? 0).toDouble(),
grades: (json['grades'] as List? ?? [])
    .map((e) => GradeEntry.fromJson(Map<String, dynamic>.from(e)))
    .toList(),
);
}
}

class GroupedGrades {
final List<CourseGrades> byCourse;

const GroupedGrades({
required this.byCourse,
});

factory GroupedGrades.fromJson(Map<String, dynamic> json) {
return GroupedGrades(
byCourse: (json['by_course'] as List? ?? [])
    .map((e) => CourseGrades.fromJson(Map<String, dynamic>.from(e)))
    .toList(),
);
}
}

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
    final course = json["course_id"] as List?;
    final teacher = json["teacher_id"] as List?;
    final courseInfo = json['course'] as Map?;
    final teacherInfo = json['teacher'] as Map?;

    return CoursSlot(
      id: json["id"] ?? 0,
      courseId: course != null ? course.first as int : (courseInfo?['id'] as int? ?? 0),
      courseName: course != null ? course.last.toString() : (courseInfo?['name']?.toString() ?? json['name']?.toString() ?? ''),
      teacherId: teacher != null ? teacher.first as int : teacherInfo?['id'] as int?,
      teacherName: teacher != null ? teacher.last.toString() : teacherInfo?['name']?.toString(),
      day: json["day"]?.toString() ?? "",
      startTime: json["start_time"]?.toString() ?? "",
      endTime: json["end_time"]?.toString() ?? "",
      room: json["room"]?.toString(),
      type: json["type"]?.toString(),
      startDatetime: json["start_datetime"] != null 
          ? DateTime.tryParse(json["start_datetime"].toString()) 
          : null,
      endDatetime: json["end_datetime"] != null 
          ? DateTime.tryParse(json["end_datetime"].toString()) 
          : null,
      isToday: json["is_today"] ?? false,
    );
  }
}


class TimetableDay {
  final String day;
  final List<CoursSlot> slots;

  const TimetableDay({
    required this.day,
    required this.slots,
  });

  factory TimetableDay.fromJson(Map<String, dynamic> json) {
    return TimetableDay(
      day: json["day"]?.toString() ?? "",
      slots: (json["slots"] as List<dynamic>? ?? [])
          .map((e) => CoursSlot.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class TimetableData {
  final int studentId;
  final String studentName;
  final List<TimetableDay> timetable;

  /// Métadonnées du planning renvoyées par le middleware (peuvent être nulles
  /// lorsqu'aucun planning n'est encore défini pour la classe).
  final String? timetableName;

  const TimetableData({
    required this.studentId,
    required this.studentName,
    required this.timetable,
    this.timetableName,
  });

  factory TimetableData.fromJson(Map<String, dynamic> json) {
    // StudentTimetableView enveloppe le planning dans { success, data, filters }.
    final payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final student = payload["student"] as Map?;
    final timetableInfo = payload["timetable"] as Map?;
    final slots = (payload["slots"] as List? ?? const [])
        .whereType<Map>()
        .map((slot) => CoursSlot.fromJson(Map<String, dynamic>.from(slot)))
        .toList();

    // Le middleware renvoie une liste plate de créneaux. L'interface Flutter
    // utilise des journées : on recompose donc ce format ici, à une seule place.
    final slotsByDay = <String, List<CoursSlot>>{};
    for (final slot in slots) {
      slotsByDay.putIfAbsent(slot.day, () => []).add(slot);
    }

    return TimetableData(
      studentId: int.tryParse(student?["id"]?.toString() ?? '') ?? 0,
      studentName: student?["name"]?.toString() ?? "",
      timetable: slotsByDay.entries
          .map((entry) => TimetableDay(day: entry.key, slots: entry.value))
          .toList(),
      timetableName: timetableInfo?["name"]?.toString(),
    );
  }
}

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


  factory Paiement.fromJson(Map<String, dynamic> json) {
    final fee = json['fee_id'] as List?;
    return Paiement(
      // Les deux conventions sont supportées pour garder l'application
      // compatible avec les réponses Odoo et les anciennes maquettes API.
      invoiceId: _asInt(json["id"] ?? json["invoice_id"]),
      invoiceNumber: json["name"]?.toString() ??
          json["invoice_number"]?.toString() ?? "",
      feeName: fee != null && fee.length > 1
          ? fee[1].toString()
          : json["fee_name"]?.toString() ?? "Facture scolaire",
      amount: _asDouble(json["amount_total"] ?? json["amount"]),
      residual: _asDouble(json["amount_residual"] ?? json["residual"]),
      paymentState: json["payment_state"]?.toString() ?? "",
      // Les factures brouillon n'ont pas toujours de date : le modèle reste
      // affichable au lieu de faire échouer le tableau de bord.
      invoiceDate: DateTime.tryParse(
            json["invoice_date"]?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      dueDate: json["invoice_date_due"] != null
          ? DateTime.tryParse(json["invoice_date_due"].toString())
          : json["due_date"] != null
              ? DateTime.tryParse(json["due_date"].toString())
          : null,
    );
  }

  bool get isPaid => paymentState == "paid";

  bool get isUnpaid =>
      const {'unpaid', 'not_paid', 'in_payment'}.contains(paymentState);

  bool get isPartial => paymentState == "partial";
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;

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

factory HealthCheckResult.fromJson(Map<String, dynamic> json) {
return HealthCheckResult(
status: json['status'] ?? 'error',
database: json['database'] ?? 'error',
odoo: json['odoo'] ?? 'error',
message: json['message'] ?? '',
);
}

bool get isHealthy => status == 'ok';
bool get isDatabaseOk => database == 'ok';
bool get isOdooOk => odoo == 'ok';
}

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
  double get totalAPayer =>
      payments.fold(
        0,
            (sum, paiement) => sum + paiement.residual,
      );

  double get totalHeuresAbsentes {
    double total = 0;
    for (var absence in absences) {
      if (absence.isAbsent && absence.endDate != null) {
        total += absence.endDate!.difference(absence.startDate).inMinutes / 60.0;
      }
    }
    return total;
  }

  /// Retourne le nombre total de jours d'absence (entrées marquées 'absent')
  int get totalJoursAbsents => absences.where((e) => e.isAbsent).length;

  /// Retourne le nombre total de retards
  int get totalRetards => absences.where((e) => e.isLate).length;

  /// Calcule les statistiques pour le mois en cours
  Map<String, dynamic> get statsMoisEnCours {
    final now = DateTime.now();
    final moisAbsences = absences.where((e) => e.startDate.month == now.month && e.startDate.year == now.year).toList();
    
    double heures = 0;
    int jours = 0;
    int retards = 0;

    for (var a in moisAbsences) {
      if (a.isAbsent) {
        jours++;
        if (a.endDate != null) {
          heures += a.endDate!.difference(a.startDate).inMinutes / 60.0;
        }
      } else if (a.isLate) {
        retards++;
      }
    }

    return {
      'heures': heures,
      'jours': jours,
      'retards': retards,
    };
  }

  static const empty = ChildDashboard();

  factory ChildDashboard.fromJson(Map<String, dynamic> json) {
    return ChildDashboard(
      absences: (json["absences"] as List<dynamic>? ?? [])
          .map(
            (e) => AbsenceEntry.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),

      grades: (json["grades"] as List<dynamic>? ?? [])
          .map(
            (e) => GradeEntry.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),

      payments: (json["payments"] as List<dynamic>? ?? [])
          .map(
            (e) => Paiement.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),

      timetable: json["timetable"] != null
          ? TimetableData.fromJson(
        Map<String, dynamic>.from(json["timetable"]),
      )
          : const TimetableData(
        studentId: 0,
        studentName: "",
        timetable: [],
      ),
    );
  }
}

