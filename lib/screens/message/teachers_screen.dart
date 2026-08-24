import 'package:flutter/material.dart';

import 'package:novaschool/models/teacher_model.dart';
import 'package:novaschool/services/teacher_service.dart';

import 'chat_screen.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TeacherService _service = TeacherService();

  late Future<List<TeacherModel>> _future;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  // ============================================================
  // CHARGEMENT DES ENSEIGNANTS
  // ============================================================

  void _loadTeachers() {
    _future = _service.getTeachers();
  }

  // ============================================================
  // RECHERCHE
  // ============================================================

  List<TeacherModel> _filterTeachers(
      List<TeacherModel> teachers,
      ) {
    if (_query.trim().isEmpty) {
      return teachers;
    }

    final query = _query.trim().toLowerCase();

    return teachers.where((teacher) {
      final name = teacher.username.toLowerCase();

      final courses = teacher.courses.any(
            (course) =>
            course.courseName.toLowerCase().contains(query),
      );

      return name.contains(query) || courses;
    }).toList();
  }

  // ============================================================
  // OUVRIR UNE CONVERSATION
  // ============================================================

  void _openChat(TeacherModel teacher) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          teacher: teacher,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // HEADER
            // ==================================================

            _buildHeader(),

            // ==================================================
            // RECHERCHE
            // ==================================================

            _buildSearch(),

            // ==================================================
            // LISTE DES ENSEIGNANTS
            // ==================================================

            Expanded(
              child: FutureBuilder<List<TeacherModel>>(
                future: _future,

                builder: (context, snapshot) {

                  // -------------------------------
                  // CHARGEMENT
                  // -------------------------------

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF155EEF),
                      ),
                    );
                  }

                  // -------------------------------
                  // ERREUR
                  // -------------------------------

                  if (snapshot.hasError) {
                    return _buildError();
                  }

                  final teachers =
                  _filterTeachers(snapshot.data ?? []);

                  // -------------------------------
                  // AUCUN ENSEIGNANT
                  // -------------------------------

                  if (teachers.isEmpty) {
                    return _buildEmpty();
                  }

                  // -------------------------------
                  // LISTE
                  // -------------------------------

                  return RefreshIndicator(
                    color: const Color(0xFF155EEF),

                    onRefresh: () async {
                      setState(() {
                        _loadTeachers();
                      });

                      await _future;
                    },

                    child: ListView.separated(
                      physics:
                      const AlwaysScrollableScrollPhysics(),

                      padding: const EdgeInsets.fromLTRB(
                        18,
                        8,
                        18,
                        25,
                      ),

                      itemCount: teachers.length,

                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),

                      itemBuilder: (context, index) {

                        final teacher = teachers[index];

                        return TeacherContactCard(
                          teacher: teacher,
                          onTap: () => _openChat(teacher),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        20,
        26,
        20,
        28,
      ),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF123D92),
            Color(0xFF1E5FE8),
          ],
        ),

        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(26),
        ),
      ),

      child: Row(
        children: [

          const Expanded(
            child: Text(
              'Enseignants',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),

              border: Border.all(
                color: Colors.white54,
              ),

              borderRadius: BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BARRE DE RECHERCHE
  // ============================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        10,
      ),

      child: TextField(
        onChanged: (value) {
          setState(() {
            _query = value;
          });
        },

        decoration: InputDecoration(
          hintText: 'Rechercher un enseignant...',

          hintStyle: const TextStyle(
            color: Color(0xFF7A8499),
            fontSize: 13,
          ),

          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF7A8499),
          ),

          filled: true,
          fillColor: Colors.white,

          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 2,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF155EEF),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERREUR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Container(
              width: 65,
              height: 65,

              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFFF0444A),
                size: 32,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Impossible de charger les enseignants.',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Vérifiez votre connexion puis réessayez.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Color(0xFF7A8499),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadTeachers();
                });
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF155EEF),

                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),

              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AUCUN CONTACT
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(22),
            ),

            child: const Icon(
              Icons.people_outline_rounded,
              color: Color(0xFF155EEF),
              size: 35,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            _query.isEmpty
                ? 'Aucun enseignant disponible.'
                : 'Aucun enseignant trouvé.',

            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Les enseignants associés à vos enfants apparaîtront ici.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Color(0xFF7A8499),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CARTE CONTACT ENSEIGNANT
// ================================================================

class TeacherContactCard extends StatelessWidget {
  final TeacherModel teacher;
  final VoidCallback onTap;

  const TeacherContactCard({
    super.key,
    required this.teacher,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final String subject =
    teacher.courses.isEmpty
        ? 'Enseignant'
        : teacher.courses.first.courseName;

    final String name =
    teacher.username.trim().isEmpty
        ? 'Enseignant'
        : teacher.username.trim();

    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(16),

      elevation: 0,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: const Color(0xFFE7EAF1),
            ),
          ),

          child: Row(
            children: [

              // ==================================================
              // PHOTO
              // ==================================================

              _TeacherAvatar(
                teacher: teacher,
                name: name,
              ),

              const SizedBox(width: 13),

              // ==================================================
              // INFORMATIONS
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      name,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101828),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subject,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Color(0xFF4E5B75),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: const [

                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 13,
                          color: Color(0xFF155EEF),
                        ),

                        SizedBox(width: 5),

                        Text(
                          'Appuyez pour discuter',
                          style: TextStyle(
                            color: Color(0xFF7A8499),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ==================================================
              // FLÈCHE
              // ==================================================

              const SizedBox(width: 8),

              Container(
                width: 32,
                height: 32,

                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5FC),
                  borderRadius: BorderRadius.circular(9),
                ),

                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF155EEF),
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// AVATAR ENSEIGNANT
// ================================================================

class _TeacherAvatar extends StatelessWidget {
  final TeacherModel teacher;
  final String name;

  const _TeacherAvatar({
    required this.teacher,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {

    final hasAvatar =
        teacher.avatar != null &&
            teacher.avatar!.trim().isNotEmpty;

    return CircleAvatar(
      radius: 27,

      backgroundColor: const Color(0xFFE8EEFF),

      backgroundImage:
      hasAvatar
          ? NetworkImage(
        teacher.avatar!,
      )
          : null,

      child: hasAvatar
          ? null
          : Text(
        name.isNotEmpty
            ? name.substring(0, 1).toUpperCase()
            : '?',

        style: const TextStyle(
          color: Color(0xFF155EEF),
          fontWeight: FontWeight.w800,
          fontSize: 17,
        ),
      ),
    );
  }
}