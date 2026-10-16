import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Container(
      // Même hauteur pour les deux cartes
      height: 155,

      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: theme.cardColor,

        borderRadius:
        BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.20 : 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          // ====================================================
          // ICÔNE
          // ====================================================

          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),

              borderRadius:
              BorderRadius.circular(11),
            ),

            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(height: 10),

          // ====================================================
          // TITRE
          // ====================================================

          Text(
            title,

            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style: TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 12,
              fontWeight:
              FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          // ====================================================
          // VALEUR
          // ====================================================

          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment:
              Alignment.centerLeft,

              child: Text(
                value,

                maxLines: 1,

                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : const Color(
                    0xFF111827,
                  ),

                  fontSize: 21,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 3),

          // ====================================================
          // SOUS-TITRE
          // ====================================================

          Text(
            subtitle,

            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style: TextStyle(
              color: color.withValues(
                alpha: 0.85,
              ),

              fontSize: 10,

              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}