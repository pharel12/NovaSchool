import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../../models/child_dashboard_models.dart';
import '../../core/constants/app_colors.dart';
import 'package:novaschool/services/child_service.dart';

import '../../widgets/student/child_header.dart';
import '../../widgets/student/child_absences_card.dart';
import '../../widgets/student/child_notes_card.dart';
import '../../widgets/student/child_schedule.dart';
import '../../widgets/student/child_invoices_card.dart';
import 'child_absences_screen.dart';
import 'child_notes_screen.dart';
import 'child_payments_screen.dart';
import 'child_timetable_screen.dart';

class ChildProfileScreen extends StatefulWidget {
  final ChildModel child;

  const ChildProfileScreen({super.key, required this.child});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final ChildService _childService = ChildService();
  ChildDashboard? _dashboard;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  /// Charge les données réel de l'enfant depuis les endpoints de l'API.
  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dashboard = await _childService.getChildDashboard(
        widget.child.id.toString(),
      );

      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Impossible de charger les informations de l’enfant.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _dashboard == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon enfant')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48),
                const SizedBox(height: 12),
                Text(_error ?? 'Données indisponibles.'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loadDashboard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dashboard = _dashboard!;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        title: Text(
          "Mon enfant",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    "2",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            child: Column(
              children: [
                ChildHeader(
                  child: widget.child,
                  anneeScolaire: widget.child.schoolYear ?? "2024 - 2025",
                ),
                const SizedBox(height: 16),

                ChildAbsencesCard(
                  totalJours: dashboard.totalJoursAbsents,
                  totalRetards: dashboard.totalRetards,
                  totalHeures: dashboard.totalHeuresAbsentes,
                  moisJours: dashboard.statsMoisEnCours['jours'],
                  moisHeures: dashboard.statsMoisEnCours['heures'],
                  moisRetards: dashboard.statsMoisEnCours['retards'],
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildAbsencesScreen(
                          childId: widget.child.id,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                ChildNotesCard(
                  grades: dashboard.grades,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildNotesScreen(
                          grades: dashboard.grades,
                          childId: widget.child.id,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

              ChildScheduleCard(
                cours: dashboard.timetable.timetable
                    .expand((day) => day.slots)
                    .where((slot) => slot.isToday)
                    .take(3)
                    .toList(),
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildTimeTableScreen(
                        childId: widget.child.id.toString(),
                        childName: widget.child.fullName,
                        initialData: dashboard.timetable, // On passe les données ici
                      ),
                    ),
                  );
                },
              ),
                const SizedBox(height: 16),

                ChildInvoicesCard(
                  totalAPayer: dashboard.totalAPayer.toInt(),
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildPaymentsScreen(
                          childId: widget.child.id,
                          initialPayments: dashboard.payments,
                        ),
                      ),
                    );
                  },
                  onPayerMaintenant: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Le paiement en ligne sera disponible prochainement.",
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
