import 'package:flutter/material.dart';

import '../../models/child_dashboard_models.dart';
import '../../models/filter_models.dart';
import '../../services/child_service.dart';

/// Liste de factures reliée aux filtres du middleware : `payment_status` et
/// `academic_year_id`. Les données sont rechargées côté serveur à chaque filtre.
class ChildPaymentsScreen extends StatefulWidget {
  final int childId;
  final List<Paiement> initialPayments;

  const ChildPaymentsScreen({
    super.key,
    required this.childId,
    required this.initialPayments,
  });

  @override
  State<ChildPaymentsScreen> createState() => _ChildPaymentsScreenState();
}

class _ChildPaymentsScreenState extends State<ChildPaymentsScreen> {
  final ChildService _childService = ChildService();
  late List<Paiement> _payments;
  PaymentStatus? _status;
  String? _academicYearId;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _payments = widget.initialPayments;
  }

  Future<void> _loadPayments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payments = await _childService.getChildPayments(
        widget.childId.toString(),
        filter: PaymentFilter(
          paymentStatus: _status,
          academicYearId: _academicYearId,
        ),
      );
      if (mounted) setState(() => _payments = payments);
    } catch (_) {
      if (mounted) setState(() => _error = 'Impossible de charger les factures.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _chooseAcademicYear() async {
    final controller = TextEditingController(text: _academicYearId ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Année académique'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Identifiant de l’année',
            hintText: 'Ex. 1',
          ),
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
    await _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    final sortedPayments = [..._payments]
      ..sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF155EEF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Toutes les factures', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: _chooseAcademicYear,
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Filtrer par année académique',
          ),
        ],
      ),
      body: Column(
        children: [
          // Ces trois statuts correspondent exactement aux valeurs de l'API.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _statusChip(null, 'Toutes'),
                _statusChip(PaymentStatus.unpaid, 'Impayées'),
                _statusChip(PaymentStatus.paid, 'Payées'),
              ],
            ),
          ),
          if (_academicYearId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Chip(
                label: Text('Année #$_academicYearId'),
                onDeleted: () {
                  setState(() => _academicYearId = null);
                  _loadPayments();
                },
              ),
            ),
          Expanded(child: _buildContent(sortedPayments)),
        ],
      ),
    );
  }

  Widget _statusChip(PaymentStatus? status, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _status == status,
        onSelected: (_) {
          setState(() => _status = status);
          _loadPayments();
        },
      ),
    );
  }

  Widget _buildContent(List<Paiement> payments) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: FilledButton.icon(
          onPressed: _loadPayments,
          icon: const Icon(Icons.refresh),
          label: Text(_error!),
        ),
      );
    }
    if (payments.isEmpty) return const Center(child: Text('Aucune facture à afficher.'));

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final payment = payments[index];
          final paid = payment.isPaid;
          return Card(
            child: ListTile(
              leading: Icon(
                paid ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                color: paid ? Colors.green : Colors.orange,
              ),
              title: Text(payment.feeName),
              subtitle: Text(payment.invoiceNumber),
              trailing: Text(
                '${payment.residual.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
