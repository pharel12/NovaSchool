import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/child_dashboard_models.dart';

/// Écran détaillé des factures et paiements d'un enfant.
/// L'objectif est de rendre la consultation des paiements plus claire,
/// plus structurée et plus agréable visuellement.
class ChildInvoicesScreen extends StatelessWidget {
  final int childId;
  final List<Paiement> historique;
  final int totalAPayer;

  const ChildInvoicesScreen({
    super.key,
    required this.childId,
    required this.historique,
    required this.totalAPayer,
  });

  double get totalFacture =>
      historique.fold(0, (sum, p) => sum + p.amount);

  double get totalPaye =>
      historique.fold(0, (sum, p) => sum + (p.amount - p.residual));

  double get reste =>
      historique.fold(0, (sum, p) => sum + p.residual);

  /// Formate un montant avec des espaces tous les 3 chiffres.
  String _formatMontant(int montant) {
    final value = montant.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final pos = value.length - i;
      buffer.write(value[i]);
      if (pos > 1 && pos % 3 == 1) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  /// Formate une date au format jj/mm/aaaa.
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  /// Retourne une couleur et un libellé selon l’état du paiement.
  _InvoiceBadge _badgeFor(Paiement paiement) {
    switch (paiement.paymentState.toLowerCase()) {
      case 'paid':
        return _InvoiceBadge(color: AppColors.success, label: 'Payé');
      case 'partial':
      case 'in_payment':
        return _InvoiceBadge(color: Colors.orange, label: 'Partiel');
      default:
        return _InvoiceBadge(color: AppColors.error, label: 'Impayé');
    }
  }

  @override
  Widget build(BuildContext context) {

    final paiements = [...historique]
      ..sort(
            (a, b) => b.invoiceDate.compareTo(a.invoiceDate),
      );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF155EEF),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Toutes les factures',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.accentOrange),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 16),
              if (historique.isEmpty)
                _buildEmptyState()
              else
                ...paiements.map(_buildInvoiceCard),
            ],
          ),
        ),
      ),
    );
  }

  /// Carte de synthèse du montant total à payer.
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentOrange.withValues(alpha: 0.18), Colors.white],
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
                  color: AppColors.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.accentOrange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Solde des paiements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Montant restant à régler pour l’année scolaire', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatMontant(totalAPayer),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
              ),
              const SizedBox(width: 6),
              Text('FCFA', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  /// Carte représentant une facture avec son état, son montant et ses détails.
  Widget _buildInvoiceCard(Paiement paiement) {
    final badge = _badgeFor(paiement);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paiement.feeName,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      paiement.invoiceNumber,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge.label,
                  style: TextStyle(color: badge.color, fontWeight: FontWeight.w700, fontSize: 11.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Montant : ${_formatMontant(paiement.amount.toInt())} FCFA', style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5)),
          if (paiement.residual  > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text("Reste à payer : ${_formatMontant(paiement.residual.toInt())} FCFA",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          if (paiement.dueDate  != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text("Échéance : ${_formatDate(paiement.dueDate!)}",
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Facture du ${_formatDate(paiement.invoiceDate)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  /// État vide plus clair quand aucune facture n’est disponible.
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
            Icon(Icons.receipt_long_rounded, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text('Aucune facture disponible pour le moment.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _InvoiceBadge {
  final Color color;
  final String label;

  const _InvoiceBadge({required this.color, required this.label});
}

