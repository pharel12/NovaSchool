import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/child_dashboard_models.dart';
import 'dashboard_section_card.dart';

class ChildNotesCard extends StatelessWidget {
  final List<GradeEntry> grades;
  final VoidCallback onSeeAll;

  const ChildNotesCard({
    super.key,
    required this.grades,
    required this.onSeeAll,
  });

  /// Moyenne générale
  double get moyenneGenerale {
    if (grades.isEmpty) return 0;

    final total = grades.fold<double>(
      0,
          (sum, grade) => sum + grade.grade,
    );

    return total / grades.length;
  }

  /// À remplacer par les vraies données du backend
  int get classement => 0;

  /// À remplacer par les vraies données du backend
  int get effectif => 0;

  Color _colorFor(double note) {
    if (note >= 14) {
      return AppColors.success;
    } else if (note >= 10) {
      return AppColors.accentOrange;
    } else {
      return AppColors.error;
    }
  }

  String _appreciation(double note) {
    if (note >= 16) return "Excellent";
    if (note >= 14) return "Très bien";
    if (note >= 12) return "Bien";
    if (note >= 10) return "Passable";
    return "À améliorer";
  }

  @override
  Widget build(BuildContext context) {
    final sortedGrades = [...grades]
      ..sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });

    return DashboardSectionCard(
      icon: Icons.menu_book_rounded,
      color: AppColors.success,
      title: "Notes & Rang",
      badgeText: "Trimestre",
      onSeeAll: onSeeAll,
      linkText: "Voir le bulletin détaillé",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Résumé
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Moyenne générale",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          moyenneGenerale
                              .toStringAsFixed(2)
                              .replaceAll('.', ','),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _colorFor(moyenneGenerale),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "/20",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _appreciation(moyenneGenerale),
                      style: TextStyle(
                        color: _colorFor(moyenneGenerale),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              /// Classement
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Classement",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          effectif == 0 ? "--" : "${classement}e",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (effectif != 0)
                          Text(
                            " / $effectif",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
