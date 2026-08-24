import 'package:flutter/material.dart';

import '../../widgets/home/child_list.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/menu_card.dart';
import '../../widgets/home/notification_card.dart';
import '../../widgets/home/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  final String accessToken;
  const DashboardScreen({
    super.key,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Logique de rafraîchissement si nécessaire
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 32),

                _buildSectionHeader("Vos enfants", isDark),
                const SizedBox(height: 16),
                const ChildList(),
                const SizedBox(height: 32),

                _buildSectionHeader("Vue d'ensemble", isDark),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "Présence",
                        value: "92%",
                        icon: Icons.fact_check_rounded,
                        color: Colors.green,
                        subtitle: "Excellente",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: "Factures",
                        value: "25 500 F",
                        icon: Icons.receipt_long_rounded,
                        color: Colors.red,
                        subtitle: "En attente",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                _buildSectionHeader("Services", isDark),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    MenuCard(
                      title: "Emploi du temps",
                      subtitle: "Voir les cours",
                      icon: Icons.calendar_month_rounded,
                      color: Colors.blue,
                      onTap: () {},
                    ),
                    MenuCard(
                      title: "Présences",
                      subtitle: "Historique",
                      icon: Icons.fact_check_rounded,
                      color: Colors.green,
                      onTap: () {},
                    ),
                    MenuCard(
                      title: "Factures",
                      subtitle: "Paiements",
                      icon: Icons.receipt_long_rounded,
                      color: Colors.orange,
                      onTap: () {},
                    ),
                    MenuCard(
                      title: "Messages",
                      subtitle: "Discussions",
                      icon: Icons.chat_bubble_outline_rounded,
                      color: Colors.purple,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("Notifications", isDark),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Voir tout", style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const NotificationCard(
                  title: "Réunion des parents",
                  message: "Une réunion est prévue le vendredi à 14h00.",
                  date: "Aujourd'hui",
                ),
                const SizedBox(height: 12),
                const NotificationCard(
                  title: "Paiement reçu",
                  message: "Votre paiement de 25 000 FCFA a été enregistré.",
                  date: "Hier",
                  isRead: true,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

