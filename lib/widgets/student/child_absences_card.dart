import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/child_dashboard_models.dart';
import 'dashboard_section_card.dart';

class ChildAbsencesCard extends StatelessWidget {
  final int totalJours;
  final int totalRetards;
  final double totalHeures;
  final int moisJours;
  final double moisHeures;
  final int moisRetards;
  final VoidCallback onSeeAll;

  const ChildAbsencesCard({
    super.key,
    required this.totalJours,
    required this.totalRetards,
    required this.totalHeures,
    required this.moisJours,
    required this.moisHeures,
    required this.moisRetards,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.event_busy,
      color: AppColors.error,
      title: "Statistiques d'absences",
      badgeText: "Résumé",
      onSeeAll: onSeeAll,
      linkText: "Voir l'historique détaillé",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ce mois-ci",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Counter(
                  value: "$moisJours",
                  label: "j",
                  caption: "Absences",
                  color: AppColors.error,
                ),
              ),
              Expanded(
                child: _Counter(
                  value: moisHeures.toStringAsFixed(1),
                  label: "h",
                  caption: "Heures",
                  color: AppColors.error,
                ),
              ),
              Expanded(
                child: _Counter(
                  value: "$moisRetards",
                  label: "fois",
                  caption: "Retards",
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Text(
            "Cumul annuel",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Counter(
                  value: "$totalJours",
                  label: "jours",
                  caption: "Total jours",
                  color: Colors.grey.shade700,
                ),
              ),
              Expanded(
                child: _Counter(
                  value: totalHeures.toStringAsFixed(1),
                  label: "h",
                  caption: "Total heures",
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String value;
  final String label;
  final String caption;
  final Color color;

  const _Counter({
    required this.value,
    required this.label,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
            ),
          ],
        ),
      ],
    );
  }
}
