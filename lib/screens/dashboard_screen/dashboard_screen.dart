import 'package:flutter/material.dart';
import '../../widgets/home/child_list.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/stat_card.dart';
import '../../widgets/home/event_card.dart';
import '../../widgets/home/section_title.dart';

class DashboardScreen extends StatelessWidget {
  final String accessToken;

  const DashboardScreen({
    super.key,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO:
            // Recharger les données du dashboard
          },

          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),

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

              const HomeHeader(),

              const SizedBox(height: 28),

              // ==================================================
              // ENFANTS
              // ==================================================

              const SectionTitle(
                title: 'Vos enfants',
                action: 'Voir tout',
              ),

              const SizedBox(height: 14),

              const ChildList(),

              const SizedBox(height: 25),

              // ==================================================
              // VUE D'ENSEMBLE
              // ==================================================

              const SectionTitle(
                title: "Vue d'ensemble",
              ),

              const SizedBox(height: 14),

              const Row(
                children: [

                  Expanded(
                    child: StatCard(
                      title: 'Présence',
                      value: '92%',
                      icon: Icons.insights_outlined,
                      color: Color(0xFF16A34A),
                      subtitle: 'Excellente',
                    ),
                  ),

                  SizedBox(width: 14),

                  Expanded(
                    child: StatCard(
                      title: 'Factures',
                      value: '25 500 F',
                      icon: Icons.receipt_long_outlined,
                      color: Color(0xFFE93442),
                      subtitle: 'En attente',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // PROCHAINS ÉVÉNEMENTS
              // ==================================================

              const SectionTitle(
                title: 'Prochains événements',
                action: 'Voir tout',
              ),

              const SizedBox(height: 12),

              const EventCard(
                icon: Icons.calendar_month_outlined,
                color: Color(0xFF2563EB),
                title: 'Réunion parents-enseignants',
                date: 'Samedi 25 mai 2025 · 10:00',
                tag: 'À venir',
              ),

              const EventCard(
                icon: Icons.event_available_outlined,
                color: Color(0xFFF59E0B),
                title: 'Fin du 3ᵉ trimestre',
                date: 'Vendredi 7 juin 2025',
                tag: 'Important',
              ),

              const EventCard(
                icon: Icons.event_note_outlined,
                color: Color(0xFF7C3AED),
                title: 'Sortie pédagogique',
                date: 'Mardi 18 juin 2025',
                tag: 'À venir',
              ),
            ],
          ),
        ),
      ),
    );
  }
}