import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D47A1);
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBg = theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor;

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.12),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: navBg,
          selectedItemColor: isDark ? const Color(0xFF4659F5) : primaryBlue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [

            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: l10n.home,
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: l10n.agenda,
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: l10n.messages,
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              label: l10n.orientation,
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: l10n.profile,
            ),
          ],
      ),
    );
  }
}
