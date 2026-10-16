import 'package:flutter/material.dart';

/// Carte générique utilisée pour les sections du dashboard
/// (Absences, Notes, Emploi du temps, Factures...).
class DashboardSectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String badgeText;
  final Widget child;
  final String linkText;
  final VoidCallback onSeeAll;

  const DashboardSectionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.badgeText,
    required this.child,
    required this.linkText,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// Contenu personnalisé
          child,

          const SizedBox(height: 16),

          /// Lien "Voir tout"
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onSeeAll,
              icon: const Icon(
                Icons.chevron_right,
                size: 18,
              ),
              label: Text(
                linkText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
