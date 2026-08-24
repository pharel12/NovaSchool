import 'package:flutter/material.dart';

class ChildCard extends StatelessWidget {
  final String initials;
  final String name;
  final String classroom;
  final bool selected;
  final bool isPresent;
  final VoidCallback? onTap;

  const ChildCard({
    super.key,
    required this.initials,
    required this.name,
    required this.classroom,
    this.selected = false,
    this.isPresent = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);
    const Color primaryOrange = Color(0xFFFF9800);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 210,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isPresent ? const Color(0xFF9FE0B4) : const Color(0xFFFFB4B8),
            width: selected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : .05),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Première ligne
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: primaryBlue.withValues(alpha: 0.15),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPresent
                        ? Colors.green.withValues(alpha: .1)
                        : Colors.red.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: isPresent ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isPresent ? "Présent" : "Absent",
                        style: TextStyle(
                          fontSize: 11,
                          color: isPresent ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              classroom,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: isDark ? Colors.white70 : const Color(0xFF155EEF),
                ),
                const SizedBox(width: 6),
                Text(
                  "Voir le profil",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF155EEF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: const Color(0xFF667085),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
