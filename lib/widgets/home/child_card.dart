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
    const Color primaryBlue =
    Color(0xFF0D47A1);

    final theme =
    Theme.of(context);

    final isDark =
        theme.brightness ==
            Brightness.dark;

    final screenWidth =
        MediaQuery.of(context).size.width;

    // Carte adaptée aux téléphones
    final cardWidth =
    screenWidth < 380
        ? screenWidth * 0.76
        : screenWidth * 0.68;

    return InkWell(
      borderRadius:
      BorderRadius.circular(18),
      onTap: onTap,

      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 250),

        width: cardWidth,
        height: 190,

        padding:
        const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: theme.cardColor,

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? primaryBlue
                : isPresent
                ? const Color(
              0xFF9FE0B4,
            )
                : const Color(
              0xFFFFB4B8,
            ),
            width: selected ? 2 : 1.2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha:
                isDark ? 0.2 : .05,
              ),
              blurRadius: 15,
              offset:
              const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ==================================================
            // PREMIERE LIGNE
            // ==================================================

            Row(
              children: [
                CircleAvatar(
                  radius: 23,

                  backgroundColor:
                  primaryBlue
                      .withValues(
                    alpha: 0.12,
                  ),

                  child: Text(
                    initials,
                    style:
                    const TextStyle(
                      color:
                      primaryBlue,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),

                  decoration:
                  BoxDecoration(
                    color: isPresent
                        ? Colors.green
                        .withValues(
                      alpha: .1,
                    )
                        : Colors.red
                        .withValues(
                      alpha: .1,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 7,
                        color: isPresent
                            ? Colors.green
                            : Colors.red,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        isPresent
                            ? "Présent"
                            : "Absent",
                        style: TextStyle(
                          fontSize: 10,
                          color: isPresent
                              ? Colors.green
                              : Colors.red,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // NOM
            // ==================================================

            Text(
              name,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : const Color(
                  0xFF111827,
                ),
              ),
            ),

            const SizedBox(height: 5),

            // ==================================================
            // CLASSE
            // ==================================================

            Text(
              classroom.isEmpty
                  ? 'Classe non renseignée'
                  : classroom,

              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,

              style: TextStyle(
                color:
                Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            const Spacer(),

            // ==================================================
            // VOIR LE PROFIL
            // ==================================================

            Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 17,
                  color: isDark
                      ? Colors.white70
                      : const Color(
                    0xFF155EEF,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  "Voir le profil",
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : const Color(
                      0xFF155EEF,
                    ),
                    fontWeight:
                    FontWeight.w600,
                    fontSize: 12,
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF667085),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}