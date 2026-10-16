import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../services/teacher_service.dart';
import '../../widgets/teacher/teacher_ui.dart';
import '../teacher/teacher_chat_list_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key, this.onNavigate});

  /// Switches tabs while retaining the teacher navigation shell.
  final ValueChanged<int>? onNavigate;

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final TeacherService _teacherService = TeacherService();

  Map<String, dynamic>? _dashboard;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ============================================================
  // CHARGEMENT DU DASHBOARD
  // ============================================================

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await _teacherService.getTeacherDashboard();

      if (!mounted) return;

      setState(() {
        _dashboard = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeacherUi.canvasColor(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: _buildBody(),
        ),
      ),
    );
  }

  // ============================================================
  // CORPS
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),

          const Icon(
            Icons.error_outline_rounded,
            size: 55,
            color: Color(0xFFF0444A),
          ),

          const SizedBox(height: 16),

          Text(
            'Impossible de charger le dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: TeacherUi.inkColor(context),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: TeacherUi.mutedColor(context),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton(
              onPressed: _loadDashboard,
              child: const Text('Réessayer'),
            ),
          ),
        ],
      );
    }

    if (_dashboard == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          Center(
            child: Text(
              'Aucune donnée disponible.',
              style: TextStyle(
                color: TeacherUi.mutedColor(context),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.menu_rounded,
          color: TeacherUi.inkColor(context),
        ),

        const SizedBox(width: 15),

        Image.asset(
          AppAssets.logo,
          width: 23,
          height: 23,
        ),

        const SizedBox(width: 6),

        Text(
          'Nova',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: TeacherUi.inkColor(context),
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
    final statistics =
    _dashboard?['statistics'] as Map<String, dynamic>?;

    final unreadMessages =
    _asInt(statistics?['unread_messages']);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.notifications_none_rounded,
          size: 27,
          color: TeacherUi.inkColor(context),
        ),

        if (unreadMessages > 0)
          Positioned(
            right: -2,
            top: -3,
            child: _Badge(
              unreadMessages.toString(),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // MESSAGE DE BIENVENUE
  // ============================================================

  Widget _buildWelcome() {
    final teacher =
    _dashboard?['teacher'] as Map<String, dynamic>?;

    final teacherName =
        teacher?['name']?.toString().trim() ?? '';

    final displayName =
    teacherName.isNotEmpty ? teacherName : 'Professeur';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, $displayName 👋',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: TeacherUi.inkColor(context),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Voici un aperçu de votre activité aujourd'hui.",
          style: TextStyle(
            color: TeacherUi.mutedColor(context),
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
    final statistics =
    _dashboard?['statistics'] as Map<String, dynamic>?;

    final classesCount =
    _asInt(statistics?['classes_count']);

    final studentsCount =
    _asInt(statistics?['students_count']);

    final messagesCount =
    _asInt(statistics?['messages_count']);

    final unreadMessages =
    _asInt(statistics?['unread_messages']);

    return Row(
      children: [
        Expanded(
          child: _Stat(
            icon: Icons.groups_outlined,
            value: classesCount.toString(),
            label: 'Classes',
            color: TeacherUi.blue,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _Stat(
            icon: Icons.group_outlined,
            value: studentsCount.toString(),
            label: 'Élèves',
            color: const Color(0xFF20B967),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _Stat(
            icon: Icons.chat_bubble_outline_rounded,
            value: messagesCount.toString(),
            label: 'Messages',
            color: const Color(0xFFF0444A),
            badge: unreadMessages > 0
                ? unreadMessages.toString()
                : null,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _Stat(
            icon: Icons.assignment_outlined,
            value: '—',
            label: 'Devoirs\nà corriger',
            color: const Color(0xFFFF9D19),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COURS DU JOUR
  // ============================================================

  Widget _buildTodaySection() {
    final rawSlots =
    _dashboard?['today_slots'];

    final slots = rawSlots is List
        ? rawSlots
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList()
        : <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "Aujourd'hui",
          action: 'Voir tout',
          onTap: () {
            widget.onNavigate?.call(3);
          },
        ),

        const SizedBox(height: 9),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: TeacherUi.cardDecoration(context),
          child: slots.isEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
            ),
            child: Center(
              child: Text(
                'Aucun cours prévu aujourd’hui.',
                style: TextStyle(
                  fontSize: 12,
                  color: TeacherUi.mutedColor(context),
                ),
              ),
            ),
          )
              : Column(
            children: [
              for (int i = 0; i < slots.length; i++)
                _buildCourseFromApi(
                  slots[i],
                  isLast: i == slots.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COURS API
  // ============================================================

  Widget _buildCourseFromApi(
      Map<String, dynamic> slot, {
        bool isLast = false,
      }) {
    final subject =
        slot['subject']?.toString().trim() ?? '';

    final classroom =
        slot['classroom']?.toString().trim() ?? '';

    final name =
        slot['name']?.toString().trim() ?? '';

    final title =
    subject.isNotEmpty && classroom.isNotEmpty
        ? '$subject - $classroom'
        : name.isNotEmpty
        ? name
        : subject.isNotEmpty
        ? subject
        : 'Cours';

    final start =
        slot['start']?.toString() ?? '';

    final end =
        slot['end']?.toString() ?? '';

    final time =
    start.isNotEmpty && end.isNotEmpty
        ? '$start - $end'
        : start.isNotEmpty
        ? start
        : 'Horaire non défini';

    final attendanceDone =
        slot['attendance_done'] == true;

    return Column(
      children: [
        _Course(
          title,
          time,
          attendanceDone
              ? 'Présence faite'
              : null,
        ),

        if (!isLast)
          const Divider(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
      ],
    );
  }

  // ============================================================
  // TÂCHES
  // ============================================================

  Widget _buildTasksSection() {
    final statistics =
    _dashboard?['statistics'] as Map<String, dynamic>?;

    final unreadMessages =
    _asInt(statistics?['unread_messages']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À faire',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: TeacherUi.inkColor(context),
          ),
        ),

        const SizedBox(height: 9),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: TeacherUi.cardDecoration(context),
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
                unreadMessages > 0
                    ? 'Répondre aux messages ($unreadMessages)'
                    : 'Répondre aux messages',
                null,
                Colors.transparent,
                onTap: () {
                  if (widget.onNavigate != null) {
                    widget.onNavigate!(1);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeacherChatListScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // UTILITAIRE
  // ============================================================

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
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
      decoration: TeacherUi.cardDecoration(context),
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
                  child: _Badge(badge!),
                ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: TeacherUi.inkColor(context),
            ),
          ),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              height: 1.25,
              color: TeacherUi.mutedColor(context),
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
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: TeacherUi.inkColor(context),
          ),
        ),

        const Spacer(),

        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 12,
                color: TeacherUi.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: TeacherUi.inkColor(context),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: TeacherUi.mutedColor(context),
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
            Icon(
              Icons.check_box_outline_blank_rounded,
              size: 17,
              color: TeacherUi.mutedColor(context),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: TeacherUi.inkColor(context),
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
