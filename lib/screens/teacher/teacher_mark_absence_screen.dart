import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../../services/teacher_service.dart';
import '../../widgets/teacher/teacher_ui.dart';
import 'teacher_chat_list_screen.dart';
import 'teacher_home_screen.dart';

class TeacherMarkAbsenceScreen extends StatefulWidget {
  const TeacherMarkAbsenceScreen({super.key});

  @override
  State<TeacherMarkAbsenceScreen> createState() =>
      _TeacherMarkAbsenceScreenState();
}

class _TeacherMarkAbsenceScreenState
    extends State<TeacherMarkAbsenceScreen> {
  final TeacherService _service = TeacherService();

  late Future<List<ChildModel>> _future;

  /// Stocke le statut choisi pour chaque élève.
  ///
  /// Exemple :
  /// {
  ///   12: 'present',
  ///   15: 'absent',
  ///   18: 'late',
  /// }
  final Map<int, String> _status = {};

  @override
  void initState() {
    super.initState();

    _future = _service.getStudents();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigate(int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherHomeScreen(),
          ),
              (_) => false,
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherChatListScreen(),
          ),
        );
        break;

      default:
        break;
    }
  }

  // ============================================================
  // ENREGISTREMENT DES ABSENCES
  // ============================================================

  Future<void> _save(List<ChildModel> students) async {
    try {
      for (final student in students) {
        final status = _status[student.id];

        if (status == null) {
          continue;
        }

        await _service.markAbsence(
          studentId: student.id,
          status: status,
          startDate: DateTime.now(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Présences enregistrées avec succès',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue lors de l\'enregistrement',
          ),
        ),
      );
    }
  }

  // ============================================================
  // RÉCUPÉRATION DU STATUT D'UN ÉLÈVE
  // ============================================================

  String _getStudentStatus(ChildModel student) {
    return _status[student.id] ??
        (student.isPresent ? 'present' : 'absent');
  }

  // ============================================================
  // COMPTER LES PRÉSENCES / ABSENCES
  // ============================================================

  int _countStatus(
      List<ChildModel> students,
      String status,
      ) {
    return students.where(
          (student) => _getStudentStatus(student) == status,
    ).length;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeacherUi.canvas,

      // ----------------------------------------------------------
      // NAVIGATION DU BAS
      // ----------------------------------------------------------

      bottomNavigationBar: TeacherBottomNav(
        currentIndex: 3,
        onTap: _navigate,
      ),

      // ----------------------------------------------------------
      // CONTENU
      // ----------------------------------------------------------

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCourseHeader(),
            _buildTabs(),
            _buildStudentsContent(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        16,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: TeacherUi.ink,
              size: 20,
            ),
          ),

          const Text(
            'Absences',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: TeacherUi.ink,
            ),
          ),

          const Spacer(),

          TeacherUi.iconTile(
            Icons.calendar_today_outlined,
            size: 19,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATIONS DU COURS
  // ============================================================

  Widget _buildCourseHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3044D9),
              TeacherUi.blue,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              color: Colors.white,
              size: 29,
            ),

            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mathématiques - 4ème A',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Mardi 20 mai 2025',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    '08:00 - 09:00   |   Salle 12',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ONGLETS
  // ============================================================

  Widget _buildTabs() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _AttendanceTab(
              'Liste',
              true,
            ),
          ),

          Expanded(
            child: _AttendanceTab(
              'Résumé',
              false,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENU DES ÉLÈVES
  // ============================================================

  Widget _buildStudentsContent() {
    return Expanded(
      child: FutureBuilder<List<ChildModel>>(
        future: _future,
        builder: (
            BuildContext context,
            AsyncSnapshot<List<ChildModel>> snapshot,
            ) {
          // ------------------------------------------------------
          // CHARGEMENT
          // ------------------------------------------------------

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: TeacherUi.blue,
              ),
            );
          }

          // ------------------------------------------------------
          // ERREUR
          // ------------------------------------------------------

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Impossible de charger les élèves.',
              ),
            );
          }

          // ------------------------------------------------------
          // DONNÉES
          // ------------------------------------------------------

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'Aucun élève trouvé',
              ),
            );
          }

          // ------------------------------------------------------
          // COMPTEURS
          // ------------------------------------------------------

          final present = _countStatus(
            students,
            'present',
          );

          final absent = _countStatus(
            students,
            'absent',
          );

          final late = _countStatus(
            students,
            'late',
          );

          return Column(
            children: [
              _buildCounters(
                present: present,
                absent: absent,
                late: late,
              ),

              Expanded(
                child: _buildStudentList(
                  students,
                ),
              ),

              _buildSaveButton(
                students,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // COMPTEURS
  // ============================================================

  Widget _buildCounters({
    required int present,
    required int absent,
    required int late,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        12,
      ),
      child: Row(
        children: [
          _Count(
            '$present',
            'Présents',
            const Color(0xFFE7F8EB),
            const Color(0xFF16A34A),
          ),

          const SizedBox(width: 8),

          _Count(
            '$absent',
            'Absents',
            const Color(0xFFFFEAEC),
            const Color(0xFFE4323B),
          ),

          const SizedBox(width: 8),

          _Count(
            '$late',
            'Retards',
            const Color(0xFFFFF4E4),
            const Color(0xFFF28A13),
          ),

          const SizedBox(width: 8),

          const _Count(
            '—',
            'Justifiés',
            Color(0xFFF0F2FF),
            TeacherUi.blue,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LISTE DES ÉLÈVES
  // ============================================================

  Widget _buildStudentList(
      List<ChildModel> students,
      ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      itemCount: students.length + 1,
      itemBuilder: (
          BuildContext context,
          int index,
          ) {
        // ------------------------------------------------------
        // TITRE
        // ------------------------------------------------------

        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              "Marquer l'absence",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: TeacherUi.ink,
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // ÉLÈVE
        // ------------------------------------------------------

        final student = students[index - 1];

        final status = _getStudentStatus(
          student,
        );

        return _StudentRow(
          student: student,
          status: status,
          onChanged: (value) {
            setState(() {
              _status[student.id] = value;
            });
          },
        );
      },
    );
  }

  // ============================================================
  // BOUTON ENREGISTRER
  // ============================================================

  Widget _buildSaveButton(
      List<ChildModel> students,
      ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            _save(students);
          },
          icon: const Icon(
            Icons.save_outlined,
          ),
          label: const Text(
            'Enregistrer',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: TeacherUi.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ONGLET LISTE / RÉSUMÉ
// ============================================================================

class _AttendanceTab extends StatelessWidget {
  final String text;
  final bool active;

  const _AttendanceTab(
      this.text,
      this.active,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active
                ? TeacherUi.blue
                : TeacherUi.line,
            width: active ? 2 : 1,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active
              ? TeacherUi.blue
              : TeacherUi.muted,
          fontWeight: active
              ? FontWeight.w700
              : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ============================================================================
// COMPTEUR
// ============================================================================

class _Count extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color color;

  const _Count(
      this.value,
      this.label,
      this.bg,
      this.color,
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),

            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LIGNE D'UN ÉLÈVE
// ============================================================================

class _StudentRow extends StatelessWidget {
  final ChildModel student;
  final String status;
  final ValueChanged<String> onChanged;

  const _StudentRow({
    required this.student,
    required this.status,
    required this.onChanged,
  });

  // --------------------------------------------------------------------------
  // STYLE DU STATUT
  // --------------------------------------------------------------------------

  ({
  String label,
  Color color,
  Color bg,
  }) _getStatusStyle() {
    switch (status) {
      case 'absent':
        return (
        label: 'Absent',
        color: const Color(0xFFD92D35),
        bg: const Color(0xFFFFEAEC),
        );

      case 'late':
        return (
        label: 'Retard',
        color: const Color(0xFFF28A13),
        bg: const Color(0xFFFFF4E4),
        );

      case 'present':
      default:
        return (
        label: 'Présent',
        color: const Color(0xFF168A44),
        bg: const Color(0xFFE7F8EB),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStatusStyle();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          // ------------------------------------------------------------------
          // AVATAR
          // ------------------------------------------------------------------

          CircleAvatar(
            radius: 18,
            backgroundColor: TeacherUi.blue.withValues(
              alpha: .12,
            ),
            child: Text(
              student.initials,
              style: const TextStyle(
                fontSize: 11,
                color: TeacherUi.blue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 11),

          // ------------------------------------------------------------------
          // NOM DE L'ÉLÈVE
          // ------------------------------------------------------------------

          Expanded(
            child: Text(
              student.fullName,
              style: const TextStyle(
                fontSize: 13,
                color: TeacherUi.ink,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ------------------------------------------------------------------
          // MENU DU STATUT
          // ------------------------------------------------------------------

          PopupMenuButton<String>(
            onSelected: onChanged,
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'present',
                  child: Text(
                    'Présent',
                  ),
                ),
                PopupMenuItem(
                  value: 'absent',
                  child: Text(
                    'Absent',
                  ),
                ),
                PopupMenuItem(
                  value: 'late',
                  child: Text(
                    'Retard',
                  ),
                ),
              ];
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    style.label,
                    style: TextStyle(
                      color: style.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: TeacherUi.muted,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          // ------------------------------------------------------------------
          // MENU SUPPLÉMENTAIRE
          // ------------------------------------------------------------------

          const Icon(
            Icons.more_horiz_rounded,
            color: TeacherUi.muted,
          ),
        ],
      ),
    );
  }
}