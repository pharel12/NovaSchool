import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String parentName;
  final String? photoUrl;

  const HomeHeader({
    super.key,
    required this.parentName,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue =
    Color(0xFF0D47A1);

    final theme =
    Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        // ========================================================
        // PARTIE GAUCHE
        // ========================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                "Bonjour 👋",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                parentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 22,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: primaryBlue
                      .withValues(alpha: .1),
                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: const Text(
                  "Bienvenue sur NovaSchool",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // ========================================================
        // NOTIFICATION
        // ========================================================

        Stack(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                BorderRadius.circular(16),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(
                      alpha:
                      isDark ? 0.2 : 0.05,
                    ),
                    blurRadius: 12,
                    offset:
                    const Offset(0, 5),
                  ),
                ],
              ),

              child: Icon(
                Icons.notifications_none_rounded,
                color: isDark
                    ? Colors.white70
                    : primaryBlue,
              ),
            ),

            Positioned(
              top: 10,
              right: 10,

              child: Container(
                width: 9,
                height: 9,

                decoration:
                BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.cardColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 10),

        // ========================================================
        // AVATAR
        // ========================================================

        Container(
          width: 52,
          height: 52,

          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(17),

            border: Border.all(
              color: primaryBlue
                  .withValues(alpha: .2),
              width: 2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                  alpha:
                  isDark ? 0.2 : 0.05,
                ),
                blurRadius: 12,
                offset:
                const Offset(0, 5),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(15),

            child: _buildAvatar(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildAvatar() {
    if (photoUrl != null &&
        photoUrl!.isNotEmpty) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,

        errorBuilder:
            (context, error, stackTrace) {
          return _defaultAvatar();
        },
      );
    }

    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Image.asset(
      "assets/images/profile.jpg",
      fit: BoxFit.cover,

      errorBuilder:
          (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFE8EEFF),
          child: const Icon(
            Icons.person,
            color: Color(0xFF0D47A1),
            size: 28,
          ),
        );
      },
    );
  }
}