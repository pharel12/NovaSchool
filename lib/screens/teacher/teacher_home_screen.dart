import 'package:flutter/material.dart';

import '../../widgets/teacher/teacher_ui.dart';
import 'teacher_chat_list_screen.dart';
import 'teacher_mark_absence_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherChatListScreen(),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherMarkAbsenceScreen(),
          ),
        );
        break;

      default:
        break;
    }
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
        currentIndex: 0,
        onTap: (index) {
          _navigate(context, index);
        },
      ),

      // ----------------------------------------------------------
      // CONTENU
      // ----------------------------------------------------------

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            20,
          ),
          children: [
            _buildHeader(),

            const SizedBox(height: 22),

            _buildWelcome(),

            const SizedBox(height: 20),

            _buildStatistics(),

            const SizedBox(height: 16),

            _buildTodaySection(),

            const SizedBox(height: 16),

            _buildTasksSection(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.menu_rounded,
          color: TeacherUi.ink,
        ),

        const SizedBox(width: 15),

        const Icon(
          Icons.auto_awesome_mosaic_rounded,
          color: TeacherUi.blue,
          size: 23,
        ),

        const SizedBox(width: 6),

        const Text(
          'Nova',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: TeacherUi.ink,
          ),
        ),

        const Text(
          'School',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: TeacherUi.blue,
          ),
        ),

        const Spacer(),

        _buildNotificationButton(),
      ],
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Widget _buildNotificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(
          Icons.notifications_none_rounded,
          size: 27,
          color: TeacherUi.ink,
        ),

        Positioned(
          right: -2,
          top: -3,
          child: _Badge(
            '3',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MESSAGE DE BIENVENUE
  // ============================================================

  Widget _buildWelcome() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, M. Dupont 👋',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: TeacherUi.ink,
          ),
        ),

        SizedBox(height: 6),

        Text(
          "Voici un aperçu de votre activité aujourd'hui.",
          style: TextStyle(
            color: TeacherUi.muted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTIQUES
  // ============================================================

  Widget _buildStatistics() {
    return const Row(
      children: [
        Expanded(
          child: _Stat(
            icon: Icons.groups_outlined,
            value: '3',
            label: 'Classes',
            color: TeacherUi.blue,
          ),
        ),

        SizedBox(width: 10),

        Expanded(
          child: _Stat(
            icon: Icons.group_outlined,
            value: '78',
            label: 'Élèves',
            color: Color(0xFF20B967),
          ),
        ),

        SizedBox(width: 10),

        Expanded(
          child: _Stat(
            icon: Icons.chat_bubble_outline_rounded,
            value: '6',
            label: 'Messages',
            color: Color(0xFFF0444A),
            badge: '2',
          ),
        ),

        SizedBox(width: 10),

        Expanded(
          child: _Stat(
            icon: Icons.assignment_outlined,
            value: '5',
            label: 'Devoirs\nà corriger',
            color: Color(0xFFFF9D19),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION "AUJOURD'HUI"
  // ============================================================

  Widget _buildTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "Aujourd'hui",
          action: 'Voir tout',
        ),

        const SizedBox(height: 9),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: TeacherUi.cardDecoration(),
          child: const Column(
            children: [
              _Course(
                'Mathématiques - 4ème A',
                '08:00 - 09:00',
                'Dans 20 min',
              ),

              _Course(
                'Mathématiques - 4ème B',
                '10:00 - 11:00',
                null,
              ),

              _Course(
                'Mathématiques - 3ème A',
                '14:00 - 15:00',
                null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION "À FAIRE"
  // ============================================================

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À faire',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: TeacherUi.ink,
          ),
        ),

        const SizedBox(height: 9),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: TeacherUi.cardDecoration(),
          child: Column(
            children: [
              const _Task(
                'Corriger les devoirs de 4ème A',
                'Prioritaire',
                Color(0xFFFDE7E8),
              ),

              const _Task(
                'Préparer le cours de demain',
                'Important',
                Color(0xFFFFF1DD),
              ),

              _Task(
                'Répondre aux messages',
                null,
                Colors.transparent,
                onTap: () {
                  // Navigation vers la messagerie
                  // Elle sera effectuée depuis le contexte parent.
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// BADGE
// ============================================================================

class _Badge extends StatelessWidget {
  final String text;

  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFF0444A),
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
        ),
      ),
    );
  }
}

// ============================================================================
// STATISTIQUE
// ============================================================================

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? badge;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 5,
      ),
      decoration: TeacherUi.cardDecoration(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              TeacherUi.iconTile(
                icon,
                color: color,
                size: 21,
              ),

              if (badge != null)
                Positioned(
                  right: -3,
                  top: -3,
                  child: _Badge(
                    badge!,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: TeacherUi.ink,
            ),
          ),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              height: 1.25,
              color: TeacherUi.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EN-TÊTE DE SECTION
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;

  const _SectionHeader({
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: TeacherUi.ink,
          ),
        ),

        const Spacer(),

        Text(
          action,
          style: const TextStyle(
            fontSize: 12,
            color: TeacherUi.blue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// COURS
// ============================================================================

class _Course extends StatelessWidget {
  final String title;
  final String time;
  final String? tag;

  const _Course(
      this.title,
      this.time,
      this.tag,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          TeacherUi.iconTile(
            Icons.calendar_today_outlined,
            size: 18,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: TeacherUi.ink,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: TeacherUi.muted,
                  ),
                ),
              ],
            ),
          ),

          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F8E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tag!,
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF129747),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// TÂCHE
// ============================================================================

class _Task extends StatelessWidget {
  final String title;
  final String? tag;
  final Color tagColor;
  final VoidCallback? onTap;

  const _Task(
      this.title,
      this.tag,
      this.tagColor, {
        this.onTap,
      });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 7,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_box_outline_blank_rounded,
              size: 17,
              color: TeacherUi.muted,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: TeacherUi.ink,
                ),
              ),
            ),

            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag!,
                  style: TextStyle(
                    fontSize: 9,
                    color: tag == 'Prioritaire'
                        ? const Color(0xFFD92D35)
                        : const Color(0xFFE47700),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}