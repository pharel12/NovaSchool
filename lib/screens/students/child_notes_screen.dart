import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/child_dashboard_models.dart';
import '../../models/filter_models.dart';
import '../../services/child_service.dart';

/// Écran détaillé des notes d'un enfant.
/// L'objectif ici est de proposer une vue plus moderne et plus lisible
/// pour explorer rapidement les performances scolaires.
class ChildNotesScreen extends StatefulWidget {
  /// Les données déjà chargées permettent un affichage instantané à l'ouverture.
  final List<GradeEntry> grades;
  final int childId;

  const ChildNotesScreen({
    super.key,
    required this.grades,
    required this.childId,
  });

  @override
  State<ChildNotesScreen> createState() => _ChildNotesScreenState();
}

class _ChildNotesScreenState extends State<ChildNotesScreen> {
  final ChildService _childService = ChildService();
  late List<GradeEntry> _grades;
  GradesFilter? _filter;
  String? _academicYearId;
  bool _loading = false;

  List<GradeEntry> get grades => _grades;

  @override
  void initState() {
    super.initState();
    _grades = widget.grades;
  }

  /// Requête les types réellement acceptés par `GET /children/{id}/grades/`.
  Future<void> _applyFilter(EvaluationType? evaluationType) async {
    setState(() {
      _filter = evaluationType == null && _academicYearId == null
          ? null
          : GradesFilter(
              evaluationType: evaluationType,
              academicYearId: _academicYearId,
            );
      _loading = true;
    });

    try {
      final grades = await _childService.getChildGrades(
        widget.childId.toString(),
        filter: _filter,
      );
      if (mounted) setState(() => _grades = grades);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de filtrer les notes.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// L'API attend l'identifiant Odoo de l'année ; aucune liste d'années n'est
  /// encore exposée par le middleware, l'utilisateur peut donc le saisir ici.
  Future<void> _chooseAcademicYear() async {
    final controller = TextEditingController(text: _academicYearId ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Année académique'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Identifiant de l’année'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Réinitialiser'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() => _academicYearId = result.isEmpty ? null : result);
    await _applyFilter(_filter?.evaluationType);
  }

  double get moyenneGenerale {
    if (grades.isEmpty) return 0;
    return grades
        .map((e) => e.grade)
        .reduce((a, b) => a + b) /
        grades.length;
  }
  int get classement => 0;
  int get effectif => 0;

  String _formatDate(DateTime? date) {
    if (date == null) return "-";

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
  /// Formate une note pour l'afficher avec une virgule au lieu du point.
  String _formatNote(double value) => value.toStringAsFixed(2).replaceAll('.', ',');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Toutes les notes',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: _chooseAcademicYear,
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Filtrer par année académique',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrer les notes',
            onSelected: (value) {
              final type = switch (value) {
                'test' => EvaluationType.test,
                'exam' => EvaluationType.exam,
                'assignment' => EvaluationType.assignment,
                _ => null,
              };
              _applyFilter(type);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('Toutes les notes')),
              PopupMenuItem(value: 'test', child: Text('Contrôles')),
              PopupMenuItem(value: 'exam', child: Text('Examens')),
              PopupMenuItem(value: 'assignment', child: Text('Devoirs')),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: AppColors.success),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 16),
              if (grades.isEmpty)
                _buildEmptyState()
              else
                ...grades.map((grade) => _buildGradeCard(grade))
            ],
          ),
        ),
      ),
    );
  }

  /// Carte principale qui met en avant la moyenne générale et le classement.
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success.withValues(alpha: 0.18), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.insights_rounded, color: AppColors.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance scolaire',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vue d’ensemble de la progression académique',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _buildMetric(title: 'Moyenne', value: _formatNote(moyenneGenerale), suffix: '/ 20', color: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetric(
                  title: 'Classement',
                  value: effectif == 0 ? '--' : '$classement',
                  suffix: effectif == 0 ? '' : '/ $effectif',
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget réutilisable pour afficher une métrique de façon élégante.
  Widget _buildMetric({required String title, required String value, required String suffix, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 4),
              Text(suffix, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
            ],
          ),
        ],
      ),
    );
  }

  /// Carte d’une matière avec sa note et une barre de progression plus élégante.
  Widget _buildGradeCard(GradeEntry grade) {
    final ratio = (grade.grade / 20).clamp(0.0, 1.0);

    final color = ratio >= 0.7
        ? AppColors.success
        : ratio >= 0.5
        ? AppColors.accentOrange
        : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  grade.courseName,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_formatNote(grade.grade)} / 20",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatDate(grade.date),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                grade.type,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// État vide plus accueillant quand aucune note n’est disponible.
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.folder_open_rounded, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text('Aucune note disponible pour le moment.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

