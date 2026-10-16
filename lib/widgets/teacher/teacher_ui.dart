import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Shared visual language for the teacher workspace.
class TeacherUi {
  TeacherUi._();

  static const blue = Color(0xFF4659F5);
  static const ink = Color(0xFF111B3A);
  static const muted = Color(0xFF66708D);
  static const canvas = Color(0xFFF7F8FC);
  static const line = Color(0xFFE8EAF2);

  static Color canvasColor(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color inkColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFF0F4F8)
          : ink;

  static Color mutedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF9EAABF)
          : muted;

  static Color lineColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2C324B)
          : line;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).cardColor;

  static BoxDecoration cardDecoration(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color ?? Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: lineColor(context)),
      boxShadow: isDark
          ? []
          : const [
              BoxShadow(
                color: Color(0x080D1A3A),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
    );
  }

  static Widget iconTile(IconData icon, {Color color = blue, Color? background, double size = 21}) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: background ?? color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: size),
      );
}

class TeacherBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const TeacherBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (Icons.home_outlined, l10n.home),
      (Icons.chat_bubble_outline_rounded, l10n.messages),
      (Icons.event_note_outlined, l10n.attendance),
      (Icons.calendar_month_outlined, l10n.agenda),
      (Icons.person_outline_rounded, l10n.profile),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final mutedText = TeacherUi.mutedColor(context);

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF2C324B)
                  : TeacherUi.line,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
                (index) {
              final selected = currentIndex == index;
              final item = items[index];

              return InkWell(
                onTap: () => onTap?.call(index),
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 62,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            item.$1,
                            color: selected
                                ? TeacherUi.blue
                                : mutedText,
                            size: 22,
                          ),

                          // Badge messages non lus
                          if (index == 1)
                            Positioned(
                              right: -7,
                              top: -7,
                              child: Container(
                                width: 16,
                                height: 16,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF0444A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? TeacherUi.blue
                              : mutedText,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
