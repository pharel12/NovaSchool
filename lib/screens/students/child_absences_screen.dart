import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/child_dashboard_models.dart';
import '../../models/filter_models.dart';
import 'package:novaschool/services/child_service.dart';

/// Écran détaillé de l'historique des absences et retards d'un enfant.
/// Permet de consulter toutes les absences avec détails et filtrage.
class ChildAbsencesScreen extends StatefulWidget {
  final int childId;

  const ChildAbsencesScreen({super.key, required this.childId});

  @override
  State<ChildAbsencesScreen> createState() => _ChildAbsencesScreenState();
}

class _ChildAbsencesScreenState extends State<ChildAbsencesScreen> {
  final ChildService _childService = ChildService();

  // État de chargement et gestion des erreurs.
  bool _loading = true;
  String? _error;
  List<AbsenceEntry> _absences = [];
  AbsenceFilter? _filter;

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  /// Récupère les absences depuis le service d'API.
  Future<void> _loadAbsences() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _childService.getChildAbsences(
        widget.childId.toString(),
        filter: _filter,
      );

      if (!mounted) return;

      setState(() {
        _absences = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// Ouvre les filtres correspondant exactement aux paramètres `date_start`
  /// et `date_end` acceptés par le middleware.
  Future<void> _selectFilter(String value) async {
    if (value == 'all') {
      setState(() => _filter = null);
    } else if (value == 'week') {
      setState(() => _filter = AbsenceFilter.currentWeek());
    } else if (value == 'month') {
      setState(() => _filter = AbsenceFilter.currentMonth());
    } else if (value == 'custom') {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (range == null) return;
      setState(() => _filter = AbsenceFilter.fromDateRange(range.start, range.end));
    }
    await _loadAbsences();
  }

  /// Formate une date au format jj/mm/aaaa.
  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  /// Retourne les statistiques d'absences et retards.
  Map<String, int> _calculateStats() {
    int absences = 0;
    int retards = 0;
    int presences = 0;

    for (final entry in _absences) {
      if (entry.isLate) {
        retards++;
      } else if (entry.isAbsent) {
        absences++;
      } else if (entry.isPresent) {
        presences++;
      }
    }

    return {
      'absences': absences,
      'retards': retards,
      'presences': presences,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Historique des absences",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrer les absences',
            onSelected: _selectFilter,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('Toutes les périodes')),
              PopupMenuItem(value: 'week', child: Text('Cette semaine')),
              PopupMenuItem(value: 'month', child: Text('Ce mois-ci')),
              PopupMenuItem(value: 'custom', child: Text('Choisir une période')),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_busy, color: AppColors.accentOrange),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAbsences,
        child: Builder(
          builder: (context) {
            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade300, size: 40),
                      const SizedBox(height: 12),
                      Text(
                       _error!,
                       style: const TextStyle(color: Colors.red, fontSize: 14),
                       textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_absences.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       Icon(Icons.check_circle_outline, color: Colors.green.shade300, size: 48),
                       const SizedBox(height: 12),
                       const Text(
                         "Aucune absence enregistrée",
                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         "Excellent travail !",
                         style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                       ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Calcul des statistiques pour affichage en en-tête.
            final stats = _calculateStats();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte de synthèse des statistiques.
                  _buildStatsCard(stats),
                  const SizedBox(height: 16),
                  // Liste des absences avec détails.
                  ..._absences.map((absence) => _buildAbsenceCard(absence)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construis la carte de synthèse des statistiques d'absences.
  Widget _buildStatsCard(Map<String, int> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withValues(alpha: 0.12), Colors.white],
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.event_busy,
              label: "Absences",
              count: stats['absences']!,
              color: AppColors.error,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.access_time,
              label: "Retards",
              count: stats['retards']!,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// Construis un élément statistique avec icône et compteur.
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
      ],
    );
  }

  /// Construis une carte pour chaque absence avec détails.
  Widget _buildAbsenceCard(AbsenceEntry absence) {
    final Color color = absence.isLate ? Colors.orange : AppColors.error;
    final IconData icon = absence.isLate ? Icons.access_time : Icons.event_busy;
    final String typeLabel = absence.isLate ? "Retard" : "Absence";

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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.bold,
                       color: color,
                      ),
                    ),
                    Text(
                      _formatDate(absence.startDate),
                      style: TextStyle(
                       fontSize: 12,
                       color: Colors.grey.shade600,
                      ),
                    ),
                    if (absence.teacherName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "Enseignant : ${absence.teacherName}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (absence.comment != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                absence.comment!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
              ),
            ),
          if (absence.endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Fin : ${_formatDate(absence.endDate!)}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

