import 'package:flutter/material.dart';

import '../../services/dashboard_service.dart';
import '../../widgets/home/child_list.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/stat_card.dart';
import '../../widgets/home/event_card.dart';
import '../../widgets/home/section_title.dart';

class DashboardScreen extends StatefulWidget {
  final String accessToken;

  const DashboardScreen({
    super.key,
    required this.accessToken,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();

  // ============================================================
  // ÉTAT
  // ============================================================

  bool _loading = true;
  String? _error;

  Map<String, dynamic> _dashboard = {};
  Map<String, dynamic> _parent = {};
  Map<String, dynamic> _overview = {};

  List<dynamic> _events = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ============================================================
  // CHARGEMENT DASHBOARD
  // ============================================================

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await _dashboardService.getParentDashboard();

      // ----------------------------------------------------------
      // Vérification de la réponse
      // ----------------------------------------------------------

      if (response['success'] == false) {
        throw Exception(
          response['message']?.toString() ??
              'Impossible de charger le dashboard.',
        );
      }

      final data = response['data'];

      if (data is! Map) {
        throw Exception(
          'Les données du dashboard sont invalides.',
        );
      }

      final dashboard =
      Map<String, dynamic>.from(data);

      // ----------------------------------------------------------
      // Parent
      // ----------------------------------------------------------

      Map<String, dynamic> parent = {};

      if (dashboard['parent'] is Map) {
        parent = Map<String, dynamic>.from(
          dashboard['parent'],
        );
      }

      // ----------------------------------------------------------
      // Vue d'ensemble
      // ----------------------------------------------------------

      Map<String, dynamic> overview = {};

      if (dashboard['overview'] is Map) {
        overview = Map<String, dynamic>.from(
          dashboard['overview'],
        );
      }

      // ----------------------------------------------------------
      // Événements
      // ----------------------------------------------------------

      List<dynamic> events = [];

      if (dashboard['upcoming_events'] is List) {
        events = List<dynamic>.from(
          dashboard['upcoming_events'],
        );
      }

      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _parent = parent;
        _overview = overview;
        _events = events;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;

        _error = e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    if (_loading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 50,
                  color: Colors.redAccent,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Impossible de charger le dashboard',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
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

    // ------------------------------------------------------------
    // Nom du parent
    // ------------------------------------------------------------

    final parentName = _getParentName();

    // ------------------------------------------------------------
    // Avatar
    // ------------------------------------------------------------

    final parentPhoto =
        _parent['photo'] ??
            _parent['avatar'] ??
            _parent['image'];

    return Scaffold(
      backgroundColor: scaffoldBg,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,

          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              24,
            ),

            children: [
              // ==================================================
              // HEADER
              // ==================================================

              HomeHeader(
                parentName: parentName,
                photoUrl: parentPhoto?.toString(),
              ),

              const SizedBox(height: 26),

              // ==================================================
              // ENFANTS
              // ==================================================

              const SectionTitle(
                title: 'Vos enfants',
                action: 'Voir tout',
              ),

              const SizedBox(height: 12),

              /*
               * IMPORTANT :
               *
               * On utilise ici ChildList.
               *
               * ChildList conserve :
               * - la récupération des enfants
               * - ChildCard
               * - le carrousel horizontal
               * - la sélection
               * - l'ouverture de ChildProfileScreen
               */

              const ChildList(),

              const SizedBox(height: 24),

              // ==================================================
              // VUE D'ENSEMBLE
              // ==================================================

              const SectionTitle(
                title: "Vue d'ensemble",
              ),

              const SizedBox(height: 12),

              _buildOverview(),

              const SizedBox(height: 24),

              // ==================================================
              // EVENEMENTS
              // ==================================================

              const SectionTitle(
                title: 'Prochains événements',
                action: 'Voir tout',
              ),

              const SizedBox(height: 12),

              _buildEvents(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NOM DU PARENT
  // ============================================================

  String _getParentName() {
    final name =
    _parent['name']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    final firstName =
        _parent['first_name']?.toString().trim() ?? '';

    final lastName =
        _parent['last_name']?.toString().trim() ?? '';

    final fullName =
    '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    final username =
    _parent['username']?.toString().trim();

    if (username != null && username.isNotEmpty) {
      return username;
    }

    return 'Parent';
  }

  // ============================================================
  // STATISTIQUES
  // ============================================================

  Widget _buildOverview() {
    final attendance =
    _overview['attendance_rate'];

    final pendingAmount =
    _overview['pending_amount'];

    final currency =
        _overview['currency']?.toString() ??
            'FCFA';

    final attendanceText =
    attendance == null
        ? '--'
        : '${_formatNumber(attendance)}%';

    final amountText =
    pendingAmount == null
        ? '0 $currency'
        : '${_formatAmount(pendingAmount)} $currency';

    final numericAmount =
        double.tryParse(
          pendingAmount?.toString() ?? '0',
        ) ??
            0;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // --------------------------------------------------------
        // Présence
        // --------------------------------------------------------

        Expanded(
          child: StatCard(
            title: 'Présence',
            value: attendanceText,
            icon: Icons.insights_outlined,
            color: const Color(0xFF16A34A),
            subtitle: attendance == null
                ? 'Aucune donnée'
                : 'Taux global',
          ),
        ),

        const SizedBox(width: 12),

        // --------------------------------------------------------
        // Factures
        // --------------------------------------------------------

        Expanded(
          child: StatCard(
            title: 'Factures',
            value: amountText,
            icon: Icons.receipt_long_outlined,
            color: const Color(0xFFE93442),
            subtitle: numericAmount > 0
                ? 'En attente'
                : 'Aucune dette',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EVENEMENTS
  // ============================================================

  Widget _buildEvents() {
    if (_events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius:
          BorderRadius.circular(14),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: const Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              color: Colors.grey,
            ),

            SizedBox(width: 10),

            Expanded(
              child: Text(
                'Aucun événement à venir.',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _events.map((event) {
        final map =
        Map<String, dynamic>.from(event);

        final title =
            map['title']?.toString() ??
                map['name']?.toString() ??
                'Événement';

        final start =
            map['start']?.toString() ??
                map['start_datetime']?.toString() ??
                '';

        final eventType =
            map['event_type']?.toString() ??
                map['type']?.toString() ??
                'À venir';

        return EventCard(
          icon: Icons.event_note_outlined,
          color: const Color(0xFF2563EB),
          title: title,
          date: start,
          tag: eventType,
        );
      }).toList(),
    );
  }

  // ============================================================
  // FORMAT NOMBRE
  // ============================================================

  String _formatNumber(dynamic value) {
    final number =
        double.tryParse(
          value.toString(),
        ) ??
            0;

    if (number == number.roundToDouble()) {
      return number
          .toInt()
          .toString();
    }

    return number
        .toStringAsFixed(1);
  }

  // ============================================================
  // FORMAT MONTANT
  // ============================================================

  String _formatAmount(dynamic value) {
    final number =
        double.tryParse(
          value.toString(),
        ) ??
            0;

    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(
        r'\B(?=(\d{3})+(?!\d))',
      ),
          (match) => ' ',
    );
  }
}