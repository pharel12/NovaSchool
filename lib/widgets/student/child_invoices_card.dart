import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/child_dashboard_models.dart';
import 'dashboard_section_card.dart';

class ChildInvoicesCard extends StatelessWidget {
  final int totalAPayer;
  final VoidCallback onSeeAll;
  final VoidCallback onPayerMaintenant;

  const ChildInvoicesCard({
    super.key,
    required this.totalAPayer,
    required this.onSeeAll,
    required this.onPayerMaintenant,
  });

  String _formatMontant(int montant) {
    final value = montant.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final pos = value.length - i;
      buffer.write(value[i]);
      if (pos > 1 && pos % 3 == 1) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.receipt_long_rounded,
      color: AppColors.accentOrange,
      title: "Factures & Paiements",
      badgeText: "Année en cours",
      onSeeAll: onSeeAll,
      linkText: "Voir l'historique des paiements",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total restant à payer",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatMontant(totalAPayer),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentOrange,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "FCFA",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onPayerMaintenant,
                  icon: const Icon(Icons.payment),
                  label: const Text("Payer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
