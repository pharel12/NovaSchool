import 'package:flutter/material.dart';


class ChildActionCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ChildActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin:
      const EdgeInsets.only(bottom:12),

      child: Material(
        color:
        theme.cardColor,

        borderRadius:
        BorderRadius.circular(18),

        child: InkWell(
          borderRadius:
          BorderRadius.circular(18),

          onTap:
          onTap,

          child: Padding(
            padding:
            const EdgeInsets.all(16),

            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),

                const SizedBox(width:15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height:4),

                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.5,
                        ),
                      )
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
